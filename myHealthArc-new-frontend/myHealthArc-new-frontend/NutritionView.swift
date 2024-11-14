//
//  NutritionView.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/23/24.
//


import SwiftUI
import SwiftUI

struct Meal {
    let name: String
    //let totalNutrition: String
    let totalProtein: Macro
    let totalCarbs: Macro
    let totalFats: Macro
    let totalCalories: Macro
}

struct Macro{
    let name: String
    let value: String
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
                .background(Color.white)
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

                            Button("Edit", systemImage: "pencil") {
                                showForm = true
                            }
                            .sheet(isPresented: $showForm) {
                                EditMeal(protein: $editProtein, carbs: $editCarbs, fats: $editFats, calories: $editCalories)
                            }
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

            // Prepare the URL with query parameters
            let baseURL = "http://localhost:8080/nutrition/info"
            let query = foodItems.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            guard let url = URL(string: "\(baseURL)?query=\(query)") else {
                print("Invalid URL")
                return
            }

            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            // Perform the API call
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

                // Decode the response and combine nutrient info
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Double]] {
                        var totalProtein = 0.0
                        var totalCarbs = 0.0
                        var totalFats = 0.0
                        var totalCalories = 0

                        // Combine the nutrient values
                        for (_, nutrients) in json {
                            totalProtein += nutrients["protein"] ?? 0
                            totalCarbs += nutrients["carbohydrates"] ?? 0
                            totalFats += nutrients["fats"] ?? 0
                            totalCalories += Int(nutrients["calories"] ?? 0)
                        }

                        var proteinRange: Macro
                        var carbsRange: Macro
                        var fatsRange: Macro
                        var caloriesRange: Macro

                        if proteinChanged{
                            proteinRange = Macro(name: "Protein:", value: "\(String(describing: Double(editProtein)))g")
                        }
                        else{
                            proteinRange = Macro(name: "Protein:", value: "\(totalProtein)g - \(totalProtein)g")
                        }

                        if carbsChanged{
                            carbsRange = Macro(name: "Carbs:", value: "\(String(describing: Double(editCarbs)))g")
                        }
                        else{
                            carbsRange = Macro(name: "Carbs:", value: "\(totalCarbs)g - \(totalCarbs)g")
                        }

                        if fatsChanged{
                            fatsRange = Macro(name: "Fats:", value: "\(String(describing: Double(editFats)))g")
                        }
                        else{
                            fatsRange = Macro(name: "Fats:", value: "\(totalFats)g - \(totalFats)g")
                        }
                        
                        if caloriesChanged{
                            caloriesRange = Macro(name: "Calories:", value: "\(String(describing: Double(editCalories)))kcal")
                        }
                        else{
                            caloriesRange = Macro(name: "Calories:", value: "\(totalCalories)kcal - \(totalCalories)kcal")
                        }

                        // Format the total nutrient information
                        DispatchQueue.main.async {
                            totalNutrition = """
                            Protein: \(totalProtein)g, \
                            Carbs: \(totalCarbs)g, \
                            Fats: \(totalFats)g, \
                            Calories: \(totalCalories)
                            """
                            // Add the meal and its nutrition info to the list
                            // meals.append(Meal(name: mealName, totalNutrition: totalNutrition))
                            // showFoodInfo = true

                            meals.append(Meal(name: mealName, totalProtein: proteinRange, totalCarbs: carbsRange, totalFats: fatsRange, totalCalories: caloriesRange))
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

    // Mock API Call to Fetch Food Info
    private func fetchFoodInfo() {
//        let mockData: [String: String] = [
//            "apple": "Apple - Calories: 95, Carbs: 25g, Protein: 0.5g, Fats: 0.3g",
//            "banana": "Banana - Calories: 105, Carbs: 27g, Protein: 1.3g, Fats: 0.4g"
//        ]
//
//        if let info = mockData[foodSearch.lowercased()] {
//            foodInfo = info
//            showFoodInfo = true
//        } else {
//            foodInfo = "No information found."
//            showFoodInfo = true
//        }
        guard !foodSearch.isEmpty else { return }

                // Prepare the URL with query parameters
                let baseURL = "http://localhost:8080/nutrition/info"
                let query = foodSearch.lowercased().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                guard let url = URL(string: "\(baseURL)?query=\(query)") else {
                    print("Invalid URL")
                    return
                }

                // Create the request
                var request = URLRequest(url: url)
                request.httpMethod = "GET"

                // Perform the API call
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

                    // Decode the response
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: Double]] {
                            if let firstFoodItem = json.first {
                                let foodItem = firstFoodItem.key
                                let nutrients = firstFoodItem.value
                                foodInfo = """
                                \(foodItem.capitalized) - Protein: \(nutrients["protein"] ?? 0)g, \
                                Carbs: \(nutrients["carbohydrates"] ?? 0)g, \
                                Fats: \(nutrients["fats"] ?? 0)g, \
                                Calories: \(nutrients["calories"] ?? 0)
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

                    // Update UI on the main thread
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

    @State private var tempProtein: String 
    @State private var tempCarbs: String 
    @State private var tempFats: String 
    @State private var tempCalories: String

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

