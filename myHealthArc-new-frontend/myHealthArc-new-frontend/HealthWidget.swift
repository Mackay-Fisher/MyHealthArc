//
//  HealthWidget.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 11/22/24.
//


import SwiftUI

struct HealthWidget: View {
    @State private var showFullHealthView = false
    @Environment(\.colorScheme) var colorScheme
    
    // Sample data - In production, this would come from HealthKit
    private let sleepStreak = 14
    private let sleepHours = 8.0
    private let sleepStages = [
        ("Awake", Color.green),
        ("Core", Color.purple),
        ("Deep", Color.blue),
        ("REM", Color.orange)
    ]
    
    var body: some View {
        VStack {
            // Header
            NavigationLink(destination: AppleHealthHomeView(), isActive: $showFullHealthView) {
                EmptyView()
            }
            
            Button(action: {
                showFullHealthView = true
            }) {
                VStack(spacing: 20) {
                    // Title Section
                    HStack {
                        Spacer()
                        HStack {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25)
                                .foregroundColor(.pink)
                            
                            Spacer()
                                .frame(width: 15)
                            
                            Text("Apple Health")
                                .font(.headline)
                                .padding(.top)
                                .frame(alignment: .leading)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .padding(.top)
                            .foregroundColor(colorScheme == .dark ? Color.lightbackground : Color.gray)
                    }
                    Divider()
                    
                    
                    // Streaks Section
                    VStack(alignment: .leading) {
                        Text("Streaks")
                            .font(.headline)
                        
                        // Sleep Goals Pill
                        HStack {
                            Image(systemName: "triangle.fill")
                                .rotationEffect(.degrees(180))
                                .foregroundColor(.green)
                            Text("Sleep Goals")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        
                        // Streak Information
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(sleepStreak) days")
                                .foregroundColor(.green)
                                .fontWeight(.bold)
                            + Text(" of meeting\nyour sleep goal!")
                                .fontWeight(.regular)
                        }
                    }
                    
                    // Sleep Data Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Time Asleep")
                            .font(.headline)
                        
                        // Sleep Ring
                        HStack {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .trim(from: 0, to: 0.7)
                                    .stroke(
                                        AngularGradient(
                                            colors: sleepStages.map { $0.1 },
                                            center: .center
                                        ),
                                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                    )
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack {
                                    Text("\(Int(sleepHours))")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("hrs")
                                        .font(.caption)
                                }
                            }
                            
                            // Legend
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(sleepStages, id: \.0) { stage in
                                    HStack {
                                        Circle()
                                            .fill(stage.1)
                                            .frame(width: 8, height: 8)
                                        Text(stage.0)
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding(.leading)
                        }
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
    }
}

// Preview provider
struct HealthWidget_Previews: PreviewProvider {
    static var previews: some View {
        HealthWidget()
    }
}
