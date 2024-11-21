//
//  SleepDataView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//
import SwiftUI
import HealthKit

struct SleepDataView: View {
    @State private var authorizationStatus: String = "Not Requested"
    @State private var totalSleepHours: Double = 0
    @State private var lastSleepHours: Double = 0
    @State private var fallAsleepTime: Date? = nil
    @State private var wakeUpTime: Date? = nil
    @State private var sleepHoursByDay: [Date: Double] = [:] // For graph data

    private let healthStore = HKHealthStore()

    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                // Goal Completion Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Goal Completion")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack {
                        ProgressBar(value: min(totalSleepHours / 56.0, 1.0)) // 8-hour/night goal over 7 days
                            .frame(height: 10)
                        
                        Text("\(String(format: "%.1f", totalSleepHours)) hrs")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .bold()
                    }
                    
                    HStack {
                        Text("\(String(format: "%.1f", totalSleepHours)) hrs this week")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("56 hrs goal")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Sleep Summary Section
                HStack(spacing: 20) {
                    // Circular Sleep Chart
                    VStack {
                        CircularSleepChart(hoursSlept: lastSleepHours)
                            .frame(width: 80, height: 80)
                        
                        Text("Last Sleep")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    // Fall Asleep and Wake Up Times
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.yellow)
                            Text("Fall Asleep")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        Text(fallAsleepTime != nil ? "\(fallAsleepTime!, formatter: timeFormatter)" : "N/A")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Divider()
                            .background(Color.white)
                        
                        HStack {
                            Image(systemName: "sunrise.fill")
                                .foregroundColor(.orange)
                            Text("Wake Up")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        Text(wakeUpTime != nil ? "\(wakeUpTime!, formatter: timeFormatter)" : "N/A")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
                
                // Sleep Graph Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sleep Graph (Last Week)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    SleepGraphView(data: sleepHoursByDay)
                        .frame(height: 150)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                Spacer()
                
                Button(action: fetchSleepData) {
                    Text("Fetch Sleep Data")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onAppear {
                requestAuthorization()
            }
        }
    }

    // MARK: - Request HealthKit Authorization
    private func requestAuthorization() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        healthStore.requestAuthorization(toShare: [], read: [sleepType]) { success, error in
            DispatchQueue.main.async {
                authorizationStatus = success ? "Authorized" : "Denied"
            }
        }
    }

    // MARK: - Fetch Sleep Data
    // MARK: - Fetch Sleep Data
    private func fetchSleepData() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        // Calculate the start of the current week (Sunday)
        let today = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = weekday - calendar.firstWeekday
        let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: calendar.startOfDay(for: today))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!

        print("Fetching sleep data from \(startOfWeek) to \(endOfWeek)")

        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: endOfWeek, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
            // Debug: Check if the query executed
            if let error = error {
                print("Error executing sleep query: \(error.localizedDescription)")
                return
            }

            // Debug: Check the returned samples
            print("Fetched \(samples?.count ?? 0) sleep samples")

            guard let samples = samples as? [HKCategorySample] else {
                print("No valid sleep samples found")
                return
            }

            DispatchQueue.main.async {
                var totalHours = 0.0
                var mostRecentSleep: Double? = nil
                var dailySleep: [Date: Double] = [:]

                for sample in samples {
                    let start = sample.startDate
                    let end = sample.endDate
                    let duration = end.timeIntervalSince(start) / 3600.0

                    print("Sample - Start: \(start), End: \(end), Duration: \(duration) hours")

                    totalHours += duration
                    if sample == samples.last {
                        mostRecentSleep = duration
                    }

                    let day = calendar.startOfDay(for: start)
                    dailySleep[day, default: 0.0] += duration
                }

                // Debug: Output aggregated results
                print("Total Sleep Hours: \(totalHours)")
                print("Most Recent Sleep Duration: \(mostRecentSleep ?? 0)")
                print("Daily Sleep Hours: \(dailySleep)")

                // Update UI state
                totalSleepHours = totalHours
                lastSleepHours = mostRecentSleep ?? 0
                sleepHoursByDay = dailySleep
            }
        }

        healthStore.execute(query)
        print("HealthKit sleep query executed")
    }



    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - Sleep Graph View
struct SleepGraphView: View {
    let data: [Date: Double]

    var body: some View {
        GeometryReader { geometry in
            let sortedData = data.sorted(by: { $0.key < $1.key })
            let maxHours = sortedData.map { $0.value }.max() ?? 8
            let width = geometry.size.width / CGFloat(sortedData.count)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(sortedData, id: \.key) { entry in
                    let height = CGFloat(entry.value / maxHours) * geometry.size.height
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: width * 0.8, height: height)
                        Text(entry.key, formatter: shortDateFormatter)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    private var shortDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
}

// Circular Sleep Chart
struct CircularSleepChart: View {
    let hoursSlept: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: CGFloat(hoursSlept / 8.0))
                .stroke(Color.green, lineWidth: 8)
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(hoursSlept)) hrs")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

// Progress Bar
struct ProgressBar: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                Rectangle()
                    .frame(width: CGFloat(value) * geometry.size.width, height: geometry.size.height)
                    .foregroundColor(.purple)
            }
            .cornerRadius(5)
        }
    }
}

// Preview
struct SleepDataView_Previews: PreviewProvider {
    static var previews: some View {
        SleepDataView()
            .preferredColorScheme(.dark)
    }
}
