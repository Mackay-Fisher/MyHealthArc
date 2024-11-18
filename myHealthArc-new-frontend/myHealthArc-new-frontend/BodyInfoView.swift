//
//  BodyInfoView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/18/24.
//

import SwiftUI

struct BodyInfoView: View {
    @State private var height: Double = 63 // Default height in inches
    @State private var weight: Double = 115 // Default weight in pounds
    @State private var gender: Gender = .male // Default gender
    @State private var age: Int = 22 // Default age
    @State private var bmi: Double? // BMI value (calculated)

    var body: some View {
        VStack(spacing: 20) {
            // Gender Toggle
            HStack(alignment: .center){
                VStack(alignment: .center, spacing: 8) {
                    HStack {
                        VStack{
                            Button(action: {
                                gender = .male
                            }) {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .background(gender == .male ? Color.pink : Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                                    .foregroundColor(.white)
                            }
                            Text("Male")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top,5)
                        }
                        
                        Spacer()
                        VStack{
                            Button(action: {
                                gender = .female
                            }) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .background(gender == .female ? Color.pink : Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                                    .foregroundColor(.white)
                            }
                            Text("Female")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top,5)
                        }
                    }
                    
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Age Input
                VStack(alignment: .center, spacing: 8) {
                    Text("Age")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.bottom)
                    HStack(spacing: 10) {
                        Button(action: {
                            if age > 1 { age -= 1 }
                        }) {
                            Text("-")
                                .font(.title)
                                .frame(width: 30, height: 30)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        
                        Text("\(age)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Button(action: {
                            age += 1
                        }) {
                            Text("+")
                                .font(.title)
                                .frame(width: 30, height: 30)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
            }
            // Height Slider
            VStack(alignment: .center, spacing: 8) {
                Text("Height (in)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(Int(height))")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Slider(value: $height, in: 36...96, step: 1) // Height range: 3ft to 8ft
                    .accentColor(.green)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)

            // Weight Slider
            VStack(alignment: .center, spacing: 8) {
                Text("Weight (lbs)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(Int(weight))")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Slider(value: $weight, in: 50...300, step: 1) // Weight range: 50lbs to 300lbs
                    .accentColor(.green)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)

            // BMI Calculation Button
            Button(action: calculateBMI) {
                Text("BMI")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.pink)
                    .cornerRadius(15)
            }
            .padding()

            // Display BMI Value
            if let calculatedBMI = bmi {
                VStack {
                    Text("Your BMI")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(String(format: "%.2f", calculatedBMI))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(calculatedBMI < 18.5 || calculatedBMI > 24.9 ? .red : .green)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
            }

            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    // Function to calculate BMI
    private func calculateBMI() {
        let heightInMeters = height * 0.0254 // Convert height to meters
        let weightInKg = weight * 0.453592 // Convert weight to kg
        bmi = weightInKg / (heightInMeters * heightInMeters)
    }
}

// Enum for Gender
enum Gender {
    case male, female

    var isMale: Bool {
        get {
            self == .male
        }
        set {
            self = newValue ? .male : .female
        }
    }
}

// Preview
struct BodyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        BodyInfoView()
            .preferredColorScheme(.dark)
    }
}
