import Fluent
import Vapor

func routes(_ app: Application) throws {
    // Register individual controllers
    try app.register(collection: MedicationCheckerController())
    // try app.register(collection: NutritionController())

    // Any other routes can also be added here
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
}
