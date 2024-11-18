import SwiftUI
import SwiftKeychainWrapper
import Foundation

var globalSelectedMealId: String?

// MARK: - Models
struct Meal {
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
        VStack {
            // Header
            HStack {
                Image("carrot")
                    .resizable()
                    .scaledToFit()
                    .padding(-2)
                    .frame(width: 30)
                Text("Nutrition Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
            }
            
            Divider()
                .overlay(colorScheme == .dark ? Color.white : Color.gray)
            
            Spacer().frame(height: 20)
            
            // Add Meal Button
            ZStack(alignment: .topTrailing) {
                HStack {
                    Spacer()
                    Text("Your Meals")
                        .font(.title3)
                        .padding(.top)
                    Spacer()
                }
                .padding(.horizontal)
                
                Button(action: { showPopup = true }) {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .padding(12)
                }
            }
            
            Spacer().frame(height: 20)
            
            // Calendar View
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(getCurrentWeek(), id: \.self) { date in
                        VStack {
                            Text(date, formatter: DateFormatter.dayOfWeekFormatter)
                                .font(.subheadline)
                            Text(date, formatter: DateFormatter.dayFormatter)
                                .font(.title3)
                                .fontWeight(Calendar.current.isDateInToday(date) ? .bold : .regular)
                                .foregroundColor(Calendar.current.isDateInToday(date) ? .blue : .primary)
                        }
                        .padding()
                        .background(Calendar.current.isDateInToday(date) ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(10)
                        .onTapGesture {
                            selectedDate = date
                            fetchMealsForDay(date: selectedDate)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Meals List
            List(meals, id: \.id) { meal in
                VStack(alignment: .leading) {
                    HStack {
                        Text(meal.name)
                            .font(.headline)
                        Spacer()
                        Button("Edit") {
                            selectedMeal = meal
                            globalSelectedMealId = meal.id
                            showForm = true
                        }
                    }
                    .padding(.bottom, 2)
                    
                    ForEach([meal.totalProtein, meal.totalCarbs, meal.totalFats, meal.totalCalories], id: \.name) { macro in
                        HStack {
                            Text(macro.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(macro.value)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 5)
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            // Search Bar
            HStack {
                TextField("Search for food", text: $foodSearch)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: fetchFoodInfo) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()
            
            if showFoodInfo {
                VStack(alignment: .leading) {
                    Text(foodInfo)
                        .font(.headline)
                    Button("Clear") {
                        foodSearch = ""
                        foodInfo = ""
                        showFoodInfo = false
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
        .padding()
        .sheet(isPresented: $showForm) {
            if let meal = selectedMeal {
                EditMeal(meal: meal) {
                    fetchMealsForDay(date: selectedDate)
                }
            }
        }
        .overlay(addMealPopup)
        .onAppear {
            fetchMealsForDay(date: selectedDate)
        }
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
                        TextField("Enter meal (comma-separated)", text: $mealInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        HStack(spacing: 20) {
                            Button("Add Meal") {
                                addMeal()
                                showPopup = false
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            Button("Cancel") {
                                showPopup = false
                            }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    // Generate current week dates centered around today
            private func getCurrentWeek() -> [Date] {
                let calendar = Calendar.current
                let today = Date()
                let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: today)?.start ?? today
                return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: startOfWeek)! }
            }
    
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
    
    private func fetchMealsForDay(date: Date) {
            let baseURL = "http://localhost:8080/nutrition/meals"
            let dateString = ISO8601DateFormatter().string(from: date)

            guard let userHash = KeychainWrapper.standard.string(forKey: "userHash") else {
                print("Failed to retrieve userHash from Keychain")
                return
            }

            guard let url = URL(string: "\(baseURL)?userHash=\(userHash)&date=\(dateString)") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error fetching meals: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data received.")
                    return
                }

                do {
                    let meals = try JSONDecoder().decode([Nutrition].self, from: data)
                    DispatchQueue.main.async {
                        self.meals = meals.map { meal in
                            let proteinValue = meal.modifiedProtein >= 0 ? meal.modifiedProtein : (meal.proteinMinimum + meal.proteinMaximum) / 2
                            let carbsValue = meal.modifiedCarbohydrates >= 0 ? meal.modifiedCarbohydrates : (meal.carbohydratesMinimum + meal.carbohydratesMaximum) / 2
                            let fatsValue = meal.modifiedFats >= 0 ? meal.modifiedFats : (meal.fatsMinimum + meal.fatsMaximum) / 2
                            let caloriesValue = meal.modifiedCalories >= 0 ? meal.modifiedCalories : (meal.caloriesMinimum + meal.caloriesMaximum) / 2

                            let proteinRange = Macro(name: "Protein:", value: meal.modifiedProtein >= 0 ? "\(meal.modifiedProtein)g" : "\(meal.proteinMinimum)g - \(meal.proteinMaximum)g")
                            let carbsRange = Macro(name: "Carbs:", value: meal.modifiedCarbohydrates >= 0 ? "\(meal.modifiedCarbohydrates)g" : "\(meal.carbohydratesMinimum)g - \(meal.carbohydratesMaximum)g")
                            let fatsRange = Macro(name: "Fats:", value: meal.modifiedFats >= 0 ? "\(meal.modifiedFats)g" : "\(meal.fatsMinimum)g - \(meal.fatsMaximum)g")
                            let caloriesRange = Macro(name: "Calories:", value: meal.modifiedCalories >= 0 ? "\(meal.modifiedCalories)kcal" : "\(meal.caloriesMinimum)kcal - \(meal.caloriesMaximum)kcal")
                            print("Meal ID: \(meal.id!)")
                            return Meal(id: meal.id!, name: meal.foodName, totalProtein: proteinRange, totalCarbs: carbsRange, totalFats: fatsRange, totalCalories: caloriesRange)
                        }
                    }
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                }
            }.resume()
        }

    
    // Fetch Nutrition Info for the Meal
        private func fetchNutritionInfo(for foodItems: [String], mealName: String) {
            guard !foodItems.isEmpty else { return }

            let baseURL = "http://localhost:8080/nutrition/info"
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

                        let proteinRange = Macro(name: "Protein:", value: "\(totalProteinMin)g - \(totalProteinMax)g")
                        let carbsRange = Macro(name: "Carbs:", value: "\(totalCarbsMin)g - \(totalCarbsMax)g")
                        let fatsRange = Macro(name: "Fats:", value: "\(totalFatsMin)g - \(totalFatsMax)g")
                        let caloriesRange = Macro(name: "Calories:", value: "\(totalCaloriesMin)kcal - \(totalCaloriesMax)kcal")

                        DispatchQueue.main.async {
                            totalNutrition = """
                            Protein: \(totalProteinMin)g - \(totalProteinMax)g, \
                            Carbs: \(totalCarbsMin)g - \(totalCarbsMax)g, \
                            Fats: \(totalFatsMin)g - \(totalFatsMax)g, \
                            Calories: \(totalCaloriesMin)kcal - \(totalCaloriesMax)kcal
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
    
    private func createNutritionObject(mealName: String, proteinMin: Double, proteinMax: Double, carbsMin: Double, carbsMax: Double, fatsMin: Double, fatsMax: Double, caloriesMin: Int, caloriesMax: Int) {
            let baseURL = "http://localhost:8080/nutrition/create"
            guard let url = URL(string: baseURL) else {
                print("Invalid URL")
                return
            }

            guard let userHash = KeychainWrapper.standard.string(forKey: "userHash") else {
                print("Failed to retrieve userHash from Keychain")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
                modifiedProtein: -1.0,
                modifiedCarbohydrates: -1.0,
                modifiedFats: -1.0,
                modifiedCalories: -1
            )

            do {
                let jsonData = try JSONEncoder().encode(nutrition)
                request.httpBody = jsonData

                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }

                    guard let data = data else {
                        print("No data received.")
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                        print("Nutrition object created successfully.")
                        if let createdNutrition = try? JSONDecoder().decode(Nutrition.self, from: data) {
                            DispatchQueue.main.async {
                                self.mealId = createdNutrition.id
                            }
                        }
                    } else {
                        print("Failed to create nutrition object.")
                    }
                }.resume()
            } catch {
                print("Encoding error: \(error.localizedDescription)")
            }
        }

        private func fetchFoodInfo() {
            guard !foodSearch.isEmpty else { return }

            let baseURL = "http://localhost:8080/nutrition/info"
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
                            \(foodItem.capitalized) - Protein: \(nutrients["proteinMinimum"] ?? 0)g - \(nutrients["proteinMaximum"] ?? 0)g, \
                            Carbs: \(nutrients["carbohydratesMinimum"] ?? 0)g - \(nutrients["carbohydratesMaximum"] ?? 0)g, \
                            Fats: \(nutrients["fatsMinimum"] ?? 0)g - \(nutrients["fatsMaximum"] ?? 0)g, \
                            Calories: \(nutrients["caloriesMinimum"] ?? 0)kcal - \(nutrients["caloriesMaximum"] ?? 0)kcal
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
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Meal Nutrition")) {
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.decimalPad)
                    TextField("Carbs (g)", text: $carbs)
                        .keyboardType(.decimalPad)
                    TextField("Fats (g)", text: $fats)
                        .keyboardType(.decimalPad)
                    TextField("Calories", text: $calories)
                        .keyboardType(.decimalPad)
                }
                
                Button("Save Changes") {
                    updateNutrition()
                }
            }
            .navigationTitle("Edit \(meal.name)")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func updateNutrition() {
        guard let mealId = globalSelectedMealId,
              let userHash = KeychainWrapper.standard.string(forKey: "userHash") else {
            return
        }
        
        let baseURL = "http://localhost:8080/nutrition/update"
        guard let url = URL(string: "\(baseURL)/\(mealId)") else {
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
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: updatedFields)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        onSave()
                        dismiss()
                    }
                }
            }.resume()
        } catch {
            print("Encoding error: \(error)")
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
