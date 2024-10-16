import Fluent
import Vapor

func routes(_ app: Application) throws {
    // Register individual controllers
    try app.register(collection: MedicationCheckerController())
    try app.register(collection: NutritionController())
    try app.register(collection: HealthDataController())
}
