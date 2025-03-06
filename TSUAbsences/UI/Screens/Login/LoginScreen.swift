import SwiftUI

struct LoginScreen: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Вход")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "346CB0"))
                    .padding(.bottom, 20)
                
                CustomTextField(placeholder: "Email", text: $viewModel.email, isRequired: true)
                CustomTextField(placeholder: "Пароль", text: $viewModel.password, isSecure: true, isRequired: true)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                CustomButton(title: "Войти", action: viewModel.login)
                    .disabled(viewModel.isLoading)
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "346CB0"))
                }
            }
        }
    }
} 
