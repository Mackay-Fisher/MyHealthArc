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
                VStack(alignment: .leading, spacing: 20) {
                    // Title Section
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
                    
                    // Streaks Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Streaks")
                            .font(.headline)
                        
                        // Sleep Goals Pill
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        // Streak Information
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
                    
                    // Sleep Data Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Time Asleep")
                            .font(.headline)
                        
                        // Sleep Ring
                        HStack {
                            CircularSleepChart(hoursSlept: sleepHours)
                                .frame(width: 80, height: 80)
                                
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
    }
}

// Preview provider
struct HealthWidget_Previews: PreviewProvider {
    static var previews: some View {
        HealthWidget()
    }
}
