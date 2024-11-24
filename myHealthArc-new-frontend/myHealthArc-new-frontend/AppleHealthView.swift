//
//  AppleHealthView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//
import SwiftUI

struct AppleHealthHomeView: View {
    @State private var selectedSection: HealthSection = .bmi // Default to BMI section
    @State private var height: Double = 63
    @State private var weight: Double = 115
    @State private var age: Int = 22
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // Header
                Text("❤️ Apple Health Data")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

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

                // Highlighted Line with Indicator
                ZStack {
                    Triangle()
                        .fill(Color.pink)
                        .frame(width: 20, height: 10)
                        .offset(x: indicatorPosition(for: selectedSection), y: -5)

                    Rectangle()
                        .fill(Color.pink.opacity(0.8))
                        .frame(height: 2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, -10)

                // Dynamic Content View
                ZStack {
                    if selectedSection == .bmi {
                        BodyInfoView(
                            height: $height,
                            weight: $weight,
                            age: $age
                        )
                    } else if selectedSection == .sleep {
                        SleepDataView()
                    } else if selectedSection == .vitals {
                        VitalInfoView()
                    }
                }
                .frame(height: geometry.size.height - geometry.safeAreaInsets.top - 100) // Adjust height dynamically
                .cornerRadius(20)


                Spacer()
            }
            .padding()
            .background(colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all))
        }
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

// Preview
struct AppleHealthHomeView_Previews: PreviewProvider {
    static var previews: some View {
        AppleHealthHomeView()
            .preferredColorScheme(.dark)
    }
}
