// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "myHealthArc",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🌱 Fluent driver for MongoDB.
        .package(url: "https://github.com/vapor/fluent-mongo-driver.git", from: "1.3.1"),
        // 🍃 An expressive templating language for Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "4.3.0"),
        // 🔵 SwiftNIO for non-blocking, event-driven networking.
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 🌍 DotEnv for environment variable management.
        .package(url: "https://github.com/swiftpackages/DotEnv.git", from: "3.0.0"),
        // Add this to your dependencies
        .package(url: "https://github.com/vapor/queues", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentMongoDriver", package: "fluent-mongo-driver"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "DotEnv", package: "DotEnv"),
            ],
            swiftSettings: swiftSettings // Removed the trailing comma here
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            path: "Tests/AppTests",
            sources: [
                //"MongoTest.swift",
                //"SchemaTests.swift",
                //"InsertUsersTest.swift",
                //"CreateMedicationsTest.swift",
                //"CreateNutritionsTest.swift",
                //"CreateHealthKitsTest.swift",
                //"FaceIDBackendTest.swift",
                "NutritionValidationTest.swift",
                "NutritionEntryTest.swift",
            ]
        )
    ]
)

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("DisableOutwardActorInference"),
        .enableExperimentalFeature("StrictConcurrency"),
    ]
}
