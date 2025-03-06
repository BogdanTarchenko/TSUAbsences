import SwiftUI

struct GroupSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = GroupSelectionViewModel()
    let onSelect: (Int) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.groups.filter { !$0.isDeleted }) { group in
                                Button(action: {
                                    onSelect(group.groupNumber)
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    HStack {
                                        Text(group.groupNumber.groupString)
                                            .foregroundColor(Color(hex: "346CB0"))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Выберите группу")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchGroups()
        }
    }
} 