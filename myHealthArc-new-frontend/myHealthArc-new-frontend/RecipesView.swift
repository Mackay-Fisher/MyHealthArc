//
//  RecipesView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 11/22/24.
//

import SwiftUI
import SwiftKeychainWrapper

struct RecipesView: View {
    @State private var recipes: [Recipe] = []
    @State private var isLoading = true
    @State private var selectedRecipe: Recipe?
    @State private var showRecipeDetail = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            ScrollView{
                // Header
                HStack {
                    Image(systemName: "book.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(-2)
                        .frame(width: 30)
                        .foregroundColor(.mhaSalmon)
                    
                    Text("Recipes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                }
                
                Divider()
                
                // Content
                if isLoading {
                    ProgressView()
                        .padding()
                } else if recipes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Recipes Saved")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Your saved recipes will appear here.\nUse the Recipe Assistant to generate and save recipes!")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    // Recipes List
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(recipes) { recipe in
                                Button(action: {
                                    selectedRecipe = recipe
                                    showRecipeDetail = true
                                }) {
                                    RecipeRowView(recipe: recipe)
                                }
                            }
                        }
                        .padding()
                    }
                    .sheet(item: $selectedRecipe) { recipe in
                        RecipeDetailView(recipe: recipe)
                    }
                }
            }
            .onAppear {
                fetchRecipes()
            }
        }
    }
    
    private func fetchRecipes() {
        guard let userHash = KeychainWrapper.standard.string(forKey: "userHash") else {
            print("DEBUG - Failed to retrieve userHash")
            isLoading = false
            return
        }
        
        let baseURL = "\(AppConfig.baseURL)/recipes"
        guard let url = URL(string: "\(baseURL)?userHash=\(userHash)") else {
            print("DEBUG - Invalid URL")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("DEBUG - Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("DEBUG - No data received")
                    return
                }
                
                do {
                    let fetchedRecipes = try JSONDecoder().decode([Recipe].self, from: data)
                    self.recipes = fetchedRecipes
                } catch {
                    print("DEBUG - Decoding error: \(error.localizedDescription)")
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("DEBUG - Received data: \(dataString)")
                    }
                }
            }
        }.resume()
    }
}

// Separate view for recipe row
struct RecipeRowView: View {
    let recipe: Recipe
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: "bookmark.fill")
                .foregroundColor(.mhaPurple)
                .padding(.leading)
            
            Text(recipe.name)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .padding(.trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 15)
        .background(colorScheme == .dark ? Color.mhaGray : .white)
        .cornerRadius(15)
        .shadow(radius: 0.2)
    }
}

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(recipe.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Text(recipe.content)
                        .font(.body)
                        .lineSpacing(1.5)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct RecipesView_Previews: PreviewProvider {
    static var previews: some View {
        RecipesView()
    }
}
