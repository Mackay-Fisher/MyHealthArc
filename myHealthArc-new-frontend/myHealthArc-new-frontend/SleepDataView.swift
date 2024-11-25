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
    @State private var sleepHoursByDay: [Date: Double] = [:]
    @State private var noDataAvailable: Bool = false
    @State private var sleepStages: [String: Double] = [
        "AWAKE": 0,
        "REM": 0,
        "CORE": 0,
        "DEEP": 0
    ]
    
    @Environment(\.colorScheme) var colorScheme
    private let healthStore = HKHealthStore()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if noDataAvailable {
                    VStack(spacing: 10) {
                        Text("No Sleep Data Available")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("This page is designed for wearable devices such as Apple Watches. To use this feature, please sync your sleep data with the Apple Health app.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Goal Completion")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            ProgressBar(value: min(totalSleepHours / 56.0, 1.0))
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
                    
                    HStack(spacing: 20) {
                        VStack {
                            CircularSleepChart(hoursSlept: lastSleepHours, stages: sleepStages)
                                .frame(width: 90, height: 90)
                            Spacer()
                            Text("Last Sleep")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        
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
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sleep Graph (Last Week)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            SleepGraphView(data: sleepHoursByDay)
                                .frame(width: max(CGFloat(sleepHoursByDay.count) * 50, UIScreen.main.bounds.width - 40))
                                .frame(height: 200)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
            }
            .padding()
            .background(colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all))
            .onAppear {
                requestAuthorization()
                fetchSleepData()
            }
        }
    }
    
    private func requestAuthorization() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        healthStore.requestAuthorization(toShare: [], read: [sleepType]) { success, error in
            DispatchQueue.main.async {
                authorizationStatus = success ? "Authorized" : "Denied"
            }
        }
    }
    
    private func fetchSleepData() {
       let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
       let today = Date()
       let calendar = Calendar.current
       let startDate = calendar.date(byAdding: .day, value: -8, to: calendar.startOfDay(for: today))!
       let predicate = HKQuery.predicateForSamples(withStart: startDate, end: today, options: .strictEndDate)
       
       let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, samples, error in
           guard let samples = samples as? [HKCategorySample], !samples.isEmpty else {
               DispatchQueue.main.async { self.noDataAvailable = true }
               return
           }
           
           DispatchQueue.main.async {
               var sleepSessions: [[HKCategorySample]] = []
               var currentSession: [HKCategorySample] = []
               let maxGapInHours = 3.0
               
               let sortedSamples = samples.sorted(by: { $0.startDate < $1.startDate })
               
               for sample in sortedSamples {
                   if let lastSample = currentSession.last {
                       let gap = sample.startDate.timeIntervalSince(lastSample.endDate) / 3600
                       if gap > maxGapInHours {
                           if !currentSession.isEmpty {
                               sleepSessions.append(currentSession)
                           }
                           currentSession = [sample]
                       } else {
                           currentSession.append(sample)
                       }
                   } else {
                       currentSession.append(sample)
                   }
               }
               if !currentSession.isEmpty {
                   sleepSessions.append(currentSession)
               }
               
               if let lastSession = sleepSessions.last {
                   var stagesData: [String: Double] = ["AWAKE": 0, "REM": 0, "CORE": 0, "DEEP": 0]
                   
                   for sample in lastSession {
                       let duration = sample.endDate.timeIntervalSince(sample.startDate) / 3600.0
                       switch sample.value {
                       case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                           stagesData["DEEP"]! += duration
                       case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                           stagesData["REM"]! += duration
                       case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                           stagesData["CORE"]! += duration
                       case HKCategoryValueSleepAnalysis.awake.rawValue:
                           stagesData["AWAKE"]! += duration
                       default:
                           break
                       }
                   }
                   
                   self.sleepStages = stagesData
                   self.lastSleepHours = stagesData.values.reduce(0, +)
                   
                   if let firstSample = lastSession.min(by: { $0.startDate < $1.startDate }),
                      let lastSample = lastSession.max(by: { $0.endDate < $1.endDate }) {
                       self.fallAsleepTime = firstSample.startDate
                       self.wakeUpTime = lastSample.endDate
                   }
               }
               
               var dailySleep: [Date: Double] = [:]
               for session in sleepSessions.suffix(7) {
                   let sessionStart = session[0].startDate
                   let sleepDay = calendar.startOfDay(for: sessionStart)
                   
                   let totalDuration = session.reduce(0.0) { sum, sample in
                       if sample.value != HKCategoryValueSleepAnalysis.awake.rawValue {
                           return sum + sample.endDate.timeIntervalSince(sample.startDate) / 3600.0
                       }
                       return sum
                   }
                   
                   dailySleep[sleepDay] = totalDuration
               }
               
               self.totalSleepHours = dailySleep.values.reduce(0, +)
               self.sleepHoursByDay = dailySleep
               self.noDataAvailable = false
           }
       }
       
       healthStore.execute(query)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct SleepGraphView: View {
   let data: [Date: Double]
   @State private var selectedDate: Date? = nil
   
   var body: some View {
       GeometryReader { geometry in
           let sortedData = data.sorted(by: { $0.key < $1.key })
           let maxHours = max(sortedData.map { $0.value }.max() ?? 8, 8)
           let width = geometry.size.width / CGFloat(sortedData.count)
           
           ZStack(alignment: .top) {
               HStack(alignment: .bottom, spacing: 4) {
                   ForEach(sortedData, id: \.key) { date, hours in
                       let height = CGFloat(hours / maxHours) * (geometry.size.height - 40)
                       VStack {
                           Spacer()
                           Rectangle()
                               .fill(Color.green)
                               .frame(width: width * 0.8, height: height)
                               .contentShape(Rectangle())
                               .onTapGesture {
                                   selectedDate = selectedDate == date ? nil : date
                                   if selectedDate != nil {
                                       DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                           selectedDate = nil
                                       }
                                   }
                               }
                           
                           VStack(spacing: 2) {
                               Text(date, formatter: dayFormatter)
                               Text(date, formatter: dateFormatter)
                           }
                           .font(.caption2)
                       }
                       .foregroundColor(.white)
                   }
               }
               
               if let date = selectedDate, let hours = data[date] {
                   VStack(spacing: 4) {
                       Text("\(date, formatter: dayFormatter)")
                           .font(.caption)
                       Text("\(Int(hours)) hrs \(Int((hours.truncatingRemainder(dividingBy: 1) * 60))) min")
                           .font(.caption)
                           .bold()
                   }
                   .padding(8)
                   .background(Color.black.opacity(0.8))
                   .cornerRadius(8)
                   .foregroundColor(.white)
                   .offset(y: 20)
               }
           }
       }
   }
   
   private var dayFormatter: DateFormatter {
       let formatter = DateFormatter()
       formatter.dateFormat = "EEEE"
       return formatter
   }
   
   private var dateFormatter: DateFormatter {
       let formatter = DateFormatter()
       formatter.dateFormat = "MMM d"
       return formatter
   }
}

