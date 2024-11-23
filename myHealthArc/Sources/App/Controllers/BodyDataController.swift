import Vapor
import Fluent

struct BodyDataController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let bodyData = routes.grouped("bodyData")
        bodyData.post("update", use: self.updateBodyData)
        bodyData.get("load", use: self.loadBodyData)
        bodyData.post("dummyPath", use: self.logIncomingData)
    }

    // MARK: - Update Body Data
    func updateBodyData(req: Request) async throws -> HTTPStatus {
        struct BodyDataPayload: Content {
            let userHash: String
            let height: Double
            let weight: Double
            let age: Int
            let gender: String
            let bmi: Double?
        }

        let payload = try req.content.decode(BodyDataPayload.self)

        print(payload)

        if let existingData = try await BodyDataModel.query(on: req.db)
            .filter(\.$userHash == payload.userHash)
            .first() {
            // Update existing data
            existingData.height = payload.height
            existingData.weight = payload.weight
            existingData.age = payload.age
            existingData.gender = payload.gender
            existingData.bmi = payload.bmi
            try await existingData.save(on: req.db)
        } else {
            // Create a new record
            let newBodyData = BodyDataModel(
                userHash: payload.userHash,
                height: payload.height,
                weight: payload.weight,
                age: payload.age,
                gender: payload.gender,
                bmi: payload.bmi
            )
            try await newBodyData.save(on: req.db)
        }

        return .ok
    }

    // MARK: - Load Body Data
    func loadBodyData(req: Request) async throws -> BodyDataModel {
        struct BodyDataResponse: Content {
            let userHash: String
            let height: Double
            let weight: Double
            let age: Int
            let gender: String
            let bmi: Double
        }

        guard let userHash = req.query[String.self, at: "userHash"] else {
            throw Abort(.badRequest, reason: "User hash not provided.")
        }

        if let data = try await BodyDataModel.query(on: req.db)
            .filter(\.$userHash == userHash)
            .first() {
            // Return the existing data
            return data
        } else {
            // Return placeholder values if no data exists
            return BodyDataModel(
                userHash: userHash,
                height: 0.0,
                weight: 0.0,
                age: 0,
                gender: "unknown",
                bmi: 0.0
            )
        }
    }

    // MARK: - Log Incoming Data (Dummy Path)
    func logIncomingData(req: Request) async throws -> Response {
        guard let byteBuffer = req.body.data else {
            throw Abort(.badRequest, reason: "No data found in request body")
        }

        let data = Data(buffer: byteBuffer)

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            print("Received JSON at /dummyPath:")
            print(json)
            return Response(status: .ok, body: .init(data: data))
        } catch {
            print("Failed to parse JSON:", error)
            throw Abort(.badRequest, reason: "Invalid JSON")
        }
    }
}
