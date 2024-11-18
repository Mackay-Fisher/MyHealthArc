import Vapor
import Fluent

final class HealthKitData: Model, Content {
    static let schema = "healthkit_data"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "userHash")
    var userHash: String
    
    @Field(key: "date")
    var date: Date

    // Body Measurements
    @OptionalField(key: "height")
    var height: Double?

    @OptionalField(key: "body_mass")
    var bodyMass: Double?

    @OptionalField(key: "body_mass_index")
    var bodyMassIndex: Double?

    // Vital Signs
    @OptionalField(key: "heart_rate")
    var heartRate: Double?

    @OptionalField(key: "blood_pressure_systolic")
    var bloodPressureSystolic: Double?

    @OptionalField(key: "blood_pressure_diastolic")
    var bloodPressureDiastolic: Double?

    @OptionalField(key: "respiratory_rate")
    var respiratoryRate: Double?

    @OptionalField(key: "body_temperature")
    var bodyTemperature: Double?

    // Activity and Fitness
    @OptionalField(key: "step_count")
    var stepCount: Int?

    @OptionalField(key: "distance_walking_running")
    var distanceWalkingRunning: Double?

    @OptionalField(key: "flights_climbed")
    var flightsClimbed: Int?

    @OptionalField(key: "active_energy_burned")
    var activeEnergyBurned: Double?

    @OptionalField(key: "exercise_time")
    var exerciseTime: Double?

    // Nutrition
    @OptionalField(key: "dietary_energy")
    var dietaryEnergy: Double?

    @OptionalField(key: "protein")
    var protein: Double?

    @OptionalField(key: "carbohydrates")
    var carbohydrates: Double?

    @OptionalField(key: "fat")
    var fat: Double?

    @OptionalField(key: "calcium")
    var calcium: Double?

    @OptionalField(key: "iron")
    var iron: Double?

    @OptionalField(key: "potassium")
    var potassium: Double?

    @OptionalField(key: "sodium")
    var sodium: Double?

    // Sleep
    @OptionalField(key: "sleep_analysis")
    var sleepAnalysis: [String]?

    @OptionalField(key: "time_asleep")
    var timeAsleep: Double?

    // Workouts
    @OptionalField(key: "workout_type")
    var workoutType: String?

    @OptionalField(key: "workout_duration")
    var workoutDuration: Double?

    @OptionalField(key: "workout_calories_burned")
    var workoutCaloriesBurned: Double?

    @OptionalField(key: "workout_distance")
    var workoutDistance: Double?
    
    init() {}

    init(
        id: UUID? = nil,
        userHash: String,
        date: Date,
        height: Double? = nil,
        bodyMass: Double? = nil,
        bodyMassIndex: Double? = nil,
        heartRate: Double? = nil,
        bloodPressureSystolic: Double? = nil,
        bloodPressureDiastolic: Double? = nil,
        respiratoryRate: Double? = nil,
        bodyTemperature: Double? = nil,
        stepCount: Int? = nil,
        distanceWalkingRunning: Double? = nil,
        flightsClimbed: Int? = nil,
        activeEnergyBurned: Double? = nil,
        exerciseTime: Double? = nil,
        dietaryEnergy: Double? = nil,
        protein: Double? = nil,
        carbohydrates: Double? = nil,
        fat: Double? = nil,
        calcium: Double? = nil,
        iron: Double? = nil,
        potassium: Double? = nil,
        sodium: Double? = nil,
        sleepAnalysis: [String]? = nil,
        timeAsleep: Double? = nil,
        workoutType: String? = nil,
        workoutDuration: Double? = nil,
        workoutCaloriesBurned: Double? = nil,
        workoutDistance: Double? = nil
    ) {
        self.id = id
        self.userHash = userHash
        self.date = date
        self.height = height
        self.bodyMass = bodyMass
        self.bodyMassIndex = bodyMassIndex
        self.heartRate = heartRate
        self.bloodPressureSystolic = bloodPressureSystolic
        self.bloodPressureDiastolic = bloodPressureDiastolic
        self.respiratoryRate = respiratoryRate
        self.bodyTemperature = bodyTemperature
        self.stepCount = stepCount
        self.distanceWalkingRunning = distanceWalkingRunning
        self.flightsClimbed = flightsClimbed
        self.activeEnergyBurned = activeEnergyBurned
        self.exerciseTime = exerciseTime
        self.dietaryEnergy = dietaryEnergy
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.calcium = calcium
        self.iron = iron
        self.potassium = potassium
        self.sodium = sodium
        self.sleepAnalysis = sleepAnalysis
        self.timeAsleep = timeAsleep
        self.workoutType = workoutType
        self.workoutDuration = workoutDuration
        self.workoutCaloriesBurned = workoutCaloriesBurned
        self.workoutDistance = workoutDistance
    }
}
