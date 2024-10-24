import Vapor
import Fluent
struct MedicationCheckerController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let drugInteraction = routes.grouped("medicationChecker")
        // drugInteraction.get("check", use: self.checkInteractions)
        drugInteraction.post("add", use: self.addMedications)
        // drugInteraction.post("remove", use: self.removeMedications)
        drugInteraction.get("test", use: self.test)
    }

    func test(req: Request) async throws -> String {
        let newInteraction = MedicationInteraction(
            medications: ["Aspirin", "Ibuprofen"],
            conflicts: ["Increased bleeding risk"]
        )
        try await newInteraction.save(on: req.db)

        guard let userHash = req.query[String.self, at: "userHash"] else {
            throw Abort(.badRequest, reason: "User hash not provided.")
        }

        print("User Hash: \(userHash)")

        // Query the database for medications associated with the userHash
        let userMedications = try await Medication.query(on: req.db)
            .filter(\.$userHash == userHash)
            .all()

        print("User Hash: \(userHash)")
        print("User Medications: \(userMedications)")
        // Print all user information (for debugging purposes)
        // userMedications.forEach { medication in
        //     print("User Hash: \(medication.userHash)")
        //     print("Medications: \(medication.medications)")
        //     print("Interactions: \(medication.interactions)")
        // }

        return "yippe"
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




    // @Sendable
    // func checkInteractions(req: Request) async throws -> FormattedInteractionResponse {
    //     let userHash = try req.query.get(String.self, at: "userHash")
    //     let medicationsParam = try req.query.get(String.self, at: "medications")
    //     let medications = medicationsParam.split(separator: ",").map(String.init)
    //     guard let userHash = req.parameters.get("userHash") else {
    //         throw Abort(.badRequest, reason: "User hash not provided.")
    //     }

    //     let ids = try await getRxNormIds(for: medications, client: req.client)
        
    //     if ids.count > 1 {
    //         let interactions = try await getInteractionData(ids, client: req.client)
    //         return interactions
    //     } else {
    //         throw Abort(.badRequest, reason: "Not enough medication IDs found for interaction check.")
    //     }
    // }

    // // Fetch RxNorm IDs
    // private func getRxNormIds(for drugs: [String], client: Client) async throws -> [String] {
    //     var ids: [String] = []
    //     for drug in drugs {
    //         let url = "https://www.medscape.com/api/quickreflookup/LookupService.ashx?q=\(drug)&sz=500&type=10417&metadata=has-interactions&format=json&jsonp=MDICshowResults"
    //         let response = try await client.get(URI(string: url))
            
    //         guard let body = response.body,
    //             var bodyString = body.getString(at: 0, length: body.readableBytes) else {
    //             print("Error retrieving ID for \(drug)")
    //             continue
    //         }
            
    //         // Remove the wrapper function and parse JSON
    //         bodyString = bodyString.replacingOccurrences(of: "MDICshowResults(", with: "")
    //             .replacingOccurrences(of: ");", with: "")
            
    //         let data = Data(bodyString.utf8)
    //         let responseData = try JSONDecoder().decode(ResponseData.self, from: data)
            
    //         // Extract IDs from the first 'types' element if available this is the id for querying interactions
    //         if let firstType = responseData.types.first {
    //             let extractedIds = firstType.references.map { $0.id }
    //             if let firstId = extractedIds.first {
    //                 ids.append(firstId)
    //             }
    //         }
    //     }
    //     return ids
    // }

    // // Parse and fetch interaction data
    // private func getInteractionData(_ ids: [String], client: Client) async throws -> FormattedInteractionResponse {
    //     let query = ids.joined(separator: ",")
    //     let url = "https://reference.medscape.com/druginteraction.do?action=getMultiInteraction&ids=\(query)"
    //     let response = try await client.get(URI(string: url))
        
    //     guard let body = response.body,
    //         let bodyData = body.getData(at: 0, length: body.readableBytes) else {
    //         throw Abort(.internalServerError, reason: "Error retrieving interaction data")
    //     }
        
    //     let interactionData = try JSONDecoder().decode(InteractionResponse.self, from: bodyData)
        
    //     // Format and return all interactions as JSON
    //     return formatInteractions(interactionData)
    // }

    // private func formatInteractions(_ interactionData: InteractionResponse) -> FormattedInteractionResponse {
    //     var interactionsBySeverity: [String: [FormattedInteraction]] = [:]
        
    //     if interactionData.errorCode == 1, let interactions = interactionData.multiInteractions {
    //         for interaction in interactions {
    //             // Extract a note from the text if present
    //             let note: String?
    //             if let commentRange = interaction.text.range(of: "Comment:") {
    //                 note = String(interaction.text[commentRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
    //             } else {
    //                 note = nil
    //             }
                
    //             let formattedInteraction = FormattedInteraction(
    //                 severity: interaction.severity,
    //                 interaction: "\(interaction.subject) and \(interaction.object)",
    //                 description: interaction.text,
    //                 note: note
    //             )
                
    //             // Append the interaction to the appropriate severity level
    //             if interactionsBySeverity[interaction.severity] != nil {
    //                 interactionsBySeverity[interaction.severity]?.append(formattedInteraction)
    //             } else {
    //                 interactionsBySeverity[interaction.severity] = [formattedInteraction]
    //             }
    //         }
    //     }
        
    //     return FormattedInteractionResponse(interactionsBySeverity: interactionsBySeverity)
    // }

    // @Sendable
    // func addMedications(req: Request) async throws -> HTTPStatus {
    //     let userHash = try req.content.get(String.self, at: "userHash")
    //     let medications = try req.content.get([[String: String]].self, at: "medications") // Array of dictionaries

    //     // Extract medication names for interaction fetching
    //     let medicationNames = medications.compactMap { $0["name"] }
    //     let ids = try await getRxNormIds(for: medicationNames, client: req.client)
    //     let interactions = try await getInteractionData(ids, client: req.client)

    //     // Update medications and interactions in the database
    //     try await saveOrUpdateMedications(medications, userHash: userHash, conflicts: interactions, db: req.db)

    //     return .ok
    // }

    // @Sendable
    // func removeMedications(req: Request) async throws -> HTTPStatus {
    //     let userHash = try req.content.get(String.self, at: "userHash")
    //     let medicationsToRemove = try req.content.get([String].self, at: "medications")

    //     if let existingMedication = try await Medication.query(on: req.db)
    //         .filter(\.$userHash == userHash)
    //         .first() {
            
    //         // Remove specified medications from the list
    //         existingMedication.medications.removeAll { medication in
    //             medicationsToRemove.contains(medication["name"] ?? "")
    //         }

    //         // Remove interactions related to the removed medications
    //         for medicationName in medicationsToRemove {
    //             existingMedication.interactions.removeValue(forKey: medicationName)
    //         }

    //         try await existingMedication.save(on: req.db)
    //     }

    //     return .ok
    // }

    // // Format interactions from the database
    // private func formatDatabaseInteractions(_ medication: Medication, for requestedMeds: [String]) -> FormattedInteractionResponse {
    //     var interactionsBySeverity: [String: [FormattedInteraction]] = [:]

    //     for med in requestedMeds {
    //         if let conflicts = medication.interactions[med] {
    //             for conflict in conflicts {
    //                 let formattedInteraction = FormattedInteraction(
    //                     severity: "Unknown",
    //                     interaction: med,
    //                     description: conflict,
    //                     note: nil
    //                 )
                    
    //                 if interactionsBySeverity["Unknown"] != nil {
    //                     interactionsBySeverity["Unknown"]?.append(formattedInteraction)
    //                 } else {
    //                     interactionsBySeverity["Unknown"] = [formattedInteraction]
    //                 }
    //             }
    //         }
    //     }

    //     return FormattedInteractionResponse(interactionsBySeverity: interactionsBySeverity)
    // }

    // // Save or update medications and interactions in the database
    // private func saveOrUpdateMedications(_ medications: [[String: String]], userHash: String, conflicts: FormattedInteractionResponse, db: Database) async throws {
    //     if var existingMedication = try await Medication.query(on: db).filter(\.$userHash == userHash).first() {
    //         // Add new medications and conflicts
    //         for medication in medications {
    //             let medName = medication["name"] ?? ""

    //             // If the medication is not already in the list, add it
    //             if !existingMedication.medications.contains(where: { $0["name"] == medName }) {
    //                 existingMedication.medications.append(medication)
    //             }
                
    //             // Update interactions for the medication
    //             let conflictList = conflicts.interactionsBySeverity.values.flatMap { $0.map { $0.description } }
    //             existingMedication.interactions[medName] = conflictList
    //         }

    //         try await existingMedication.save(on: db)
    //     } else {
    //         // Create new Medication entry
    //         let conflictList = conflicts.interactionsBySeverity.values.flatMap { $0.map { $0.description } }
    //         let newMedication = Medication(userHash: userHash, medications: medications, interactions: [medications.compactMap { $0["name"] }.joined(separator: ","): conflictList])
    //         try await newMedication.save(on: db)
    //     }
    // }
}
