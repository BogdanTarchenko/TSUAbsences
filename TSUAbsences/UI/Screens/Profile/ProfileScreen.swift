import SwiftUI

struct ProfileScreen: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading {
                    ProgressView()
                } else if let profile = viewModel.profile {
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color(hex: "346CB0"))
                            
                            VStack(spacing: 10) {
                                Text(profile.fullName)
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                
                                Text(profile.email)
                                    .foregroundColor(.gray)
                                
                                if case .student = profile.role {
                                    if let groupNumber = profile.group?.groupNumber {
                                        Text("Группа \(String(groupNumber))")
                                            .foregroundColor(Color(hex: "346CB0"))
                                    }
                                }
                                
                                Text(profile.role.displayName)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 12)
                                    .background(Color(hex: "346CB0").opacity(0.1))
                                    .cornerRadius(8)
                                
                                if profile.isBlocked {
                                    Text("Аккаунт заблокирован")
                                        .foregroundColor(.red)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 12)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 12) {
                            CustomButton(title: "Редактировать", action: {
                                showEditProfile = true
                            })
                            
                            CustomButton(title: "Выйти", action: viewModel.logout)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Профиль")
            .alert("Ошибка", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Неизвестная ошибка")
            }
            .sheet(isPresented: $showEditProfile) {
                if let profile = viewModel.profile {
                    EditProfileScreen(profile: profile)
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.fetchProfile()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ProfileUpdated"))) { notification in
            if let profile = notification.userInfo?["profile"] as? UserProfile {
                viewModel.profile = profile
            }
        }
    }
}

extension UserRole {
    var displayName: String {
        switch self {
        case .admin:
            return "Администратор"
        case .deanery:
            return "Деканат"
        case .teacher:
            return "Преподаватель"
        case .student:
            return "Студент"
        }
    }
} 
