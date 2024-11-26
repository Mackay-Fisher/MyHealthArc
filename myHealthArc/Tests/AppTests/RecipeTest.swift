import XCTest
import Fluent
import FluentMongoDriver
import Vapor
import MongoKitten
import XCTVapor
@testable import App

final class RecipeTest: XCTestCase {
    var app: Application!
    var recipeCollection: MongoKitten.MongoCollection!

    override func setUp() async throws {
        app = try await Application.make(.testing)
        try await configure(app)
        guard let databaseURL = Environment.get("DATABASE_URL") else {
            XCTFail("DATABASE_URL not set")
            return
        }
        let mongoDB = try await MongoDatabase.connect(databaseURL, on: app.eventLoopGroup.next()).get()
        recipeCollection = mongoDB["recipes"]
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
    }

    func testCreateRecipe() async throws {
        try await createRecipe(userHash: "user1", name: "Recipe 1", content: "Mix ingredients")
        try await deleteRecipe(userHash: "user1")
    }

    func testFetchRecipes() async throws {
        try await createRecipe(userHash: "user2", name: "Recipe 2", content: "Mix ingredients")
        try await fetchRecipes(userHash: "user2")
        try await deleteRecipe(userHash: "user2")
    }

    func testCreateAndFetchRecipe1() async throws {
        try await createRecipe(userHash: "user3", name: "Recipe 3", content: "Mix ingredients")
        try await fetchRecipes(userHash: "user3")
        try await deleteRecipe(userHash: "user3")
    }

    func testCreateAndFetchRecipe2() async throws {
        try await createRecipe(userHash: "user4", name: "Recipe 4", content: "Mix ingredients")
        try await fetchRecipes(userHash: "user4")
        try await deleteRecipe(userHash: "user4")
    }

    func testCreateAndFetchRecipe3() async throws {
        try await createRecipe(userHash: "user5", name: "Recipe 5", content: "Mix ingredients")
        try await fetchRecipes(userHash: "user5")
        try await deleteRecipe(userHash: "user5")
    }

    private func createRecipe(userHash: String, name: String, content: String) async throws {
        let newRecipe = Recipe(
            name: name,
            content: content,
            userHash: userHash
        )

        print("Sending POST request to create the recipe document for \(userHash)")
        try await app.test(.POST, "/recipes", beforeRequest: { req in
            try req.content.encode(newRecipe)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Failed to create recipe document")
        })

        print("Fetching the recipe document for \(userHash) from the database")
        guard let dbItem = try await recipeCollection.findOne(["userHash": userHash], as: Recipe.self).get() else {
            XCTFail("Failed to fetch the recipe document from the database")
            return
        }

        XCTAssertEqual(dbItem.userHash, newRecipe.userHash, "User hash does not match")
        XCTAssertEqual(dbItem.name, newRecipe.name, "Name does not match")
        XCTAssertEqual(dbItem.content, newRecipe.content, "Content does not match")
        print("Recipe document validation completed successfully for \(userHash)")
    }

    private func fetchRecipes(userHash: String) async throws {
        print("Sending GET request to fetch the recipe documents for \(userHash)")
        try await app.test(.GET, "/recipes?userHash=\(userHash)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok, "Failed to fetch recipe documents")
            let recipes = try res.content.decode([Recipe].self)
            XCTAssertFalse(recipes.isEmpty, "No recipes found for userHash: \(userHash)")
            print("Fetched recipe documents: \(recipes)")
        })
    }

    private func deleteRecipe(userHash: String) async throws {
        print("Deleting the recipe document for \(userHash) from the database")
        _ = try await recipeCollection.deleteOne(where: ["userHash": userHash]).get()
        print("Deleted the recipe document for \(userHash)")
    }
}