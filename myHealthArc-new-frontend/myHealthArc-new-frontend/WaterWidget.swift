//
//  WaterWidget.swift
//  myHealthArc-new-frontend
//
//  Created by Sharir on 11/24/24.
//
import SwiftUI

struct WaterWidget: View {
    @AppStorage("cupsFilled") private var cupsFilled: Int = 0
    @AppStorage("lastUpdatedDate") private var lastUpdatedDate: String = ""
    @AppStorage("waterGoal") private var waterGoal: Int = 8

    @State private var isLoading = true
    private let baseURL = "\(AppConfig.baseURL)/goals"
    private let userId = "dummy_user_id"

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Goal...")
            } else {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.mhaBlue)
                        Text("Water Intake")
                            .font(.headline)
                    }

                    Divider()

                    ZStack {
                        Circle()
                            .stroke(lineWidth: 10)
                            .foregroundColor(.mhaGray.opacity(0.3))
                            .frame(width: 150, height: 150)

                        Circle()
                            .trim(from: 0.0, to: progress)
                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .foregroundColor(.mhaBlue)
                            .frame(width: 150, height: 150)
                            .rotationEffect(.degrees(-90))

                        VStack {
                            Image(systemName: "drop.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .foregroundColor(.mhaBlue)

                            Text("\(cupsFilled) / \(waterGoal)")
                                .font(.headline)
                                .padding(.top, 4)
                        }
                    }
                    .padding()

                    HStack {
                        Button(action: {
                            if cupsFilled < waterGoal {
                                cupsFilled += 1
                            }
                        }) {
                            Text("Add Water")
                                .font(.subheadline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.mhaBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            if cupsFilled > 0 {
                                cupsFilled -= 1
                            }
                        }) {
                            Text("Remove Water")
                                .font(.subheadline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
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

    private var progress: CGFloat {
        return CGFloat(cupsFilled) / CGFloat(waterGoal)
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

struct WaterWidget_Previews: PreviewProvider {
    static var previews: some View {
        WaterWidget()
    }
}
