import SwiftUI

struct MainScreen: View {
    @StateObject private var viewModel = MainScreenViewModel()
    
    var body: some View {
        TabView {
            ProfileScreen()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
            
            if case .teacher = viewModel.userRole {
                RequestsScreen()
                    .tabItem {
                        Image(systemName: "doc.text.fill")
                        Text("Заявки")
                    }
            }
            
            if case .student = viewModel.userRole {
                StudentRequestsScreen()
                    .tabItem {
                        Image(systemName: "doc.text.fill")
                        Text("Мои заявки")
                    }
            }
        }
        .accentColor(Color(hex: "346CB0"))
        .onAppear {
            viewModel.fetchUserRole()
        }
    }
} 
