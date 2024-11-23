import Fluent
import Vapor

struct RecipeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let recipes = routes.grouped("recipes")
        recipes.post(use: create)
        recipes.get(use: fetchRecipes)
    }

    func create(req: Request) async throws -> Recipe {
        let recipe = try req.content.decode(Recipe.self)
        try await recipe.save(on: req.db)
        return recipe
    }
    
    func fetchRecipes(req: Request) async throws -> [Recipe] {
            guard let userHash = req.query[String.self, at: "userHash"] else {
                throw Abort(.badRequest, reason: "nooooooooo")
            }
            return try await Recipe.query(on: req.db)
                .filter(\.$userHash == userHash)
                .all()
        }
}
