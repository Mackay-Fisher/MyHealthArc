//
//  VitalInfoView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//

import SwiftUI

struct VitalInfoView: View {
    let containerHeight: CGFloat // Height passed from the parent view

    @State private var heartRate: Int = 72 // Heart rate in bpm
    @State private var respiratoryRate: Int = 15 // Breaths per minute
    @State private var systolicBP: Int = 120 // Systolic blood pressure
    @State private var diastolicBP: Int = 80 // Diastolic blood pressure
    @State private var heartRateData: [(String, Double)] = [ // Example heart rate data
        ("12:00", 72), ("12:01", 74), ("12:02", 70),
        ("12:03", 75), ("12:04", 72), ("12:05", 68)
    ]
    @State private var respiratoryData: [(String, Double)] = [ // Example respiratory rate data
        ("12:00", 12), ("12:01", 13), ("12:02", 15),
        ("12:03", 14), ("12:04", 15), ("12:05", 16)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Blood Pressure Section
                VStack(spacing: 10) {
                    Text("Blood Pressure")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Text("Systolic: \(systolicBP) mmHg")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Spacer()
                        Text("Diastolic: \(diastolicBP) mmHg")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)

                // Heart Rate Section
                VitalSection(
                    title: "Heart Rate",
                    value: "\(heartRate) bpm",
                    icon: "heart.fill",
                    iconColor: .red,
                    data: heartRateData,
                    lineColor: .red,
                    fillColor: Color.red.opacity(0.2)
                )

                // Respiratory Rate Section
                VitalSection(
                    title: "Respiratory Rate",
                    value: "\(respiratoryRate) breaths/min",
                    icon: "lungs.fill",
                    iconColor: .blue,
                    data: respiratoryData,
                    lineColor: .blue,
                    fillColor: Color.blue.opacity(0.2)
                )
            }
            .padding()
            .frame(minHeight: containerHeight) // Dynamically adjust the height
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct VitalSection: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    let data: [(String, Double)] // Updated to include time-value pairs
    let lineColor: Color
    let fillColor: Color

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("10:23") // Placeholder for timestamp
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            HStack(alignment: .center) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(iconColor)
                Spacer()
                Text(value)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.bottom, 10)

            GraphView(data: data, lineColor: lineColor, fillColor: fillColor)
                .frame(height: 150) // Consistent graph height
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// Updated Graph View
struct GraphView: View {
    let data: [(String, Double)] // Time and value pairs
    let lineColor: Color
    let fillColor: Color

    @State private var hoverIndex: Int? // Tracks the currently hovered index

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let step = width / CGFloat(data.count - 1)
            let maxValue = data.map { $0.1 }.max() ?? 1
            let minValue = data.map { $0.1 }.min() ?? 0

            ZStack {
                // Graph Line
                Path { path in
                    guard !data.isEmpty else { return }
                    path.move(to: CGPoint(
                        x: 0,
                        y: height * (1 - CGFloat((data[0].1 - minValue) / (maxValue - minValue)))
                    ))

                    for index in 1..<data.count {
                        let xPosition = CGFloat(index) * step
                        let yPosition = height * (1 - CGFloat((data[index].1 - minValue) / (maxValue - minValue)))
                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    }
                }
                .stroke(lineColor, lineWidth: 2)

                // Graph Fill
                Path { path in
                    guard !data.isEmpty else { return }
                    path.move(to: CGPoint(
                        x: 0,
                        y: height
                    ))
                    path.addLine(to: CGPoint(
                        x: 0,
                        y: height * (1 - CGFloat((data[0].1 - minValue) / (maxValue - minValue)))
                    ))

                    for index in 1..<data.count {
                        let xPosition = CGFloat(index) * step
                        let yPosition = height * (1 - CGFloat((data[index].1 - minValue) / (maxValue - minValue)))
                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    }

                    path.addLine(to: CGPoint(x: width, y: height))
                    path.closeSubpath()
                }
                .fill(fillColor)

                // Hover Interactivity
                if let hoverIndex = hoverIndex, hoverIndex >= 0 && hoverIndex < data.count {
                    let xPosition = CGFloat(hoverIndex) * step
                    let yPosition = height * (1 - CGFloat((data[hoverIndex].1 - minValue) / (maxValue - minValue)))

                    // Vertical Line
                    Path { path in
                        path.move(to: CGPoint(x: xPosition, y: 0))
                        path.addLine(to: CGPoint(x: xPosition, y: height))
                    }
                    .stroke(lineColor.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))

                    // Hover Point
                    Circle()
                        .fill(lineColor)
                        .frame(width: 10, height: 10)
                        .position(x: xPosition, y: yPosition)

                    // Value Tooltip
                    VStack(spacing: 2) {
                        Text(data[hoverIndex].0) // Time
                            .font(.caption)
                            .foregroundColor(.white)
                        Text(String(format: "%.0f", data[hoverIndex].1)) // Value
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(5)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    .position(
                        x: min(max(20, xPosition), geometry.size.width - 20),
                        y: max(20, yPosition - 30)
                    )
                }
            }
            .gesture(DragGesture()
                .onChanged { value in
                    // Calculate hover index based on drag position
                    let index = Int((value.location.x / step).rounded())
                    hoverIndex = index
                }
                .onEnded { _ in
                    hoverIndex = nil // Clear hover index when interaction ends
                }
            )
        }
        .frame(height: 150) // Adjust graph height as needed
    }
}

// Preview
struct VitalInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VitalInfoView(containerHeight: 600)
            .preferredColorScheme(.dark)
    }
}

