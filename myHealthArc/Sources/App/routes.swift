import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: UserController())
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    try app.register(collection: MedicationCheckerController())
    try app.register(collection: NutritionController())
    try app.register(collection: RecipeController())
    try app.register(collection: HealthFitnessDataController())
    // try app.register(collection: FitnessController())
    try app.register(collection: GoalsController())
    try app.register(collection: BodyDataController())
    try app.register(collection: UserServiceController())
}
