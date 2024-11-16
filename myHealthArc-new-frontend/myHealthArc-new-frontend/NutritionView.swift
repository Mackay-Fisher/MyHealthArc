//
//  NutritionView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.
//


import SwiftUI
import SwiftUI
import SwiftKeychainWrapper

struct Meal {
    let name: String
    let totalProtein: Macro
    let totalCarbs: Macro
    let totalFats: Macro
    let totalCalories: Macro
}

struct Macro{
    let name: String
    let value: String
}

struct Nutrition: Codable {
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
    let modifiedProtein: Double?
    let modifiedCarbohydrates: Double?
    let modifiedFats: Double?
    let modifiedCalories: Int?
}

struct NutritionView: View {
    @State private var mealInput: String = ""
    @State private var meals: [Meal] = []
    @State private var foodSearch: String = ""
    @State private var foodInfo: String = ""
    @State private var showFoodInfo: Bool = false
    @State private var totalNutrition: String = ""
    @State private var showPopup: Bool = false
    @State private var showForm: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedDate: Date = Date() 

    @State private var editProtein: String = ""
    @State private var editCarbs: String = ""
    @State private var editFats: String = ""
    @State private var editCalories: String = ""
    @State private var proteinChanged: Bool = false
    @State private var carbsChanged: Bool = false
    @State private var fatsChanged: Bool = false
    @State private var caloriesChanged: Bool = false

