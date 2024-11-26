//
//  HealthWidget.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 11/22/24.
//
import SwiftUI
import HealthKit

struct HealthWidget: View {
    //TODO: fix variables that are needed vs not
   @State private var showFullHealthView = false
   @Environment(\.colorScheme) var colorScheme
    @State private var fallAsleepTime: Date? = nil
    @State private var wakeUpTime: Date? = nil
    @State private var noDataAvailable: Bool = false
    @State private var totalSleepHours: Double = 0
    private let healthStore = HKHealthStore()
    @State private var lastSleepHours: Double = 0
    private let sleepStreak = 35
@State private var sleepStages: [String: Double] = [
        "AWAKE": 0,
        "REM": 0,
        "CORE": 0,
        "DEEP": 0
    ]
   var body: some View {
       VStack {
           NavigationLink(destination: AppleHealthHomeView(), isActive: $showFullHealthView) {
               EmptyView()
           }
           
           Button(action: {
               showFullHealthView = true
           }) {
               VStack(alignment: .leading, spacing: 20) {
                  HStack {
                      Spacer()
                      HStack {
                          Image(systemName: "heart.fill")
                              .resizable()
                              .scaledToFit()
                              .frame(width: 25)
                              .foregroundColor(.pink)
                          
                          Text("Apple Health")
                              .font(.headline)
                              .padding(.top)
                      }
                      
                      Spacer()
                      
                      Image(systemName: "chevron.right")
                          .padding(.top)
                          .foregroundColor(colorScheme == .dark ? Color.lightbackground : Color.gray)
                  }
                  
                  Divider()
                  
                  VStack(alignment: .leading, spacing: 10) {
                      Text("Streaks")
                          .font(.headline)
                      
                      HStack {
                          Image(systemName: "pin.fill")
                              .rotationEffect(.degrees(180))
                              .foregroundColor(.blue)
                          Text("Sleep Goals")
                              .font(.subheadline)
                      }
                      .padding(.horizontal, 12)
                      .padding(.vertical, 6)
                      .background(Color.gray.opacity(0.2))
                      .cornerRadius(20)
                      
                      HStack(alignment: .center) {
                          Image(systemName: "flame.fill")
                              .foregroundColor(.orange)
                          
                          Text("\(sleepStreak) days")
                              .foregroundColor(.green)
                              .fontWeight(.bold)
                          + Text(" of meeting\nyour sleep goal!")
                              .fontWeight(.regular)
                      }
                      .frame(maxWidth: .infinity, alignment: .center)
                  }
                   
                   VStack(alignment: .leading, spacing: 10) {
                       Text("Time Asleep")
                           .font(.headline)
                       
                       HStack {
                           VStack {
                               CircularSleepChart(hoursSlept: lastSleepHours, stages: sleepStages)
                                   .frame(width: 90, height: 90)
                               Text("Last Sleep")
                                   .font(.caption)
                           }
                           
                           VStack(alignment: .leading, spacing: 4) {
                               ForEach(sleepStages.sorted(by: { $0.key < $1.key }), id: \.key) { stage, hours in
                                   HStack {
                                       Circle()
                                           .fill(stageColor(for: stage))
                                           .frame(width: 8, height: 8)
                                       Text(stage)
                                           .font(.caption)
                                       Spacer()
                                       Text("\(Int(hours))h \(Int((hours.truncatingRemainder(dividingBy: 1) * 60)))m")
                                           .font(.caption)
                                   }
                               }
                           }
                           .padding(.leading)
                       }
                       .frame(maxWidth: .infinity, alignment: .center)
                   }
               }
               .padding()
               .frame(width: 350)
               .background(colorScheme == .dark ? Color.mhaGray : Color.white)
               .cornerRadius(30)
               .shadow(radius: 0.2)
           }
           .buttonStyle(PlainButtonStyle())
       }
       .padding(.horizontal)
       .onAppear { fetchSleepData() }
   }
   
   private func stageColor(for stage: String) -> Color {
       switch stage {
       case "AWAKE": return .yellow
       case "REM": return .purple
       case "CORE": return .blue
       case "DEEP": return .green
       default: return .gray
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
               //self.sleepHoursByDay = dailySleep
               self.noDataAvailable = false
           }
       }
       
       healthStore.execute(query)
    }
}

struct HealthWidget_Previews: PreviewProvider {
    static var previews: some View {
        HealthWidget()
    }
}
