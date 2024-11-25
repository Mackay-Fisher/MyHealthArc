//
//  VitalInfoView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//
import SwiftUI
import HealthKit

struct VitalInfoView: View {
    @State private var heartRate: Int?
    @State private var respiratoryRate: Int?
    @State private var systolicBP: Int?
    @State private var diastolicBP: Int?
    @State private var heartRateData: [(String, Double)] = []
    @State private var respiratoryData: [(String, Double)] = []
    @State private var noDataAvailable: Bool = false
    @State private var isAuthorized: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    private let healthStore = HKHealthStore()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if noDataAvailable {
                    VStack(spacing: 10) {
                        Text("No Vital Data Available")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        
                        Text("This page is designed for wearable devices such as Apple Watches. To use this feature, please sync your vital data with the Apple Health app.")
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    if let systolic = systolicBP, let diastolic = diastolicBP {
                        VStack(spacing: 10) {
                            Text("Blood Pressure")
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            HStack {
                                Text("Systolic: \(systolic) mmHg")
                                    .font(.subheadline)
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                Spacer()
                                Text("Diastolic: \(diastolic) mmHg")
                                    .font(.subheadline)
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    }
                    
                    if let heartRate = heartRate {
                        VitalSection(
                            title: "Heart Rate",
                            value: "\(heartRate) bpm",
                            timestamp: Date(),
                            icon: "heart.fill",
                            iconColor: .red,
                            data: heartRateData,
                            lineColor: .red,
                            fillColor: Color.red.opacity(0.2)
                        )
                    }
                    
                    if let respiratoryRate = respiratoryRate {
                        VitalSection(
                            title: "Respiratory Rate",
                            value: "\(respiratoryRate) breaths/min",
                            timestamp: Date(),
                            icon: "lungs.fill",
                            iconColor: .mhaBlue,
                            data: respiratoryData,
                            lineColor: .mhaBlue,
                            fillColor: Color.mhaBlue.opacity(0.2)
                        )
                    }
                }
            }
            .padding()
            .background(colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            AppleHealthManager.shared.requestPermissions { success, error in
                DispatchQueue.main.async {
                    self.isAuthorized = success
                    if success {
                        self.fetchVitalData()
                    } else {
                        self.noDataAvailable = true
                    }
                }
            }
        }
    }
    
    private func fetchVitalData() {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        
        Task {
            do {
                // Get vital signs
                let vitalSigns = try await AppleHealthManager.shared.fetchVitalSigns()
                
                // Get historical heart rate data
                let heartRateHistory = try await AppleHealthManager.shared.fetchHistoricalData(
                    for: .heartRate,
                    unit: HKUnit(from: "count/min"),
                    from: startDate,
                    to: now
                )
                
                // Get historical respiratory rate data
                let respiratoryHistory = try await AppleHealthManager.shared.fetchHistoricalData(
                    for: .respiratoryRate,
                    unit: HKUnit.count().unitDivided(by: .minute()),
                    from: startDate,
                    to: now
                )
                
                DispatchQueue.main.async {
                    // Update current values
                    for data in vitalSigns {
                        switch data.type {
                        case "heartRate":
                            self.heartRate = Int(data.value)
                        case "respiratoryRate":
                            self.respiratoryRate = Int(data.value)
                        case "bloodPressureSystolic":
                            self.systolicBP = Int(data.value)
                        case "bloodPressureDiastolic":
                            self.diastolicBP = Int(data.value)
                        default:
                            break
                        }
                    }
                    
                    // Update graph data
                    self.heartRateData = heartRateHistory
                    self.respiratoryData = respiratoryHistory
                    
                    self.noDataAvailable = vitalSigns.isEmpty
                }
            } catch {
                print("Error fetching data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.noDataAvailable = true
                }
            }
        }
    }
}

struct VitalSection: View {
    let title: String
    let value: String
    let timestamp: Date
    let icon: String
    let iconColor: Color
    let data: [(String, Double)]
    let lineColor: Color
    let fillColor: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                Spacer()
                Text(timestamp, style: .time) // Use timestamp
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Divider()
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
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
            .padding(.bottom, 10)
            
            GraphView(data: data, lineColor: lineColor, fillColor: fillColor)
                .frame(height: 150)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct GraphView: View {
    let data: [(String, Double)]
    let lineColor: Color
    let fillColor: Color
    
    @State private var hoverIndex: Int?
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let step = width / CGFloat(max(data.count - 1, 1))
            let maxValue = data.map { $0.1 }.max() ?? 1
            let minValue = data.map { $0.1 }.min() ?? 0
            
            ZStack {
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
                
                Path { path in
                    guard !data.isEmpty else { return }
                    path.move(to: CGPoint(x: 0, y: height))
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
                
                if let hoverIndex = hoverIndex, hoverIndex >= 0 && hoverIndex < data.count {
                    let xPosition = CGFloat(hoverIndex) * step
                    let yPosition = height * (1 - CGFloat((data[hoverIndex].1 - minValue) / (maxValue - minValue)))
                    
                    Path { path in
                        path.move(to: CGPoint(x: xPosition, y: 0))
                        path.addLine(to: CGPoint(x: xPosition, y: height))
                    }
                    .stroke(lineColor.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
                    
                    Circle()
                        .fill(lineColor)
                        .frame(width: 10, height: 10)
                        .position(x: xPosition, y: yPosition)
                    
                    VStack(spacing: 2) {
                        Text(data[hoverIndex].0)
                            .font(.caption)
                            .foregroundColor(.white)
                        Text(String(format: "%.0f", data[hoverIndex].1))
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
                    let index = Int((value.location.x / step).rounded())
                    hoverIndex = index
                }
                .onEnded { _ in
                    hoverIndex = nil
                }
            )
        }
        .frame(height: 150)
    }
}

struct VitalInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VitalInfoView()
            .preferredColorScheme(.dark)
    }
}
