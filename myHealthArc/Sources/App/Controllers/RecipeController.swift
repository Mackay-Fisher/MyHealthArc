import Fluent
import Vapor

struct RecipeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let recipes = routes.grouped("recipes")
        recipes.post(use: create)
    }

    func create(req: Request) async throws -> Recipe {
        let recipe = try req.content.decode(Recipe.self)
        try await recipe.save(on: req.db)
        return recipe
    }
}