//
//  AppleHealthView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//
import SwiftUI

struct AppleHealthHomeView: View {
    @State private var selectedSection: HealthSection = .bmi // Default to BMI section

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("❤️ Apple Health Data")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Highlighted Line with Indicator
            
            // Horizontal Selector
            HStack(spacing: 30) {
                SectionButton(section: .bmi, isSelected: selectedSection == .bmi) {
                    selectedSection = .bmi
                }

                SectionButton(section: .sleep, isSelected: selectedSection == .sleep) {
                    selectedSection = .sleep
                }

                SectionButton(section: .vitals, isSelected: selectedSection == .vitals) {
                    selectedSection = .vitals
                }
            }
            ZStack {
                
                Triangle()
                    .fill(Color.pink)
                    .frame(width: 20, height: 10)
                    .offset(x: indicatorPosition(for: selectedSection), y: -5)
                // Line
                Rectangle()
                    .fill(Color.pink.opacity(0.8))
                    .frame(height: 2)

                // Triangle Indicator
                
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, -8)


            // Dynamic Content View
            ZStack {
                if selectedSection == .bmi {
                    BodyInfoView()
                } else if selectedSection == .sleep {
                    SleepDataView()
                } else if selectedSection == .vitals {
                    VitalInfoView()
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground).edgesIgnoringSafeArea(.bottom))
            .cornerRadius(20)
            .padding()

            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    // Calculate the position of the triangle indicator
    private func indicatorPosition(for section: HealthSection) -> CGFloat {
        switch section {
        case .bmi: return -110 // Adjust for the first section
        case .sleep: return 0 // Centered for the second section
        case .vitals: return 110 // Adjust for the third section
        }
    }
}

// Enum for Section
enum HealthSection {
    case bmi, sleep, vitals

    var title: String {
        switch self {
        case .bmi: return "BMI"
        case .sleep: return "Sleep"
        case .vitals: return "Vitals"
        }
    }

    var imageName: String {
        switch self {
        case .bmi: return "bmi_icon" // Replace with your actual image names
        case .sleep: return "sleep_icon"
        case .vitals: return "vital_icon"
        }
    }
}

// Custom Shape for Triangle
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0)) // Top of triangle
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Bottom right
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // Bottom left
        path.closeSubpath()
        return path
    }
}

// Button for Section Selector
struct SectionButton: View {
    let section: HealthSection
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        VStack {
            Image(section.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding()
                .background(isSelected ? Color.pink : Color.gray.opacity(0.2))
                .clipShape(Circle())
                .shadow(radius: isSelected ? 5 : 0)

            Text(section.title)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .onTapGesture(perform: action)
    }
}

// Subsections
struct BodyInfoView: View {
    var body: some View {
        VStack {
            Text("BMI Information")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

struct SleepDataView: View {
    var body: some View {
        VStack {
            Text("Sleep Data")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

struct VitalInfoView: View {
    var body: some View {
        VStack {
            Text("Vital Information")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

// Preview
struct AppleHealthHomeView_Previews: PreviewProvider {
    static var previews: some View {
        AppleHealthHomeView()
            .preferredColorScheme(.dark)
    }
}
