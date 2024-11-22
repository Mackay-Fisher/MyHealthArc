//
//  VitalInfoView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//

import SwiftUI
import HealthKit

struct VitalInfoView: View {

    @State private var heartRate: Int? // Heart rate in bpm
    @State private var respiratoryRate: Int? // Breaths per minute
    @State private var systolicBP: Int? // Systolic blood pressure
    @State private var diastolicBP: Int? // Diastolic blood pressure
    @State private var heartRateData: [(String, Double)] = []
    @State private var respiratoryData: [(String, Double)] = []
    @State private var noDataAvailable: Bool = false // No data flag

    private let healthStore = HKHealthStore()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if noDataAvailable {
                    // No Data Fallback Message
                    VStack(spacing: 10) {
                        Text("No Vital Data Available")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("This page is designed for wearable devices such as Apple Watches. To use this feature, please sync your vital data with the Apple Health app.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    // Blood Pressure Section
                    if let systolic = systolicBP, let diastolic = diastolicBP {
                        VStack(spacing: 10) {
                            Text("Blood Pressure")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            HStack {
                                Text("Systolic: \(systolic) mmHg")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Diastolic: \(diastolic) mmHg")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    }

                    // Heart Rate Section
                    if let heartRate = heartRate {
                        VitalSection(
                            title: "Heart Rate",
                            value: "\(heartRate) bpm",
                            icon: "heart.fill",
                            iconColor: .red,
                            data: heartRateData,
                            lineColor: .red,
                            fillColor: Color.red.opacity(0.2)
                        )
                    }

                    // Respiratory Rate Section
                    if let respiratoryRate = respiratoryRate {
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
                }
            }
            .padding()
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onAppear {
                fetchVitalData()
            }
        }
    }

    // MARK: - Fetch Vital Data
    private func fetchVitalData() {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .hour, value: -1, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let dispatchGroup = DispatchGroup()

        var heartRateFound = false
        var respiratoryRateFound = false
        var bloodPressureFound = false

        // Fetch heart rate
        dispatchGroup.enter()
        fetchQuantityData(for: .heartRate, unit: HKUnit.count().unitDivided(by: HKUnit.minute()), predicate: predicate) { values in
            if let latest = values.last {
                self.heartRate = Int(latest.1)
                heartRateFound = true
            }
            self.heartRateData = values
            dispatchGroup.leave()
        }

        // Fetch respiratory rate
        dispatchGroup.enter()
        fetchQuantityData(for: .respiratoryRate, unit: HKUnit.count().unitDivided(by: HKUnit.minute()), predicate: predicate) { values in
            if let latest = values.last {
                self.respiratoryRate = Int(latest.1)
                respiratoryRateFound = true
            }
            self.respiratoryData = values
            dispatchGroup.leave()
        }

        // Fetch blood pressure
        dispatchGroup.enter()
        fetchBloodPressureData(predicate: predicate) { systolic, diastolic in
            if systolic > 0 || diastolic > 0 {
                self.systolicBP = systolic
                self.diastolicBP = diastolic
                bloodPressureFound = true
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            if !heartRateFound && !respiratoryRateFound && !bloodPressureFound {
                self.noDataAvailable = true
            }
        }
    }

    // MARK: - Fetch Quantity Data Helper
    private func fetchQuantityData(for identifier: HKQuantityTypeIdentifier, unit: HKUnit, predicate: NSPredicate, completion: @escaping ([(String, Double)]) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            completion([])
            return
        }

        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: 10, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, _ in
            var results: [(String, Double)] = []
            if let samples = samples as? [HKQuantitySample] {
                for sample in samples {
                    let timestamp = DateFormatter.localizedString(from: sample.startDate, dateStyle: .none, timeStyle: .short)
                    let value = sample.quantity.doubleValue(for: unit)
                    results.append((timestamp, value))
                }
            }
            DispatchQueue.main.async {
                completion(results)
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Fetch Blood Pressure Data Helper
    private func fetchBloodPressureData(predicate: NSPredicate, completion: @escaping (Int, Int) -> Void) {
        guard let systolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
              let diastolicType = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic) else {
            completion(0, 0)
            return
        }

        let systolicQuery = HKSampleQuery(sampleType: systolicType, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, _ in
            let systolicValue = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.millimeterOfMercury()) ?? 0
            DispatchQueue.main.async {
                let systolic = Int(systolicValue)

                let diastolicQuery = HKSampleQuery(sampleType: diastolicType, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, _ in
                    let diastolicValue = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.millimeterOfMercury()) ?? 0
                    DispatchQueue.main.async {
                        let diastolic = Int(diastolicValue)
                        completion(systolic, diastolic)
                    }
                }
                self.healthStore.execute(diastolicQuery)
            }
        }

        healthStore.execute(systolicQuery)
    }
}

// Preview
struct VitalInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VitalInfoView()
            .preferredColorScheme(.dark)
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

