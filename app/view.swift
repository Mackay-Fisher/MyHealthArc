import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FirstView()
                .tabItem {
                    Text("Home Page")
                }

            SecondView()
                .tabItem {
                    Text("Prescirptions")
                }

            ThirdView()
                .tabItem {
                    Text("Diet")
                }
        }
    }
}

struct FirstView: View {
    var body: some View {
        Text("Welcome to the Home Tab")
            .padding()
    }
}

struct SecondView: View {
    var body: some View {
        Text("Prescriptions")
            .padding()
    }
}

struct ThirdView: View {
    var body: some View {
        Text("Diet")
            .padding()
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