    var body: some View {
        VStack {
            HStack{Image ("carrot")
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
                .overlay(
                    (colorScheme == .dark ? Color.white : Color.gray)
                )
            Spacer()
                .frame(height:20)
            
            // Meal Input Section
            ZStack(alignment: .topTrailing) {
                HStack {
                    Spacer()
                    
                    Text("Your Meals")
                        .font(.title3)
                        .padding(.top)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                Button(action: {
                    withAnimation {
                        showPopup = true
                    }
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .padding(12)
                }
            }
            .disabled(showPopup)
            //TODO: fix the nutrition search thing
            //TODO: figure out why spacing is so messed up
            Spacer()
                .frame(height:20)
            
            
            if showPopup {              
                VStack(spacing: 20) {
                    HStack {
                        TextField("Enter meal (comma-separated)", text: $mealInput)
                            .padding(5)
                            .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(colorScheme == .dark ? Color.white : Color.gray, lineWidth: 0.5)
                            )
                        
                        Button("Add Meal") {
                            addMeal()
                            withAnimation {
                                showPopup = false
                            }
                        }
                        .padding()
                        .frame(width: 120, height: 40)
                        .background(Color.green)
                        .cornerRadius(20)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }

                    Button(action: {
                        withAnimation {
                            showPopup = false
                        }
                    }) {
                        Text("Cancel")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .cornerRadius(16)
                .frame(width: 350)
                .shadow(radius: 20)
                .transition(.scale)
            }

            VStack {
                // Calendar Week View
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(getCurrentWeek(), id: \.self) { date in
                            VStack {
                                Text(date, formatter: DateFormatter.dayOfWeekFormatter)
                                    .font(.subheadline)
                                Text(date, formatter: DateFormatter.dayFormatter)
                                    .font(.title3)
                                    .fontWeight(isToday(date) ? .bold : .regular)
                                    .foregroundColor(isToday(date) ? .mhaGreen : .primary)
                            }
                            .padding()
                            .background(isToday(date) ? Color.mhaPurple.opacity(0.2) : Color.clear)
                            .cornerRadius(50)
                            .onTapGesture {
                                selectedDate = date 
                                fetchMealsForDay(date: selectedDate)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
                        
            List(meals, id: \.name) { meal in
                VStack(alignment: .leading) {
                    HStack{
                        Text(meal.name)
                            .font(.headline)
                            .padding(.bottom, 2)

                            Spacer()
                            /*
                            Button("Edit", systemImage: "pencil") {
                                showForm = true
                            }
                            .sheet(isPresented: $showForm) {
                                EditMeal(protein: $editProtein, carbs: $editCarbs, fats: $editFats, calories: $editCalories, proteinChanged: $proteinChanged, carbsChanged: $carbsChanged, fatsChanged: $fatsChanged, caloriesChanged: $caloriesChanged)
                            }*/
                    }
                    
                    // Text(meal.totalNutrition)
                    //     .font(.subheadline)
                    //     .foregroundColor(.secondary)
                    //     .padding(.bottom, 5)

                    HStack {
                        Text(meal.totalProtein.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)

                        Text(meal.totalProtein.value)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)
                    }


                    HStack {
                        Text(meal.totalCarbs.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)

                        Text(meal.totalCarbs.value)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)
                    }

                    HStack {
                        Text(meal.totalFats.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)

                        Text(meal.totalFats.value)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)
                    }

                    HStack {
                        Text(meal.totalCalories.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)

                        Text(meal.totalCalories.value)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .padding(.bottom)
            .padding(.leading, -15)
            
            Spacer()
        

            // Food Search Section
            HStack {
                
                TextField("Search for food", text: $foodSearch, onCommit: {
                    fetchFoodInfo()
                })
                .padding(5)
                .background(colorScheme == .dark ? Color.mhaGray : Color.white)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? Color.white : Color.gray, lineWidth: 0.5)
                )
                //.frame(width: 250, height: 150, alignment:.center)


                Button(action: fetchFoodInfo) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.mhaPurple)
                        .clipShape(Circle())
                }
            }
            .padding()

            // Display Food Info
            if showFoodInfo {
                VStack(alignment: .leading) {
                    Text(foodInfo)
                        .font(.headline)
                        .padding(.bottom, 2)

                    Button(action: clearSearch) {
                        Text("Clear")
                            .padding()
                            .background(Color.mhaGreen)
                            .cornerRadius(50)
                            .foregroundColor(.white)
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .center) // Center button
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            fetchMealsForDay(date: selectedDate)
        }
    }
    // Add Meal Functionality
    private func addMeal() {
        guard !mealInput.isEmpty else { return }

        // Split the meal input into individual food items
        let foodItems = mealInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let mealName = mealInput  // Keep the original meal input
        mealInput = ""  // Clear the input

        // Fetch nutrition info for the food items
        fetchNutritionInfo(for: foodItems, mealName: mealName)
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
                        meals.append(Meal(name: mealName, totalProtein: proteinRange, totalCarbs: carbsRange, totalFats: fatsRange, totalCalories: caloriesRange))

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
                        let proteinValue = meal.modifiedProtein ?? (meal.proteinMinimum + meal.proteinMaximum) / 2
                        let carbsValue = meal.modifiedCarbohydrates ?? (meal.carbohydratesMinimum + meal.carbohydratesMaximum) / 2
                        let fatsValue = meal.modifiedFats ?? (meal.fatsMinimum + meal.fatsMaximum) / 2
                        let caloriesValue = meal.modifiedCalories ?? (meal.caloriesMinimum + meal.caloriesMaximum) / 2

                        let proteinRange = Macro(name: "Protein:", value: meal.modifiedProtein != nil ? "\(meal.modifiedProtein!)g" : "\(meal.proteinMinimum)g - \(meal.proteinMaximum)g")
                        let carbsRange = Macro(name: "Carbs:", value: meal.modifiedCarbohydrates != nil ? "\(meal.modifiedCarbohydrates!)g" : "\(meal.carbohydratesMinimum)g - \(meal.carbohydratesMaximum)g")
                        let fatsRange = Macro(name: "Fats:", value: meal.modifiedFats != nil ? "\(meal.modifiedFats!)g" : "\(meal.fatsMinimum)g - \(meal.fatsMaximum)g")
                        let caloriesRange = Macro(name: "Calories:", value: meal.modifiedCalories != nil ? "\(meal.modifiedCalories!)kcal" : "\(meal.caloriesMinimum)kcal - \(meal.caloriesMaximum)kcal")

                        return Meal(name: meal.foodName, totalProtein: proteinRange, totalCarbs: carbsRange, totalFats: fatsRange, totalCalories: caloriesRange)
                    }
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
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
            modifiedProtein: nil,
            modifiedCarbohydrates: nil,
            modifiedFats: nil,
            modifiedCalories: nil
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
    

    // Clear Search Functionality
    private func clearSearch() {
        foodSearch = ""
        foodInfo = ""
        showFoodInfo = false
    }
    // Generate current week dates centered around today
        private func getCurrentWeek() -> [Date] {
            let calendar = Calendar.current
            let today = Date()
            let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: today)?.start ?? today
            return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: startOfWeek)! }
        }
        
        // Check if the date is today
        private func isToday(_ date: Date) -> Bool {
            Calendar.current.isDateInToday(date)
        }
}
// Date Formatters for day and day of week
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

struct EditMeal: View{
    @Binding var protein: String 
    @Binding var carbs: String
    @Binding var fats: String 
    @Binding var calories: String
    @Binding var proteinChanged: Bool
    @Binding var carbsChanged: Bool
    @Binding var fatsChanged: Bool
    @Binding var caloriesChanged: Bool

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var tempProtein: String = ""
    @State private var tempCarbs: String = ""
    @State private var tempFats: String = ""
    @State private var tempCalories: String = ""

    var body: some View{
        NavigationView{
            Form{
                Section(header: Text("Edit Meal Nutrition")){
                    TextField("Protein", text: $tempProtein)
                        .keyboardType(.decimalPad)
                    TextField("Carbs", text: $tempCarbs)
                        .keyboardType(.decimalPad)
                    TextField("Fats", text: $tempFats)
                        .keyboardType(.decimalPad)
                    TextField("Calories", text: $tempCalories)
                        .keyboardType(.decimalPad)
                }

                Section {
                    Button("Save"){
                        //Update only if there is a non-empty value
                        if !tempProtein.isEmpty{
                            protein = tempProtein
                            proteinChanged = true
                        }
                        if !tempCarbs.isEmpty{
                            carbs = tempCarbs
                            carbsChanged = true
                        }
                        if !tempFats.isEmpty{
                            fats = tempFats
                            fatsChanged = true
                        }
                        if !tempCalories.isEmpty{
                            calories = tempCalories
                            caloriesChanged = true
                        }

                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Edit Meal")
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel"){
                        dismiss()
                    }
                }
            }
        }
    }
}

// Preview for SwiftUI Canvas
struct NutritionView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionView()
    }
}

