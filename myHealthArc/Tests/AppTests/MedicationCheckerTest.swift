import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
import XCTVapor
@testable import App

final class MedicationCheckerTest: XCTestCase {
    var app: Application!
    var medicationCollection: MongoKitten.MongoCollection!
    var interactionCollection: MongoKitten.MongoCollection!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        let mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
        medicationCollection = mongoDB["medications"]
        interactionCollection = mongoDB["medication_interactions"]
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testAddMedications() async throws {
        let userHash = "testUser1"
        let medications = ["aspirin", "ibuprofen"]
        let dosages = ["100mg", "200mg"]
        let frequencies = [1, 2]

        try await addMedications(userHash: userHash, medications: medications, dosages: dosages, frequencies: frequencies)
        try await deleteMedications(userHash: userHash)
    }

    func testRemoveMedications() async throws {
        let userHash = "testUser2"
        let medications = ["aspirin", "ibuprofen"]
        let dosages = ["100mg", "200mg"]
        let frequencies = [1, 2]

        try await addMedications(userHash: userHash, medications: medications, dosages: dosages, frequencies: frequencies)
        try await removeMedications(userHash: userHash, medications: ["aspirin"])
        try await deleteMedications(userHash: userHash)
    }

    func testLoadUserMedications() async throws {
        let userHash = "testUser3"
        let medications = ["aspirin", "ibuprofen"]
        let dosages = ["100mg", "200mg"]
        let frequencies = [1, 2]

        try await addMedications(userHash: userHash, medications: medications, dosages: dosages, frequencies: frequencies)
        try await loadUserMedications(userHash: userHash)
        try await deleteMedications(userHash: userHash)
    }

    func testCheckInteractions() async throws {
        let userHash = "testUser4"
        let medications = ["aspirin", "ibuprofen"]
        let dosages = ["100mg", "200mg"]
        let frequencies = [1, 2]

        try await addMedications(userHash: userHash, medications: medications, dosages: dosages, frequencies: frequencies)
        try await checkInteractions(userHash: userHash, medications: medications)
        try await deleteMedications(userHash: userHash)
    }

    func testDemoCheckInteractions() async throws {
        let medications = ["aspirin", "ibuprofen"]
        try await demoCheckInteractions(medications: medications)
    }

    private func addMedications(userHash: String, medications: [String], dosages: [String], frequencies: [Int]) async throws {
        let newMedication = Medication(
            userHash: userHash,
            medications: medications,
            dosages: dosages,
            frequencies: frequencies
        )

        print("Sending POST request to add medications for \(userHash)")
        try await app.test(.POST, "/medicationChecker/add", beforeRequest: { req in
            try req.content.encode(newMedication)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Failed to add medications")
        })

        print("Fetching the medication record for \(userHash) from the database")
        guard let dbItem = try await medicationCollection.findOne(["userHash": userHash], as: Medication.self).get() else {
            XCTFail("Failed to fetch the medication record from the database")
            return
        }

        XCTAssertEqual(dbItem.userHash, newMedication.userHash, "User hash does not match")
        XCTAssertEqual(dbItem.medications, newMedication.medications, "Medications do not match")
        XCTAssertEqual(dbItem.dosages, newMedication.dosages, "Dosages do not match")
        XCTAssertEqual(dbItem.frequencies, newMedication.frequencies, "Frequencies do not match")
        print("Medication record validation completed successfully for \(userHash)")
    }

    private func removeMedications(userHash: String, medications: [String]) async throws {
        let removeRequest = RemoveMedicationsRequest(userHash: userHash, medications: medications)

        print("Sending POST request to remove medications for \(userHash)")
        try await app.test(.POST, "/medicationChecker/remove", beforeRequest: { req in
            try req.content.encode(removeRequest)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Failed to remove medications")
        })

        print("Fetching the updated medication record for \(userHash) from the database")
        guard let dbItem = try await medicationCollection.findOne(["userHash": userHash], as: Medication.self).get() else {
            XCTFail("Failed to fetch the updated medication record from the database")
            return
        }

        XCTAssertFalse(dbItem.medications.contains { medications.contains($0) }, "Medications were not removed")
        print("Medication removal validation completed successfully for \(userHash)")
    }

    private func loadUserMedications(userHash: String) async throws {
        print("Sending GET request to load medications for \(userHash)")
        try await app.test(.GET, "/medicationChecker/load?userHash=\(userHash)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Failed to load medications")
            let medication = try res.content.decode(Medication.self)
            XCTAssertEqual(medication.userHash, userHash, "User hash does not match")
            print("Loaded medication record: \(medication)")
        })
    }

    private func checkInteractions(userHash: String, medications: [String]) async throws {
        let medicationsParam = medications.joined(separator: ",")

        print("Sending GET request to check interactions for \(userHash)")
        try await app.test(.GET, "/medicationChecker/check?userHash=\(userHash)&medications=\(medicationsParam)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Failed to check interactions")
            let interactionResponse = try res.content.decode(FormattedInteractionResponse.self)
            XCTAssertFalse(interactionResponse.interactionsBySeverity.isEmpty, "No interactions found")
            print("Interaction check completed successfully for \(userHash)")
        })
    }

    private func demoCheckInteractions(medications: [String]) async throws {
        let medicationsParam = medications.joined(separator: ",")

        print("Sending GET request to demo check interactions")
        try await app.test(.GET, "/medicationChecker/demoCheck?medications=\(medicationsParam)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Failed to demo check interactions")
            let interactionResponse = try res.content.decode(FormattedInteractionResponse.self)
            XCTAssertFalse(interactionResponse.interactionsBySeverity.isEmpty, "No interactions found")
            print("Demo interaction check completed successfully")
        })
    }

    private func deleteMedications(userHash: String) async throws {
        print("Deleting the medication record for \(userHash) from the database")
        _ = try await medicationCollection.deleteOne(where: ["userHash": userHash]).get()
        print("Deleted the medication record for \(userHash)")
    }
}

struct RemoveMedicationsRequest: Content {
    let userHash: String
    let medications: [String]
}