import Fluent
import Vapor

struct CreateHealthKitData: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("healthkit_data")
            .id()
            .field("userHash", .string, .required) // Unique user identifier
            .field("date", .datetime, .required) // Timestamp for daily data

            // Body Measurements
            .field("height", .double) // Height in meters
            .field("body_mass", .double) // Body Mass in kilograms
            .field("body_mass_index", .double) // BMI

            // Vital Signs
            .field("heart_rate", .double) // Heart Rate in bpm
            .field("blood_pressure_systolic", .double) // Systolic blood pressure
            .field("blood_pressure_diastolic", .double) // Diastolic blood pressure
            .field("respiratory_rate", .double) // Respiratory Rate in breaths per minute
            .field("body_temperature", .double) // Body Temperature in Celsius

            // Activity and Fitness
            .field("step_count", .int) // Total steps taken
            .field("distance_walking_running", .double) // Distance in meters
            .field("flights_climbed", .int) // Number of flights of stairs
            .field("active_energy_burned", .double) // Calories burned
            .field("exercise_time", .double) // Minutes of exercise

            // Nutrition
            .field("dietary_energy", .double) // Total calories consumed
            .field("protein", .double) // Protein in grams
            .field("carbohydrates", .double) // Carbohydrates in grams
            .field("fat", .double) // Fat in grams
            .field("calcium", .double) // Calcium in mg
            .field("iron", .double) // Iron in mg
            .field("potassium", .double) // Potassium in mg
            .field("sodium", .double) // Sodium in mg

            // Sleep
            .field("sleep_analysis", .array(of: .string)) // Sleep periods (e.g., "inBed", "asleep")
            .field("time_asleep", .double) // Time asleep in hours

            // Workouts
            .field("workout_type", .string) // Type of workout (e.g., "running", "swimming")
            .field("workout_duration", .double) // Duration of workout in minutes
            .field("workout_calories_burned", .double) // Calories burned during workout
            .field("workout_distance", .double) // Distance covered

            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("healthkit_data").delete()
    }
}
