import Vapor
import Fluent

struct WeeklyTaskHandler: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let weeklyTasks = routes.grouped("weeklyTasks")
        weeklyTasks.get("updateInteractions", use: self.updateMedicationInteractions)
    }

    /// Update all existing medication interactions
    func updateMedicationInteractions(req: Request) async throws -> HTTPStatus {
        req.logger.info("Starting weekly update of medication interactions...")

        // Fetch all records in the medication_interactions database
        let allInteractions = try await MedicationInteraction.query(on: req.db).all()

        for interaction in allInteractions {
            // Fetch updated conflicts for the medications
            let updatedConflicts = try await fetchUpdatedConflicts(for: interaction.medications, req: req)

            // Update the database record with the new conflicts
            interaction.conflicts = updatedConflicts
            try await interaction.save(on: req.db)

            req.logger.info("Updated conflicts for medications: \(interaction.medications.joined(separator: ", "))")
        }

        req.logger.info("All medication interactions have been updated successfully.")
        return .ok
    }

    /// Fetch updated conflicts for a list of medications
    private func fetchUpdatedConflicts(for medications: [String], req: Request) async throws -> [String] {
        // Use MedicationCheckerController's functions to fetch RxNorm IDs and interaction data
        let checkerController = MedicationCheckerController()

        // Fetch RxNorm IDs for the medications
        let ids = try await checkerController.getRxNormIds(for: medications, client: req.client)

        // Fetch interaction data using the IDs
        let interactionData = try await checkerController.getInteractionData(ids, client: req.client)

        // Format the interaction data into conflicts
        let formattedConflicts = interactionData.interactionsBySeverity.flatMap { (severity, reactions) in
            reactions.map { "\(severity): \($0.description)" }
        }

        return formattedConflicts
    }
}
