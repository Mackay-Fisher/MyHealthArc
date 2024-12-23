import SwiftUI
import SwiftKeychainWrapper

struct BodyInfoView: View {

    @Binding var height: Double // Dynamic height (in inches)
    @Binding var weight: Double // Dynamic weight (in pounds)
    @Binding var age: Int       // Dynamic age
    @State private var gender: Gender = .male // Default gender
    @State private var bmi: Double?           // BMI value (calculated)
    @State private var showPopup: Bool = false // Control popup visibility
    let userHash = KeychainWrapper.standard.string(forKey: "userHash")
    @State private var isLoading: Bool = false // Track loading state
    @Environment(\.colorScheme) var colorScheme

    enum Gender: String, Codable {
        case male, female
    }

    var body: some View {
        ScrollView {
            ZStack {
                VStack(spacing: 20) {
                    // Gender Toggle
                    HStack(alignment: .center) {
                        // Gender Toggle
                        VStack(alignment: .center, spacing: 8) {
                            HStack {
                                GenderToggle(gender: $gender, selected: .male)
                                Spacer()
                                GenderToggle(gender: $gender, selected: .female)
                            }
                        }
                        .padding()
                        .frame(minHeight: 100) // Set minimum height for consistency
                        .background(Color(.systemGray6))
                        .cornerRadius(15)

                        // Age Input
                        AgeInput(age: $age)
                    }
                    
                    // Height Slider
                    SliderInput(title: "Height (in)", value: $height, range: 36...96)
                    
                    // Weight Slider
                    SliderInput(title: "Weight (lbs)", value: $weight, range: 50...300)
                    
                    // BMI Calculation Button
                    Button(action: {
                        calculateBMI()
                        showPopup = true
                    }) {
                        Text("Calculate BMI")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.mhaSalmon)
                            .cornerRadius(20)
                    }
                    .padding()
                }
                .onAppear {
                    Task { await loadBodyData() }
                }
                .onDisappear {
                    Task { await updateBodyData() }
                }
                
                // Loading State
                if isLoading {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                }
                
                // Popup Overlay
                if showPopup {
                    PopupOverlay(bmi: bmi) { showPopup = false }
                }
            }
            .padding()
            .background(colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all))
        }
    }

    // MARK: - BMI Calculation
    private func calculateBMI() {
        let heightInMeters = height * 0.0254
        let weightInKg = weight * 0.453592
        bmi = weightInKg / (heightInMeters * heightInMeters)
    }

    // MARK: - Load Body Data
    private func loadBodyData() async {
        guard let userHash = userHash else {
            print("User hash is nil.")
            return
        }
        
        guard let url = URL(string: "\(AppConfig.baseURL)/bodyData/load?userHash=\(userHash)") else {
            print("Invalid URL")
            return
        }

        print(url)
        isLoading = true
        defer { isLoading = false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(BodyDataPayload.self, from: data)
            DispatchQueue.main.async {
                print(response)
                self.height = response.height
                self.weight = response.weight
                self.age = response.age
                self.gender = response.gender == "male" ? .male : .female
                self.bmi = response.bmi
            }
        } catch {
            print("Failed to load body data:", error.localizedDescription)
        }
    }


    // MARK: - Update Body Data
    // Function to update body data
    private func updateBodyData() async{
        guard let url = URL(string: "\(AppConfig.baseURL)/bodyData/update") else {
            print("Invalid URL")
            return
        }

        let payload = BodyDataPayload(
            userHash: userHash,
            height: height,
            weight: weight,
            age: age,
            gender: gender == .male ? "male" : "female",
            bmi: bmi
        )

        Task {
            do {
                // Encode the payload
                let jsonData = try JSONEncoder().encode(payload)

                // Log the JSON payload before sending
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("POST Request Payload:")
                    print(jsonString)
                }

                // Configure the POST request
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData

                // Perform the request
                let (responseData, response) = try await URLSession.shared.data(for: request)

                // Log the HTTP response
                if let httpResponse = response as? HTTPURLResponse {
                    print("POST Response Status Code: \(httpResponse.statusCode)")
                }

                // Log the response body
                if let responseString = String(data: responseData, encoding: .utf8) {
                    print("POST Response Body:")
                    print(responseString)
                }

            } catch {
                // Log any errors
                print("Failed to update body data:", error.localizedDescription)
            }
        }
    }

}

// MARK: - Subviews
struct GenderToggle: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var gender: BodyInfoView.Gender
    let selected: BodyInfoView.Gender

    var body: some View {
        VStack{
            Button(action: { gender = selected }) {
                Image(systemName: selected == .male ? "person.fill" : "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .padding()
                    .background(gender == selected ? Color.mhaSalmon : Color.gray.opacity(0.2))
                    .clipShape(Circle())
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            Text(selected == .male ? "Male" : "Female")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.top, 5)
        }
    }
}

struct AgeInput: View {
    @Binding var age: Int
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Age")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.bottom)
            HStack(spacing: 10) {
                Button(action: { if age > 1 { age -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.mhaSalmon)
                        .font(.title2)
                }

                Text("\(age)")
                    .font(.system(size: UIFontMetrics.default.scaledValue(for: 30), weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Button(action: { age += 1 }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.mhaSalmon)
                        .font(.title2)
                }
            }
        }
        .padding()
        .frame(minHeight: 127)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct SliderInput: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Text("\(Int(value))")
                .font(.system(size: UIFontMetrics.default.scaledValue(for: 40), weight: .bold, design: .rounded))
            Slider(value: $value, in: range, step: 1)
                .accentColor(.mhaGreen)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct PopupOverlay: View {
    let bmi: Double?
    let onClose: () -> Void
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
//        Color.black.opacity(0.12)
//            .edgesIgnoringSafeArea(.all)
//            .onTapGesture { onClose() }

        VStack(spacing: 15) {
            Text("Your BMI")
                .font(.headline)
                .foregroundColor(.white)

            if let calculatedBMI = bmi {
                Text(String(format: "%.2f kg/m²", calculatedBMI))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    //.foregroundColor(calculatedBMI < 18.5 || calculatedBMI > 24.9 ? .red : .green)

                Text(calculatedBMI < 18.5 ? "(Underweight)" :
                     calculatedBMI > 24.9 ? "(Overweight)" :
                     "(Normal)")
                    .font(.title3)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(8)
                    .background(
                            calculatedBMI < 18.5 || calculatedBMI > 24.9 ? Color.red : Color.mhaGreen
                        )
                        .cornerRadius(10)

                Text("A BMI of 18.5 - 24.9 indicates a healthy weight.")
                    .font(.subheadline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("BMI data unavailable.")
                    .font(.title3)
                    .foregroundColor(.gray)
            }

            Button(action: { onClose() }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(20)
            }
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color.mhaSalmon)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// BodyDataPayload struct
struct BodyDataPayload: Codable {
    let userHash: String?
    let height: Double
    let weight: Double
    let age: Int
    let gender: String
    let bmi: Double?
}


// MARK: - Preview
struct BodyInfoView_Previews: PreviewProvider {
    @State static var height: Double = 63
    @State static var weight: Double = 115
    @State static var age: Int = 22

    static var previews: some View {
        BodyInfoView(height: $height, weight: $weight, age: $age)
            .preferredColorScheme(.dark)
    }
}
