//
//  loginView.swift
//  myHealthArc-frontend
//
//  Created by Anjali Hole on 10/9/24.
//

import SwiftUI

//move this to a common file later
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
}


struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                
            Text("myHealthArc")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.top, -20)
                .padding(.bottom, 30)
                
            
            TextField("Username", text: $username)
                .font(.system(size: 18))
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay( // Black border overlay
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.black, lineWidth: 0.5)
                )
                .padding(.horizontal)
                .frame(width: 250, height: 50)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
            
            
            
            SecureField("Password", text: $password)
                .font(.system(size: 18))
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay( // Black border overlay
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.black, lineWidth: 0.5)
                )
                .padding(.horizontal)
                .frame(width: 250, height: 50)
                .multilineTextAlignment(.center)
                        
            
            Button("Login") {
                // Navigation action to go to the next screen
                //testing if input is being taken
                print("Username: \(username), Password: \(password)")
            }
            //dont allow login button click without input
            .frame(width: 100, height: 50)
            .background(username.isEmpty || password.isEmpty ? Color.gray : Color(hex:"#C197D2"))
            .cornerRadius(50)
            .foregroundColor(.white)
            .padding(.top)
            .disabled(username.isEmpty || password.isEmpty)
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