struct CircularSleepChart: View {
    let hoursSlept: Double
    let stages: [String: Double]
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: CGFloat(stages["AWAKE"]! / hoursSlept))
                .stroke(Color.yellow, lineWidth: 8)
                .rotationEffect(.degrees(-90))
            
            Circle()
                .trim(from: CGFloat(stages["AWAKE"]! / hoursSlept),
                      to: CGFloat((stages["AWAKE"]! + stages["REM"]!) / hoursSlept))
                .stroke(Color.purple, lineWidth: 8)
                .rotationEffect(.degrees(-90))
            
            Circle()
                .trim(from: CGFloat((stages["AWAKE"]! + stages["REM"]!) / hoursSlept),
                      to: CGFloat((stages["AWAKE"]! + stages["REM"]! + stages["CORE"]!) / hoursSlept))
                .stroke(Color.blue, lineWidth: 8)
                .rotationEffect(.degrees(-90))
            
            Circle()
                .trim(from: CGFloat((stages["AWAKE"]! + stages["REM"]! + stages["CORE"]!) / hoursSlept),
                      to: CGFloat((stages["AWAKE"]! + stages["REM"]! + stages["CORE"]! + stages["DEEP"]!) / hoursSlept))
                .stroke(Color.green, lineWidth: 8)
                .rotationEffect(.degrees(-90))
            
            VStack {
               Text("\(Int(hoursSlept)) hrs")
                   .font(.headline)
               Text("\(Int((hoursSlept.truncatingRemainder(dividingBy: 1) * 60))) min")
                   .font(.caption)
            }
            .foregroundColor(.white)
        }
    }
}

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

struct SleepDataView_Previews: PreviewProvider {
    static var previews: some View {
        SleepDataView()
            .preferredColorScheme(.dark)
    }
}
