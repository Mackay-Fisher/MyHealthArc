import NIOSSL
import Fluent
import FluentMongoDriver
import Leaf
import Vapor

public func configure(_ app: Application) async throws {
    // Serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Configure database connection
    try app.databases.use(DatabaseConfigurationFactory.mongo(
        connectionString: Environment.get("DATABASE_URL") ?? "mongodb://localhost:27017/vapor_database"
    ), as: .mongo)

    // Add migrations
    app.migrations.add(CreateTodo())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateMedication())
    app.migrations.add(CreateNutrition())
    app.migrations.add(CreateHealthKitData())
    app.migrations.add(CreateMedicationInteractions())
    app.migrations.add(CreateNutritionItem())
    app.migrations.add(CreateUserGoals())  // Add fitness goals migration
    app.migrations.add(CreateUserStreaks()) // Add fitness streaks migration
    app.migrations.add(CreateRecipe())
    app.migrations.add(CreateUserService())

    // Use Leaf for rendering
    app.views.use(.leaf)
    // Register routes
    try routes(app)
}