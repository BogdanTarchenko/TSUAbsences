import SwiftUI

struct EditProfileScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: EditProfileViewModel
    @State private var showGroupSelection = false
    
    init(profile: UserProfile) {
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(profile: profile))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        CustomTextField(
                            placeholder: "ФИО",
                            text: $viewModel.fullName,
                            isRequired: true
                        )
                        
                        CustomTextField(
                            placeholder: "Email",
                            text: $viewModel.email,
                            isRequired: true
                        )
                        
                        if case .student = viewModel.role {
                            Button(action: { showGroupSelection = true }) {
                                HStack {
                                    Text("Группа")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(viewModel.groupNumberText)
                                        .foregroundColor(Color(hex: "346CB0"))
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        CustomButton(
                            title: "Сохранить",
                            action: {
                                Task {
                                    if await viewModel.saveProfile() {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        )
                        .disabled(viewModel.isLoading)
                        
                        if viewModel.isLoading {
                            ProgressView()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Редактирование профиля")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
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