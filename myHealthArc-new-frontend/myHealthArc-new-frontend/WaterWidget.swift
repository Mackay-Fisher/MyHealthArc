import SwiftUI

struct WaterWidget: View {
    @AppStorage("cupsFilled") private var cupsFilled: Int = 0
    @AppStorage("lastUpdatedDate") private var lastUpdatedDate: String = ""
    @AppStorage("waterGoal") private var waterGoal: Int = 8

    @State private var isLoading = true
    private let baseURL = "https://e0dc-198-217-29-75.ngrok-free.app/goals"
    private let userId = "dummy_user_id"
    
    @Environment(\.colorScheme) var colorScheme

    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Goal...")
            } else {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.mhaBlue)
                        Text("Log Water Intake")
                            .font(.headline)
                    }
                    //.padding()

                    Divider()
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(0..<waterGoal, id: \.self) { index in
                            CupView(isFilled: index < cupsFilled)
                                .onTapGesture {
                                    cupsFilled = index + 1 
                                }
                        }
                    }
                    //.padding()

                    Text("\(cupsFilled) / \(waterGoal) glasses")
                        .font(.subheadline)
                        .padding(.top)
                }
                .frame(maxWidth: 320)
                .padding()
                .background(colorScheme == .dark ? Color.mhaGray : Color.white)
                .cornerRadius(30)
                .shadow(radius: 0.2)
            }
        }
        .onAppear {
            checkForNewDay()
            fetchGoalsFromAPI()
        }
    }

    private func checkForNewDay() {
        let currentDate = formattedDate(Date())
        if lastUpdatedDate != currentDate {
            cupsFilled = 0
            lastUpdatedDate = currentDate
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func fetchGoalsFromAPI() {
        isLoading = true
        guard let url = URL(string: "\(baseURL)/fetch?userId=\(userId)") else {
            print("Invalid URL")
            isLoading = false
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { isLoading = false }
            guard let data = data, error == nil else {
                print("Error fetching goals: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                if let goals = try JSONSerialization.jsonObject(with: data) as? [String: Int] {
                    DispatchQueue.main.async {
                        waterGoal = goals["water-intake"] ?? 8
                    }
                }
            } catch {
                print("Error parsing goals JSON: \(error)")
            }
        }.resume()
    }
}

struct CupView: View {
    let isFilled: Bool

    var body: some View {
        Image(systemName: isFilled ? "drop.fill" : "drop")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundColor(.mhaBlue)
            .padding(4)
    }
}

struct WaterWidget_Previews: PreviewProvider {
    static var previews: some View {
        WaterWidget()
    }
}

