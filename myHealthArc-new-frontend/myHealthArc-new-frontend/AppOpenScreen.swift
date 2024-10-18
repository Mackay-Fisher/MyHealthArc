//
//  AppOpenScreen.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//

//should only show up once, when the app is opened for the first time after download
import SwiftUI

struct AppOpenScreen: View {
    @State private var isLoggedIn = false
    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                
                Text("myHealthArc")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.top, -20)
                    .padding(.bottom, 30)
                
                //Spacer()
                
                // Sign Up Button
                NavigationLink(destination: SignUpView()) {
                    Text("Sign Up")
                        .frame(width: 150, height: 50)
                        .background(Color(hex: "#C197D2"))
                        .cornerRadius(50)
                        .foregroundColor(.white)
                        .padding(.top)
                }
                
                // "I already have an account" link
                NavigationLink(destination: LoginView(isLoggedIn: $isLoggedIn)) {
                    Text("I already have an account")
                        .foregroundColor(Color(hex: "#C197D2"))
                        .padding(.top, 10)
                }
                
                Spacer()
            }
        }
    }
}


struct AppOpenScreen_Previews: PreviewProvider {
    static var previews: some View {
        AppOpenScreen()
    }
}
