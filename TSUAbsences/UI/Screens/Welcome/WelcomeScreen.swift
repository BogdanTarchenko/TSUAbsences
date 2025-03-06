import SwiftUI

struct WelcomeScreen: View {
    @StateObject private var viewModel = WelcomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("backgroundImageTSU")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                Color.white
                    .opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("Добро пожаловать")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "346CB0"))
                    
                    Text("в систему учета пропусков ТГУ")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "346CB0"))
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        NavigationLink {
                            LoginScreen()
                        } label: {
                            Text("Войти")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 350, height: 50)
                                .background(Color(hex: "346CB0"))
                                .cornerRadius(10)
                        }

                        NavigationLink {
                            RegistrationScreen()
                        } label: {
                            Text("Зарегистрироваться")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 350, height: 50)
                                .background(Color(hex: "346CB0"))
                                .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
} 
