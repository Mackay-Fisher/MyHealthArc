



import Vapor

struct MedicationCheckerController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let drugInteraction = routes.grouped("medicationChecker")
        drugInteraction.get("check", use: self.checkInteractions)
    }

    @Sendable
    func checkInteractions(req: Request) async throws -> FormattedInteractionResponse {
        let medicationsParam = try req.query.get(String.self, at: "medications")
        let medications = medicationsParam.split(separator: ",").map(String.init)
        let ids = try await getRxNormIds(for: medications, client: req.client)
        
        if ids.count > 1 {
            let interactions = try await getInteractionData(ids, client: req.client)
            return interactions
        } else {
            throw Abort(.badRequest, reason: "Not enough medication IDs found for interaction check.")
        }
    }

    // Fetch RxNorm IDs
    private func getRxNormIds(for drugs: [String], client: Client) async throws -> [String] {
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
            
            // Extract IDs from the first 'types' element if available
            if let firstType = responseData.types.first {
                let extractedIds = firstType.references.map { $0.id }
                print("Extracted IDs for \(drug):", extractedIds) // Print IDs for debugging
                
                if let firstId = extractedIds.first {
                    ids.append(firstId) // Add only the first ID to the result list
                }
            }
        }
        
        // Print all collected IDs for debugging
        print("All IDs:", ids)
        return ids
    }


    
    // Parse and fetch interaction data
    private func getInteractionData(_ ids: [String], client: Client) async throws -> FormattedInteractionResponse {
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


    
    private func formatInteractions(_ interactionData: InteractionResponse) -> FormattedInteractionResponse {
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



}
