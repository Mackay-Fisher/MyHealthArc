//
//  SleepDataView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//
import SwiftUI

struct SleepDataView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Goal Completion Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Goal Completion")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    ProgressBar(value: 0.6) // 60% completion
                        .frame(height: 10)
                    
                    Text("60%")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .bold()
                }
                
                HStack {
                    Text("5h 4m")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("8h")
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
                    CircularSleepChart(hoursSlept: 5.0)
                        .frame(width: 80, height: 80)
                    
                    Text("Total Sleep")
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
                    Text("11:24 PM")
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
                    Text("4:05 AM")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
            }

            // Sleep Stages Graph
            VStack(alignment: .leading, spacing: 10) {
                Text("Sleep Data")
                    .font(.headline)
                    .foregroundColor(.white)
                
                SleepStageGraph()
                    .frame(height: 100)
                
                HStack {
                    LegendItem(color: .green, text: "Awake")
                    LegendItem(color: .purple, text: "Light")
                    LegendItem(color: .orange, text: "Deep")
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)

            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
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

// Sleep Stages Graph
struct SleepStageGraph: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Mock data points for sleep stages
                let dataPoints: [Double] = [1, 2, 3, 2, 1, 3, 1]
                
                // Calculate the spacing
                let spacing = width / CGFloat(dataPoints.count - 1)
                
                // Scale the data points to fit the graph height
                let maxY = dataPoints.max() ?? 1
                let scaleFactor = height / CGFloat(maxY)
                
                // Draw the graph
                path.move(to: CGPoint(x: 0, y: height - CGFloat(dataPoints[0]) * scaleFactor))
                for (index, value) in dataPoints.enumerated() {
                    path.addLine(to: CGPoint(x: CGFloat(index) * spacing, y: height - CGFloat(value) * scaleFactor))
                }
            }
            .stroke(Color.white, lineWidth: 2)
        }
    }
}

// Legend Item for Sleep Stages
struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.white)
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
