import NIOSSL
import Fluent
import FluentMongoDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try app.databases.use(DatabaseConfigurationFactory.mongo(
        connectionString: Environment.get("DATABASE_URL") ?? "mongodb://localhost:27017/vapor_database"
    ), as: .mongo)

    app.migrations.add(CreateTodo())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateMedication())
    app.migrations.add(CreateNutrition())
    app.migrations.add(CreateHealthKit())
    app.migrations.add(CreateMedicationInteractions())
    app.migrations.add(CreateNutritionItem())


    app.views.use(.leaf)


    // register routes
    try routes(app)
}
