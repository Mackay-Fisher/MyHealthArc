
//
//  NutritionView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.

import SwiftUI
import SwiftKeychainWrapper
import Foundation

var globalSelectedMealId: String?

// MARK: - Models
struct Meal: Identifiable {
    let id: String
    let name: String
    let totalProtein: Macro
    let totalCarbs: Macro
    let totalFats: Macro
    let totalCalories: Macro
}

struct Macro {
    let name: String
    let value: String
}

struct Nutrition: Codable {
    let id: String?
    let userHash: String
    let foodName: String
    let proteinMinimum: Double
    let proteinMaximum: Double
    let carbohydratesMinimum: Double
    let carbohydratesMaximum: Double
    let fatsMinimum: Double
    let fatsMaximum: Double
    let caloriesMinimum: Int
    let caloriesMaximum: Int
    let modifiedProtein: Double
    let modifiedCarbohydrates: Double
    let modifiedFats: Double
    let modifiedCalories: Int
}

struct MacroRange: Codable {
    let minimum: Double
    let maximum: Double
}

struct MacroRangeResponse: Codable {
    let protein: MacroRange
    let carbohydrates: MacroRange
    let fats: MacroRange
    let calories: MacroRange
}

// MARK: - Main View
struct NutritionView: View {
    @State private var mealInput: String = ""
    @State private var meals: [Meal] = []
    @State private var foodSearch: String = ""
    @State private var foodInfo: String = ""
    @State private var showFoodInfo: Bool = false
    @State private var totalNutrition: String = ""
    @State private var showPopup: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var mealId: String? = ""
    @State private var selectedMeal: Meal?
    @State private var showForm: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Main Content
            VStack {
                // Header
                HStack {
                    Image("carrot")
                        .resizable()
                        .scaledToFit()
                        .padding(-2)
                        .frame(width: 30)
                    Text("Meal Tracking")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                Divider()
                
                Spacer().frame(height: 10)
                
                // Add Meal Button
                ZStack(alignment: .topTrailing) {
                    HStack {
                        Spacer()
                        Text("Your Meals")
                            .font(.title2)
                            .padding(.top)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Button(action: { showPopup = true }) {
                        Image(systemName: "plus.circle")
                            .font(.title)
                            .padding(12)
                            .foregroundColor(Color.mhaPurple)
                    }
                }
                
                Spacer().frame(height: 2)
                
                // Calendar View
                calendarView
                
                // Meals List
                List(meals, id: \.id) { meal in
                    Button(action: {
                        selectedMeal = meal
                        globalSelectedMealId = meal.id
                        showForm = true
                    }) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(meal.name)
                                    .font(.headline)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Spacer()
                                Image("pencil")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(6)
                                    .frame(width: 30)
                            }
                            .padding(.bottom, 2)
                            
                            HStack(spacing: 10) {
                                ForEach([meal.totalProtein, meal.totalCarbs, meal.totalFats, meal.totalCalories], id: \.name) { macro in
                                    VStack(spacing: 8) {
                                        Text(macro.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(colorForMacro(macro.name))
                                        
                                        ZStack {
                                            Circle()
                                                .stroke(colorForMacro(macro.name), lineWidth: 2)
                                                .frame(width: 65, height: 65)
                                            
                                            Text(macro.value)
                                                .font(.footnote)
                                                .fontWeight(.medium)
                                                .foregroundColor(colorForMacro(macro.name))
                                        }
                                        
                                        if(macro.name == "Calories:") {
                                            Text("kcal")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(Color.mhaGreen)
                                        }
                                        else {
                                            Text("g")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(colorForMacro(macro.name))
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .blur(radius: showFoodInfo ? 8 : 0)
            .overlay(
                Rectangle()
                    .fill(Color.black.opacity(showFoodInfo ? 0.3 : 0))
                    .allowsHitTesting(showFoodInfo)
            )
            
            // Search Bar and Results Overlay
            VStack {
                Spacer()
                
                // Search Bar
                VStack {
                    HStack {
                        TextField("Search for food", text: $foodSearch)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .cornerRadius(20)
                        Button(action: fetchFoodInfo) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.mhaPurple)
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    
                    // Search Results
                    if showFoodInfo {
                        VStack(alignment: .leading, spacing: 15) {
                            let items = foodInfo.split(separator: " - ", maxSplits: 1)
                            if items.count == 2 {
                                Text(String(items[0]).capitalized)
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                
                                let nutrients = String(items[1]).components(separatedBy: ", ")
                                ForEach(nutrients, id: \.self) { nutrient in
                                    let parts = nutrient.split(separator: ":")
                                    if parts.count == 2 {
                                        let name = String(parts[0]) + ":"
                                        let values = String(parts[1]).trimmingCharacters(in: .whitespaces)
                                        
                                        HStack(spacing: 10) {
                                            Circle()
                                                .fill(colorForMacro(name))
                                                .frame(width: 8, height: 8)
                                            
                                            Text(name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .frame(width: 80, alignment: .leading)
                                            
                                            Text(values)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            if name == "Calories:" {
                                                Text("kcal")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            } else {
                                                Text("g")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    foodSearch = ""
                                    foodInfo = ""
                                    showFoodInfo = false
                                }) {
                                    Text("Clear")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color.mhaSalmon)
                                        .cornerRadius(20)
                                }
                                .padding(.top, 10)
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .padding()
                        //.background(colorScheme == .dark ? Color.mhaGray : Color.white)
                        .cornerRadius(12)
                        //.shadow(radius: 5)
                        .padding(.horizontal)
                    }
                }
                //.background(colorScheme == .dark ? Color.mhaGray: Color.white)
                .cornerRadius(12)
                //.shadow(radius: showFoodInfo ? 2 : 0)
            }
        }
        .sheet(item: $selectedMeal) { meal in
            EditMeal(meal: meal) {
                fetchMealsForDay(date: selectedDate)
            }
        }
        .overlay(addMealPopup)
        .onAppear {
            fetchMealsForDay(date: selectedDate)
        }
    }
    
    // MARK: - Helper Functions
    private func colorForMacro(_ macroName: String) -> Color {
        switch macroName {
        case "Protein:":
            return Color.mhaBlue
        case "Carbs:":
            return Color.mhaOrange
        case "Fats:":
            return Color.mhaSalmon
        case "Calories:":
            return Color.mhaGreen
        default:
            return Color.gray.opacity(0.8)
        }
    }
    
    // MARK: - Calendar View
    private var calendarView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(getCurrentWeek(), id: \.self) { date in
                    VStack {
                        Text(date, formatter: DateFormatter.dayOfWeekFormatter)
                            .font(.subheadline)
                        Text(date, formatter: DateFormatter.dayFormatter)
                            .font(.title3)
                            .fontWeight(isSelectedDate(date) ? .bold : .regular)
                            .foregroundColor(isSelectedDate(date) ? Color.mhaGreen : .primary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(isSelectedDate(date) ? Color.mhaPurple.opacity(0.2) : Color.clear)
                    )
                    .onTapGesture {
                        selectedDate = Calendar.current.startOfDay(for: date)
                        fetchMealsForDay(date: selectedDate)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func isSelectedDate(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    private func getCurrentWeek() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: today)?.start ?? today
        return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: startOfWeek)! }
    }
    
    // MARK: - Add Meal Popup
    private var addMealPopup: some View {
        Group {
            if showPopup {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture { showPopup = false }
                    
                    VStack(spacing: 20) {
                        TextField("Enter Meal (comma-separated)", text: $mealInput)
                            .padding(10)
                            .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(colorScheme == .dark ? Color.white : Color.gray, lineWidth: 0.5)
                            )
                        
                        HStack(spacing: 20) {
                            Button("Add Meal") {
                                addMeal()
                                showPopup = false
                            }
                            .frame(width: 120, height: 40)
                            .background(Color.mhaGreen)
                            .cornerRadius(20)
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                            
                            Button("Cancel") {
                                showPopup = false
                            }
                            .padding()
                            .frame(width: 120, height: 40)
                            .background(Color.mhaSalmon)
                            .cornerRadius(20)
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                        }
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color.darkGray : Color.white)
                    .cornerRadius(16)
                    .frame(width: 350)
                    .shadow(radius: 2)
                }
            }
        }
    }
    //MARK: - Search Bar
    private var searchBar: some View {
        VStack {
            // Search Bar
            HStack {
                TextField("Search for food", text: $foodSearch)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(20)
                Button(action: fetchFoodInfo) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.mhaPurple)
                        .clipShape(Circle())
                }
            }
            .padding()
            
            
            // Search Results
            if showFoodInfo {
                VStack(alignment: .leading, spacing: 15) {
                    // Food Name (first part before the first " - ")
                    let items = foodInfo.split(separator: " - ", maxSplits: 1)
                    if items.count == 2 {
                        Text(String(items[0]).capitalized)
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        // Nutrients info
                        let nutrients = String(items[1]).components(separatedBy: ", ")
                        ForEach(nutrients, id: \.self) { nutrient in
                            let parts = nutrient.split(separator: ":")
                            if parts.count == 2 {
                                let name = String(parts[0]) + ":"
                                let values = String(parts[1]).trimmingCharacters(in: .whitespaces)
                                
                                HStack(spacing: 10) {
                                    Circle()
                                        .fill(colorForMacro(name))
                                        .frame(width: 8, height: 8)
                                    
                                    Text(name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .frame(width: 80, alignment: .leading)
                                    
                                    Text(values)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    if name == "Calories:" {
                                        Text("kcal")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("g")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        
                        // Clear Button
                        Button(action: {
                            foodSearch = ""
                            foodInfo = ""
                            showFoodInfo = false
                        }) {
                            Text("Clear")
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.mhaSalmon)
                                .cornerRadius(20)
                        }
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    // MARK: - Helper Functions
    
    private func generateRandomID(length: Int = 16) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    // MARK: - Networking Functions
    private func addMeal() {
            guard !mealInput.isEmpty else { return }

            // Split the meal input into individual food items
            let foodItems = mealInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            let mealName = mealInput  // Keep the original meal input
            mealInput = ""  // Clear the input

            // Fetch nutrition info for the food items
            fetchNutritionInfo(for: foodItems, mealName: mealName)
        }
    
    private static let apiDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter
        }()
        
    private func fetchMealsForDay(date: Date) {
        let baseURL = "\(AppConfig.baseURL)/nutrition/meals"
        let dateString = ISO8601DateFormatter().string(from: date)
        
        guard let userHash = KeychainWrapper.standard.string(forKey: "userHash"),
            let url = URL(string: "\(baseURL)?userHash=\(userHash)&date=\(dateString)") else {
            print("DEBUG - Failed to create URL with userHash or date")
            return
        }
        
        print("DEBUG - Fetching meals for date: \(dateString)")
        print("DEBUG - Using URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("DEBUG - Error fetching meals: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("DEBUG - Response status code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("DEBUG - No data received")
                return
            }
            
            do {
                let nutritions = try JSONDecoder().decode([Nutrition].self, from: data)
                print("DEBUG - Received \(nutritions.count) meals from server")
                
                DispatchQueue.main.async {
                    self.meals = nutritions.map { nutrition in
                        print("DEBUG - Processing meal: \(nutrition.foodName)")
                        
                        // Format protein values
                        let proteinValue = nutrition.modifiedProtein != nutrition.proteinMinimum ?
                            String(format: "%.1f", nutrition.modifiedProtein) :
                            String(format: "%.1f-%.1f", nutrition.proteinMinimum, nutrition.proteinMaximum)
                        
                        // Format carbs values
                        let carbsValue = nutrition.modifiedCarbohydrates != nutrition.carbohydratesMinimum ?
                            String(format: "%.1f", nutrition.modifiedCarbohydrates) :
                            String(format: "%.1f-%.1f", nutrition.carbohydratesMinimum, nutrition.carbohydratesMaximum)
                        
                        // Format fats values
                        let fatsValue = nutrition.modifiedFats != nutrition.fatsMinimum ?
                            String(format: "%.1f", nutrition.modifiedFats) :
                            String(format: "%.1f-%.1f", nutrition.fatsMinimum, nutrition.fatsMaximum)
                        
                        // Format calories values
                        let caloriesValue = nutrition.modifiedCalories != nutrition.caloriesMinimum ?
                            String(nutrition.modifiedCalories) :
                            "\(nutrition.caloriesMinimum)-\(nutrition.caloriesMaximum)"
                        
                        print("DEBUG - Formatted values:")
                        print("Protein: \(proteinValue)")
                        print("Carbs: \(carbsValue)")
                        print("Fats: \(fatsValue)")
                        print("Calories: \(caloriesValue)")
                        
                        return Meal(
                            id: nutrition.id ?? generateRandomID(),
                            name: nutrition.foodName,
                            totalProtein: Macro(name: "Protein:", value: "\(proteinValue)"),
                            totalCarbs: Macro(name: "Carbs:", value: "\(carbsValue)"),
                            totalFats: Macro(name: "Fats:", value: "\(fatsValue)"),
                            totalCalories: Macro(name: "Calories:", value: "\(caloriesValue)")
                        )
                    }
                    print("DEBUG - Updated meals array with \(self.meals.count) items")
                }
            } catch {
                print("DEBUG - Decoding error: \(error)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("DEBUG - Raw response: \(responseString)")
                }
            }
        }.resume()
    }
    
    // Fetch Nutrition Info for the Meal
        private func fetchNutritionInfo(for foodItems: [String], mealName: String) {
            guard !foodItems.isEmpty else { return }

            let baseURL = "\(AppConfig.baseURL)/nutrition/info"
            let query = foodItems.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            guard let url = URL(string: "\(baseURL)?query=\(query)") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        totalNutrition = "Error: \(error.localizedDescription)"
                        showFoodInfo = true
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        totalNutrition = "No data received."
                        showFoodInfo = true
                    }
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Double]] {
                        var totalProteinMin = 0.0
                        var totalProteinMax = 0.0
                        var totalCarbsMin = 0.0
                        var totalCarbsMax = 0.0
                        var totalFatsMin = 0.0
                        var totalFatsMax = 0.0
                        var totalCaloriesMin = 0
                        var totalCaloriesMax = 0

                        for (_, nutrients) in json {
                            totalProteinMin += nutrients["proteinMinimum"] ?? 0
                            totalProteinMax += nutrients["proteinMaximum"] ?? 0
                            totalCarbsMin += nutrients["carbohydratesMinimum"] ?? 0
                            totalCarbsMax += nutrients["carbohydratesMaximum"] ?? 0
                            totalFatsMin += nutrients["fatsMinimum"] ?? 0
                            totalFatsMax += nutrients["fatsMaximum"] ?? 0
                            totalCaloriesMin += Int(nutrients["caloriesMinimum"] ?? 0)
                            totalCaloriesMax += Int(nutrients["caloriesMaximum"] ?? 0)
                        }

                        let proteinRange = Macro(name: "Protein:", value: "\(totalProteinMin) - \(totalProteinMax)")
                        let carbsRange = Macro(name: "Carbs:", value: "\(totalCarbsMin) - \(totalCarbsMax)")
                        let fatsRange = Macro(name: "Fats:", value: "\(totalFatsMin) - \(totalFatsMax)")
                        let caloriesRange = Macro(name: "Calories:", value: "\(totalCaloriesMin) - \(totalCaloriesMax)")

                        DispatchQueue.main.async {
                            totalNutrition = """
                            Protein: \(totalProteinMin) - \(totalProteinMax), \
                            Carbs: \(totalCarbsMin) - \(totalCarbsMax), \
                            Fats: \(totalFatsMin) - \(totalFatsMax), \
                            Calories: \(totalCaloriesMin) - \(totalCaloriesMax)
                            """
                            meals.append(Meal(id: generateRandomID(), name: mealName, totalProtein: proteinRange, totalCarbs: carbsRange, totalFats: fatsRange, totalCalories: caloriesRange))

                            createNutritionObject(mealName: mealName, proteinMin: totalProteinMin, proteinMax: totalProteinMax, carbsMin: totalCarbsMin, carbsMax: totalCarbsMax, fatsMin: totalFatsMin, fatsMax: totalFatsMax, caloriesMin: totalCaloriesMin, caloriesMax: totalCaloriesMax)
                        }
                    } else {
                        DispatchQueue.main.async {
                            totalNutrition = "Failed to parse response."
                            showFoodInfo = true
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        totalNutrition = "Decoding error: \(error.localizedDescription)"
                        showFoodInfo = true
                    }
                }
            }.resume()
        }
    
    private func createNutritionObject(mealName: String, proteinMin: Double, proteinMax: Double,
                                         carbsMin: Double, carbsMax: Double, fatsMin: Double, fatsMax: Double,
                                         caloriesMin: Int, caloriesMax: Int) {
            let baseURL = "\(AppConfig.baseURL)/nutrition/create"
            guard let url = URL(string: baseURL) else {
                print("Invalid URL")
                return
            }
            
            guard let userHash = KeychainWrapper.standard.string(forKey: "userHash") else {
                print("Failed to retrieve userHash from Keychain")
                return
            }
            
            // Format the date for the create request
            let dateString = NutritionView.apiDateFormatter.string(from: selectedDate)
            
            let nutrition = Nutrition(
                id: nil,
                userHash: userHash,
                foodName: mealName,
                proteinMinimum: proteinMin,
                proteinMaximum: proteinMax,
                carbohydratesMinimum: carbsMin,
                carbohydratesMaximum: carbsMax,
                fatsMinimum: fatsMin,
                fatsMaximum: fatsMax,
                caloriesMinimum: caloriesMin,
                caloriesMaximum: caloriesMax,
                modifiedProtein: proteinMin,
                modifiedCarbohydrates: carbsMin,
                modifiedFats: fatsMin,
                modifiedCalories: caloriesMin
            )
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let jsonData = try JSONEncoder().encode(nutrition)
                request.httpBody = jsonData
                print("Creating nutrition object for date: \(dateString)")  // Debug print
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Create response status: \(httpResponse.statusCode)")
                        if httpResponse.statusCode == 201 {
                            DispatchQueue.main.async {
                                fetchMealsForDay(date: selectedDate)
                            }
                            print("Nutrition object created successfully")
                        } else {
                            print("Failed to create nutrition object")
                        }
                    }
                }.resume()
            } catch {
                print("Encoding error: \(error.localizedDescription)")
            }
        }

        private func fetchFoodInfo() {
            guard !foodSearch.isEmpty else { return }

            let baseURL = "\(AppConfig.baseURL)/nutrition/info"
            let query = foodSearch.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            guard let url = URL(string: "\(baseURL)?query=\(query)") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        foodInfo = "Error: \(error.localizedDescription)"
                        showFoodInfo = true
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        foodInfo = "No data received."
                        showFoodInfo = true
                    }
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Double]] {
                        if let firstFoodItem = json.first {
                            let foodItem = firstFoodItem.key
                            let nutrients = firstFoodItem.value
                            foodInfo = """
                            \(foodItem.capitalized) - Protein: \(nutrients["proteinMinimum"] ?? 0)g - \(nutrients["proteinMaximum"] ?? 0), \
                            Carbs: \(nutrients["carbohydratesMinimum"] ?? 0) - \(nutrients["carbohydratesMaximum"] ?? 0), \
                            Fats: \(nutrients["fatsMinimum"] ?? 0) - \(nutrients["fatsMaximum"] ?? 0), \
                            Calories: \(nutrients["caloriesMinimum"] ?? 0) - \(nutrients["caloriesMaximum"] ?? 0)
                            """
                        } else {
                            foodInfo = "No information found."
                        }
                    } else {
                        foodInfo = "Failed to parse response."
                    }
                } catch {
                    foodInfo = "Decoding error: \(error.localizedDescription)"
                }

                DispatchQueue.main.async {
                    showFoodInfo = true
                }
            }.resume()
        }
}

// MARK: - Edit Meal View
struct EditMeal: View {
    let meal: Meal
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fats: String = ""
    @State private var calories: String = ""

    @State private var minProtein: Double?
    @State private var maxProtein: Double?
    @State private var minCarbs: Double?
    @State private var maxCarbs: Double?
    @State private var minFats: Double?
    @State private var maxFats: Double?
    @State private var minCalories: Double?
    @State private var maxCalories: Double?
    
    init(meal: Meal, onSave: @escaping () -> Void) {
        print("DEBUG - Raw Meal Values:")
        print("Protein: \(meal.totalProtein.value)")
        print("Carbs: \(meal.totalCarbs.value)")
        print("Fats: \(meal.totalFats.value)")
        print("Calories: \(meal.totalCalories.value)")
        
        self.meal = meal
        self.onSave = onSave
        
        // Extract the first number from each value string
        let proteinValue = EditMeal.extractFirstNumber(from: meal.totalProtein.value)
        let carbsValue = EditMeal.extractFirstNumber(from: meal.totalCarbs.value)
        let fatsValue = EditMeal.extractFirstNumber(from: meal.totalFats.value)
        let caloriesValue = EditMeal.extractFirstNumber(from: meal.totalCalories.value)

        _protein = State(initialValue: proteinValue)
        _carbs = State(initialValue: carbsValue)
        _fats = State(initialValue: fatsValue)
        _calories = State(initialValue: caloriesValue)
        
        print("DEBUG - Extracted Values:")
        print("Protein: \(proteinValue)")
        print("Carbs: \(carbsValue)")
        print("Fats: \(fatsValue)")
        print("Calories: \(caloriesValue)")
        
        // Initialize State properties
        _protein = State(initialValue: proteinValue)
        _carbs = State(initialValue: carbsValue)
        _fats = State(initialValue: fatsValue)
        _calories = State(initialValue: caloriesValue)
    }
    
    // Helper function to extract the first number from a string
    private static func extractFirstNumber(from string: String) -> String {
        if let firstNumber = string.split(whereSeparator: { !$0.isNumber && $0 != "." })
            .first(where: { Double($0) != nil }) {
            return String(firstNumber)
        }
        return ""
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Your Form with sections
                Form {
                    Section(header: Text("Current Values")) {
                        Text("Protein: \(meal.totalProtein.value)")
                        Text("Carbs: \(meal.totalCarbs.value)")
                        Text("Fats: \(meal.totalFats.value)")
                        Text("Calories: \(meal.totalCalories.value)")
                    }
                    
                    Section(header: Text("Edit Meal Nutrition")) {
                        VStack(alignment: .leading) {
                            if let minProtein = minProtein, let maxProtein = maxProtein {
                                VStack {
                                    Text("Protein")                                         .font(.headline)
                                        .padding(.bottom, 5)

                                    HStack {
                                        Text("\(minProtein, specifier: "%.1f")g")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        Slider(value: Binding(
                                            get: { Double(protein) ?? 0 },
                                            set: { protein = String(format: "%.1f", $0) }
                                        ), in: minProtein...maxProtein, step: 0.1)
                                        .accentColor(.blue)

                                        Text("\(maxProtein, specifier: "%.1f")g")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    Text("\(protein) g")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 5)
                                }
                                .padding(.vertical)
                            }
                        }

                        VStack(alignment: .leading) {
                            if let minCarbs = minCarbs, let maxCarbs = maxCarbs {
                                VStack {
                                    Text("Carbs")
                                        .font(.headline)
                                        .padding(.bottom, 5)

                                    HStack {
                                        Text("\(minCarbs, specifier: "%.1f")g")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        Slider(value: Binding(
                                            get: { Double(carbs) ?? 0 },
                                            set: { carbs = String(format: "%.1f", $0) }
                                        ), in: minCarbs...maxCarbs, step: 0.1)
                                        .accentColor(.orange)

                                        Text("\(maxCarbs, specifier: "%.1f")g")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    Text("\(carbs) g")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 5)
                                }
                                .padding(.vertical)
                            }
                        }

                        VStack(alignment: .leading) {
                            if let minFats = minFats, let maxFats = maxFats {
                                VStack {
                                    Text("Fats")
                                        .font(.headline)
                                        .padding(.bottom, 5)

                                    HStack {
                                        Text("\(minFats, specifier: "%.1f")g")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        Slider(value: Binding(
                                            get: { Double(fats) ?? 0 },
                                            set: { fats = String(format: "%.1f", $0) }
                                        ), in: minFats...maxFats, step: 0.1)
                                        .accentColor(.red)

                                        Text("\(maxFats, specifier: "%.1f")g")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    Text("\(fats) g")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 5)
                                }
                                .padding(.vertical)
                            }
                        }

                        VStack(alignment: .leading) {
                            if let minCalories = minCalories, let maxCalories = maxCalories {
                                VStack {
                                    Text("Calories")
                                        .font(.headline)
                                        .padding(.bottom, 5)

                                    HStack {
                                        Text("\(minCalories, specifier: "%.0f") kcal")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        Slider(value: Binding(
                                            get: { Double(calories) ?? 0 },
                                            set: { calories = String(format: "%.0f", $0) }
                                        ), in: minCalories...maxCalories, step: 1)
                                        .accentColor(Color.mhaGreen)

                                        Text("\(maxCalories, specifier: "%.0f") kcal")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    Text("\(calories) kcal")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 5)
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                }


                Button(action: {
                    print("DEBUG - Saving values:")
                    print("Protein: \(protein)")
                    print("Carbs: \(carbs)")
                    print("Fats: \(fats)")
                    print("Calories: \(calories)")
                    updateNutrition()
                }) {
                    Text("Save")
                        .frame(width: 120, height: 40)
                        .foregroundColor(.white)
                        .background(Color.mhaGreen)
                        .cornerRadius(20)
                        .padding(.bottom)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
            }
            .navigationTitle("Edit \(meal.name)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                fetchMacroRanges()
            }
        }
    }
    
    private func fetchMacroRanges() {
        guard let mealId = globalSelectedMealId else {
            print("DEBUG - Missing mealId")
            return
        }
        
        let baseURL = "\(AppConfig.baseURL)/nutrition/macroRanges"
        guard let url = URL(string: "\(baseURL)/\(mealId)") else {
            print("DEBUG - Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("DEBUG - Error fetching macro ranges: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("DEBUG - No data received")
                return
            }
            
            do {
                let macroRanges = try JSONDecoder().decode(MacroRangeResponse.self, from: data)
                DispatchQueue.main.async {
                    self.minProtein = macroRanges.protein.minimum
                    self.maxProtein = macroRanges.protein.maximum
                    self.minCarbs = macroRanges.carbohydrates.minimum
                    self.maxCarbs = macroRanges.carbohydrates.maximum
                    self.minFats = macroRanges.fats.minimum
                    self.maxFats = macroRanges.fats.maximum
                    self.minCalories = macroRanges.calories.minimum
                    self.maxCalories = macroRanges.calories.maximum
                }
            } catch {
                print("DEBUG - Decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func updateNutrition() {
        guard let mealId = globalSelectedMealId,
              let userHash = KeychainWrapper.standard.string(forKey: "userHash") else {
            print("DEBUG - Missing mealId or userHash")
            return
        }
        
        print("DEBUG - Updating meal with ID: \(mealId)")
        
        let baseURL = "\(AppConfig.baseURL)/nutrition/update"
        guard let url = URL(string: "\(baseURL)/\(mealId)") else {
            print("DEBUG - Invalid URL")
            return
        }
        
        var updatedFields: [String: Any] = ["userHash": userHash]
        
        if !protein.isEmpty {
            updatedFields["modifiedProtein"] = Double(protein) ?? 0.0
        }
        if !carbs.isEmpty {
            updatedFields["modifiedCarbohydrates"] = Double(carbs) ?? 0.0
        }
        if !fats.isEmpty {
            updatedFields["modifiedFats"] = Double(fats) ?? 0.0
        }
        if !calories.isEmpty {
            updatedFields["modifiedCalories"] = Int(calories) ?? 0
        }
        
        print("DEBUG - Sending update with fields: \(updatedFields)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: updatedFields)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("DEBUG - Error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("DEBUG - Response status: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        DispatchQueue.main.async {
                            onSave()
                            dismiss()
                        }
                    }
                }
            }.resume()
        } catch {
            print("DEBUG - Encoding error: \(error)")
        }
    }
}

// MARK: - Date Formatter Extensions
extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
}

// MARK: - Preview Provider
struct NutritionView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionView()
    }
}
