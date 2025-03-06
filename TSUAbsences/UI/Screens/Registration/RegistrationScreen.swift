import SwiftUI

struct RegistrationScreen: View {
    @StateObject private var viewModel = RegistrationViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showGroupSelection = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Регистрация")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "346CB0"))
                        .padding(.bottom, 20)
                    
                    CustomTextField(placeholder: "ФИО", text: $viewModel.fullName, isRequired: true)
                    CustomTextField(placeholder: "Email", text: $viewModel.email, isRequired: true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Группа")
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showGroupSelection = true
                        }) {
                            HStack {
                                Text(viewModel.groupNumberText.isEmpty ? "Выберите группу" : viewModel.groupNumberText)
                                    .foregroundColor(viewModel.groupNumberText.isEmpty ? .gray : .black)
                                Spacer()
                                if !viewModel.groupNumberText.isEmpty {
                                    Button(action: {
                                        viewModel.groupNumberText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    
                    CustomTextField(placeholder: "Пароль", text: $viewModel.password, isSecure: true, isRequired: true)
                    CustomTextField(placeholder: "Подтвердите пароль", text: $viewModel.confirmPassword, isSecure: true, isRequired: true)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    CustomButton(title: "Зарегистрироваться", action: viewModel.register)
                        .disabled(viewModel.isLoading)
                    
                    if viewModel.isLoading {
                        ProgressView()
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
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
        .sheet(isPresented: $showGroupSelection) {
            GroupSelectionView { selectedGroup in
                viewModel.groupNumberText = String(selectedGroup)
            }
        }
    }
} 