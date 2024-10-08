import Vapor

struct MedicationCheckerController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let drugInteraction = routes.grouped("medicationChecker")
        drugInteraction.get("check", use: self.checkInteractions)
    }

    // Function to check interactions
    func checkInteractions(req: Request) async throws -> String {
        let medications = try req.query.decode([String].self) // Expecting a list of medication names as query params
        let ids = try await getRxNormIds(for: medications, client: req.client)
        
        if ids.count > 1 {
            let interactions = try await getInteractionData(ids, client: req.client)
            return interactions
        } else {
            return "Not enough medication IDs found for interaction check."
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
            
            if let id = responseData.types.first?.references.first?.id {
                ids.append(id)
            }
        }
        return ids
    }
    
    // Parse and fetch interaction data
    private func getInteractionData(_ ids: [String], client: Client) async throws -> String {
        let query = ids.joined(separator: ",")
        let url = "https://reference.medscape.com/druginteraction.do?action=getMultiInteraction&ids=\(query)"
        let response = try await client.get(URI(string: url))
        
        guard let body = response.body,
              let bodyData = body.getData(at: 0, length: body.readableBytes) else {
            throw Abort(.internalServerError, reason: "Error retrieving interaction data")
        }
        
        let interactionData = try JSONDecoder().decode(InteractionResponse.self, from: bodyData)
        return formatInteractions(interactionData)
    }
    
    // Function to format interactions by severity
    private func formatInteractions(_ interactionData: InteractionResponse) -> String {
        var result = ""
        if interactionData.errorCode == 0, let interactions = interactionData.multiInteractions {
            let sortedInteractions = interactions.sorted { $0.severityId > $1.severityId }
            
            for interaction in sortedInteractions {
                result += "Severity Level: \(interaction.severity)\nDescription: \(interaction.text)\n\n"
            }
        } else {
            result = "No interactions found."
        }
        return result
    }
}
