//
//  FitnessDataView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//

import SwiftUI

struct FitnessDataView: View {
    let containerHeight: CGFloat // Height passed from the parent view

    @State private var stepCount: Int = 5548
    @State private var caloriesBurned: Int = 177
    @State private var distance: Double = 0.22 // in miles
    @State private var exerciseTime: Int = 30 // in minutes
    @State private var elevationGain: Int = 300 // in feet
    @State private var activeEnergy: Int = 500 // Active calories burned

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Text("🏃‍♂️ Apple Fitness Data")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Summary")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom)

                // Manage Goals Button
                HStack {
                    Text("Manage Goals")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .onTapGesture {
                    // Add navigation or functionality for "Manage Goals"
                    print("Manage Goals tapped!")
                }

                // Data Widgets Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    FitnessWidget(
                        title: "Step Count",
                        value: "\(stepCount)",
                        goal: "10,000",
                        progress: Double(stepCount) / 10000,
                        icon: "figure.walk",
                        iconColor: .blue
                    )

                    FitnessWidget(
                        title: "Calories Burned",
                        value: "\(caloriesBurned) kcal",
                        goal: "400 kcal",
                        progress: Double(caloriesBurned) / 400,
                        icon: "flame.fill",
                        iconColor: .red
                    )

                    FitnessWidget(
                        title: "Distance",
                        value: "\(String(format: "%.2f", distance)) mi",
                        goal: "1.0 mi",
                        progress: distance / 1.0,
                        icon: "map.fill",
                        iconColor: .green
                    )

                    FitnessWidget(
                        title: "Exercise Time",
                        value: "\(exerciseTime) min",
                        goal: "60 min",
                        progress: Double(exerciseTime) / 60,
                        icon: "dumbbell.fill",
                        iconColor: .purple
                    )

                    FitnessWidget(
                        title: "Elevation Gain",
                        value: "\(elevationGain) ft",
                        goal: "500 ft",
                        progress: Double(elevationGain) / 500,
                        icon: "triangle.fill",
                        iconColor: .orange
                    )

                    FitnessWidget(
                        title: "Active Energy",
                        value: "\(activeEnergy) kcal",
                        goal: "800 kcal",
                        progress: Double(activeEnergy) / 800,
                        icon: "bolt.fill",
                        iconColor: .yellow
                    )
                }
            }
            .padding()
            .frame(minHeight: containerHeight) // Dynamically set the height
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

// Widget Component
struct FitnessWidget: View {
    let title: String
    let value: String
    let goal: String
    let progress: Double
    let icon: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Background Circle
                Circle()
                    .stroke(lineWidth: 10)
                    .fill(Color(.systemGray5))

                // Progress Circle
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .fill(iconColor)
                    .rotationEffect(Angle(degrees: -90))

                // Icon
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(iconColor)
            }
            .frame(width: 80, height: 80)

            // Title and Values
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("To Go: \(goal)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// Preview
struct FitnessDataView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessDataView(containerHeight: 800)
            .preferredColorScheme(.dark)
    }
}
