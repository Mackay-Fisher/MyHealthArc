import Vapor
import Fluent
struct MedicationCheckerController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let drugInteraction = routes.grouped("medicationChecker")
        drugInteraction.get("check", use: self.checkInteractions)
        drugInteraction.post("add", use: self.addMedications)
        drugInteraction.post("remove", use: self.removeMedications)
        drugInteraction.get("load", use: self.loadUserMedications)
        drugInteraction.get("demoCheck", use: self.demoCheckInteractions)
    }

    @Sendable
    func demoCheckInteractions(req: Request) async throws -> FormattedInteractionResponse {
        // Get medications from the query and convert to lowercase
        let medicationsParam = try req.query.get(String.self, at: "medications")
        let medications = medicationsParam.split(separator: ",").map { $0.lowercased() }

        // Ensure at least two medications are provided
        guard medications.count >= 2 else {
            throw Abort(.badRequest, reason: "At least two medications are required for interaction checking.")
        }

        // Sort medications for consistent lookup
        let sortedMedications = medications.sorted()

        // Fetch RxNorm IDs for the medications
        let ids = try await getRxNormIds(for: sortedMedications, client: req.client)

        // Ensure there are enough IDs for interaction checking
        guard ids.count > 1 else {
            throw Abort(.badRequest, reason: "Not enough medication IDs found for interaction check.")
        }

        // Fetch interaction data based on the IDs
        let interactions = try await getInteractionData(ids, client: req.client)

        return interactions
    }


    @Sendable
    func loadUserMedications(req: Request) async throws -> Medication {
        // Get userHash from the query
        guard let userHash = req.query[String.self, at: "userHash"] else {
            throw Abort(.badRequest, reason: "User hash not provided.")
        }

        // Retrieve the medication record associated with the userHash
        guard let existingMedication = try await Medication.query(on: req.db)
            .filter(\.$userHash == userHash)
            .first() else {
            throw Abort(.notFound, reason: "No medications found for the given user.")
        }

        // Return the medication record as JSON
        return existingMedication
    }


    @Sendable
    func addMedications(req: Request) async throws -> Medication {
        // Get userHash from the request body
        let userHash = try req.content.get(String.self, at: "userHash")
        
        // Get medications, dosages, and frequencies from the request body
        let newMedications = try req.content.get([String].self, at: "medications")
        let newDosages = try req.content.get([String].self, at: "dosages")
        let newFrequencies = try req.content.get([Int].self, at: "frequencies") // Changed to integer array

        // Query for existing medication record for the user
        if var existingMedication = try await Medication.query(on: req.db)
            .filter(\.$userHash == userHash)
            .first() {

            // Iterate over new medications
            for (index, newMed) in newMedications.enumerated() {
                if let existingIndex = existingMedication.medications.firstIndex(of: newMed) {
                    // If the medication exists but the frequency is different, update the frequency
                    if existingMedication.frequencies[existingIndex] != newFrequencies[index] {
                        existingMedication.frequencies[existingIndex] = newFrequencies[index]
                    }
                } else {
                    // If the medication doesn't exist, add it along with dosage and frequency
                    existingMedication.medications.append(newMed)
                    existingMedication.dosages.append(newDosages[index])
                    existingMedication.frequencies.append(newFrequencies[index])
                }
            }

            // Save the updated medications to the database
            try await existingMedication.save(on: req.db)
            return existingMedication
        } else {
            // Create a new Medication entry if no existing record is found for the user
            let newMedication = Medication(
                userHash: userHash,
                medications: newMedications,
                dosages: newDosages,
                frequencies: newFrequencies
            )
            
            // Save the new medication entry to the database
            try await newMedication.save(on: req.db)
            return newMedication
        }
    }

    @Sendable
    func checkInteractions(req: Request) async throws -> FormattedInteractionResponse {
        // Get userHash from the query
        guard let userHash = req.query[String.self, at: "userHash"] else {
            throw Abort(.badRequest, reason: "User hash not provided.")
        }
        
         // Get medications from the query and convert them to lowercase
        let medicationsParam = try req.query.get(String.self, at: "medications")
        let queryMedications = medicationsParam.split(separator: ",").map { $0.lowercased() }


        let existingMedication = try await Medication.query(on: req.db)
        .filter(\.$userHash == userHash)
        .first()

        // Combine existing medications with the passed-in ones, making sure they are unique
        let medications: [String]
        if let storedMeds = existingMedication?.medications {
            medications = Array(Set(storedMeds.map { $0.lowercased() } + queryMedications))
        } else {
            medications = queryMedications
        }

        // Sort medications for consistent lookup
        let sortedMedications = medications.sorted()

        // Check if interactions already exist for this sorted list of medications (case-insensitive)
        if let existingInteraction = try await MedicationInteraction.query(on: req.db)
            .filter(\.$medications == sortedMedications)
            .first() {

            // Return existing interactions if found
            return formatStoredInteractions(existingInteraction)
        }

        // Fetch RxNorm IDs for the sorted medications
        let ids = try await getRxNormIds(for: sortedMedications, client: req.client)
        
        // Ensure there are enough IDs for interaction checking
        guard ids.count > 1 else {
            throw Abort(.badRequest, reason: "Not enough medication IDs found for interaction check.")
        }

        // Fetch interaction data based on the IDs
        let interactions = try await getInteractionData(ids, client: req.client)

        // Save new interactions in the medication_interactions collection
        try await saveNewInteractions(medications: sortedMedications, interactions: interactions, db: req.db)

        return interactions
    }


    public func saveNewInteractions(medications: [String], interactions: FormattedInteractionResponse, db: Database) async throws {
        // Prepare conflicts with severity
        let formattedConflicts = interactions.interactionsBySeverity.flatMap { (severity, reactions) in
            reactions.map { "\(severity): \($0.description)" }
        }

        // Create a new MedicationInteraction record
        let newInteraction = MedicationInteraction(
            medications: medications,
            conflicts: formattedConflicts
        )

        // Save to the database
        try await newInteraction.save(on: db)
    }


    private func formatStoredInteractions(_ interaction: MedicationInteraction) -> FormattedInteractionResponse {
        var interactionsBySeverity: [String: [FormattedInteraction]] = [:]

        for conflict in interaction.conflicts {
            // Split the conflict string into severity and description
            let components = conflict.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            if components.count == 2 {
                let severity = String(components[0])
                let description = String(components[1])

                let formattedInteraction = FormattedInteraction(
                    severity: severity,
                    interaction: interaction.medications.joined(separator: ", "),
                    description: description,
                    note: nil
                )

                // Add to the appropriate severity level
                if interactionsBySeverity[severity] != nil {
                    interactionsBySeverity[severity]?.append(formattedInteraction)
                } else {
                    interactionsBySeverity[severity] = [formattedInteraction]
                }
            }
        }

        return FormattedInteractionResponse(interactionsBySeverity: interactionsBySeverity)
    }


    // Fetch RxNorm IDs
    public func getRxNormIds(for drugs: [String], client: Client) async throws -> [String] {
        var ids: [String] = []
        for drug in drugs {
            let url = "https://www.medscape.com/api/quickreflookup/LookupService.ashx?q=\(drug)&sz=500&type=10417&metadata=has-interactions&format=json&jsonp=MDICshowResults"
            let response = try await client.get(URI(string: url))

            guard let body = response.body,
                var bodyString = body.getString(at: 0, length: body.readableBytes) else {
                print("Error retrieving ID for \(drug)")
                continue
            }            
            // Remove the wrapper function and parse JSON
            bodyString = bodyString.replacingOccurrences(of: "MDICshowResults(", with: "")
                .replacingOccurrences(of: ");", with: "")
            
            let data = Data(bodyString.utf8)
            let responseData = try JSONDecoder().decode(ResponseData.self, from: data)
            
            // Extract IDs from the first 'types' element if available this is the id for querying interactions
            if let firstType = responseData.types.first {
                let extractedIds = firstType.references.map { $0.id }
                if let firstId = extractedIds.first {
                    ids.append(firstId)
                }
            }
        }
        return ids
    }

    // // Parse and fetch interaction data
    public func getInteractionData(_ ids: [String], client: Client) async throws -> FormattedInteractionResponse {
        let query = ids.joined(separator: ",")
        let url = "https://reference.medscape.com/druginteraction.do?action=getMultiInteraction&ids=\(query)"
        let response = try await client.get(URI(string: url))
        
        guard let body = response.body,
            let bodyData = body.getData(at: 0, length: body.readableBytes) else {
            throw Abort(.internalServerError, reason: "Error retrieving interaction data")
        }
        
        let interactionData = try JSONDecoder().decode(InteractionResponse.self, from: bodyData)
        
        // Format and return all interactions as JSON
        return formatInteractions(interactionData)
    }

    public func formatInteractions(_ interactionData: InteractionResponse) -> FormattedInteractionResponse {
        var interactionsBySeverity: [String: [FormattedInteraction]] = [:]
        
        if interactionData.errorCode == 1, let interactions = interactionData.multiInteractions {
            for interaction in interactions {
                // Extract a note from the text if present
                let note: String?
                if let commentRange = interaction.text.range(of: "Comment:") {
                    note = String(interaction.text[commentRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    note = nil
                }
                
                let formattedInteraction = FormattedInteraction(
                    severity: interaction.severity,
                    interaction: "\(interaction.subject) and \(interaction.object)",
                    description: interaction.text,
                    note: note
                )
                
                // Append the interaction to the appropriate severity level
                if interactionsBySeverity[interaction.severity] != nil {
                    interactionsBySeverity[interaction.severity]?.append(formattedInteraction)
                } else {
                    interactionsBySeverity[interaction.severity] = [formattedInteraction]
                }
            }
        }
        
        return FormattedInteractionResponse(interactionsBySeverity: interactionsBySeverity)
    }

    @Sendable
    func removeMedications(req: Request) async throws -> HTTPStatus {
        // Get userHash from the request body
        let userHash = try req.content.get(String.self, at: "userHash")

        // Get medications to remove from the request body and convert to lowercase
        let medicationsToRemove = try req.content.get([String].self, at: "medications").map { $0.lowercased() }

        // Retrieve existing medication record for the user
        guard var existingMedication = try await Medication.query(on: req.db)
            .filter(\.$userHash == userHash)
            .first() else {
            throw Abort(.notFound, reason: "No medications found for the given user.")
        }

        // Convert stored medications to lowercase for case-insensitive matching
        var storedMedications = existingMedication.medications.map { $0.lowercased() }

        // Iterate through the medications to remove
        for med in medicationsToRemove {
            if let index = storedMedications.firstIndex(of: med) {
                // Remove the medication and associated dosage and frequency
                storedMedications.remove(at: index)
                existingMedication.medications.remove(at: index)
                existingMedication.dosages.remove(at: index)
                existingMedication.frequencies.remove(at: index)
            }
        }

        // If no medications are left, delete the record
        if existingMedication.medications.isEmpty {
            try await existingMedication.delete(on: req.db)
            return .ok
        }

        // Save the updated medication record
        try await existingMedication.save(on: req.db)

        return .ok
    }



}
