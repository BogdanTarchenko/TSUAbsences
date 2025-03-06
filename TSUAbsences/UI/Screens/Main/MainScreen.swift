import SwiftUI

struct MainScreen: View {
    var body: some View {
        TabView {
            Text("Главная")
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }
            
            ProfileScreen()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
        }
        .accentColor(Color(hex: "346CB0"))
    }
} 