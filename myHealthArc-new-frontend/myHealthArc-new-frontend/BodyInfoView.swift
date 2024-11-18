import SwiftUI

struct BodyInfoView: View {
    let containerHeight: CGFloat // Height passed from the parent view

    @Binding var height: Double // Dynamic height (in inches)
    @Binding var weight: Double // Dynamic weight (in pounds)
    @Binding var age: Int       // Dynamic age
    @State private var gender: Gender = .male // Default gender
    @State private var bmi: Double?           // BMI value (calculated)
    @State private var showPopup: Bool = false // Control popup visibility

    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 20) {
                // Gender Toggle
                HStack(alignment: .center) {
                    VStack(alignment: .center, spacing: 8) {
                        HStack {
                            VStack {
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
                                    .padding(.top, 5)
                            }

                            Spacer()

                            VStack {
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
                                    .padding(.top, 5)
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
                                .font(.system(size: UIFontMetrics.default.scaledValue(for: 40), weight: .bold, design: .rounded))
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
                        .font(.system(size: UIFontMetrics.default.scaledValue(for: 40), weight: .bold, design: .rounded))
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
                        .font(.system(size: UIFontMetrics.default.scaledValue(for: 40), weight: .bold, design: .rounded))
                    Slider(value: $weight, in: 50...300, step: 1) // Weight range: 50lbs to 300lbs
                        .accentColor(.green)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)

                // BMI Calculation Button
                Button(action: {
                    calculateBMI()
                    showPopup = true // Show the popup
                }) {
                    Text("Calculate BMI")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .cornerRadius(15)
                }
                .padding()
            }
            .frame(height: containerHeight) // Adjust height dynamically

            // Popup Overlay
            if showPopup {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all) // Background overlay
                    .onTapGesture {
                        showPopup = false // Dismiss the popup when tapped outside
                    }

                VStack(spacing: 15) {
                    Text("Your BMI")
                        .font(.headline)
                        .foregroundColor(.white)

                    if let calculatedBMI = bmi {
                        Text(String(format: "%.2f kg/m²", calculatedBMI))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(calculatedBMI < 18.5 || calculatedBMI > 24.9 ? .red : .green)

                        Text(calculatedBMI < 18.5 ? "(Underweight)" :
                             calculatedBMI > 24.9 ? "(Overweight)" :
                             "(Normal)")
                            .font(.title3)
                            .foregroundColor(.white)

                        Text("A BMI of 18.5 - 24.9 indicates that you are at a healthy weight for your height. By maintaining a healthy weight, you lower your risk of developing serious health problems.")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }

                    Button(action: {
                        showPopup = false // Dismiss popup on button press
                    }) {
                        Text("Close")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(15)
                    }
                }
                .padding()
                .frame(maxWidth: 300)
                .background(Color.pink)
                .cornerRadius(20)
                .shadow(radius: 10)
            }
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
    @State static var height: Double = 63
    @State static var weight: Double = 115
    @State static var age: Int = 22

    static var previews: some View {
        BodyInfoView(containerHeight: 600, height: $height, weight: $weight, age: $age)
            .preferredColorScheme(.dark)
    }
}
