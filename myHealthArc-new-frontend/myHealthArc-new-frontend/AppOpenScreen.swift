//
//  AppOpenScreen.swift
//  myHealthArc-new-frontend
//
//  Created by Anjali Hole on 10/17/24.
//

//should only show up once, when the app is opened for the first time after download
import SwiftUI

struct AppOpenScreen: View {
    @Binding var isLoggedIn: Bool
    @Binding var hasSignedUp: Bool
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
                NavigationLink(destination: SignUpView(isLoggedIn: $isLoggedIn, hasSignedUp:$hasSignedUp)) {
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
        .accentColor(.mhaPurple)
    }
}


struct AppOpenScreen_Previews: PreviewProvider {
    static var previews: some View {
        // @Previewable
        @State var isLoggedIn: Bool = false
        @State var hasSignedUp: Bool = false
        AppOpenScreen(isLoggedIn: $isLoggedIn, hasSignedUp:$hasSignedUp)
    }
}
