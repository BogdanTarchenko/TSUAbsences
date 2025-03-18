import SwiftUI
import PhotosUI

struct ExtendRequestView: View {
    @ObservedObject var viewModel: StudentRequestsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                if let request = viewModel.selectedRequestForExtend {
                    Section("Информация о заявке") {
                        Text("Заявка #\(request.id.prefix(8))")
                            .font(.subheadline)
                        
                        Text("Текущий период: \(request.dateStart.formattedPeriod(to: request.dateEnd))")
                            .font(.subheadline)
                    }
                    
                    Section("Новая дата окончания") {
                        RussianDatePicker(selection: $viewModel.extendRequestDateEnd, label: "Дата окончания", displayedComponents: .date)
                            .onChange(of: viewModel.extendRequestDateEnd) { newValue in
                                if newValue < request.dateEnd {
                                    viewModel.extendRequestDateEnd = request.dateEnd
                                }
                            }
                    }
                    
                    Section("Причина продления") {
                        TextEditor(text: $viewModel.extendRequestMessage)
                            .frame(minHeight: 100)
                    }
                    
                    Section(header: Text("Файлы *"), footer: Text("Необходимо прикрепить хотя бы один файл")) {
                        Button {
                            showingImagePicker = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Добавить файл")
                            }
                        }
                        
                        if !viewModel.extendSelectedImages.isEmpty {
                            Text("Файлы будут автоматически сжаты перед отправкой")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(0..<viewModel.extendSelectedImages.count, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            VStack {
                                                Image(uiImage: viewModel.extendSelectedImages[index])
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 100)
                                                    .cornerRadius(8)
                                                
                                                if let size = viewModel.extendSelectedImages[index].jpegData(compressionQuality: 0.5)?.count {
                                                    Text("\(formatFileSize(size))")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            
                                            Button {
                                                viewModel.removeExtendImage(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white.clipShape(Circle()))
                                            }
                                            .padding(4)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if viewModel.extendSelectedImages.isEmpty {
                            Text("Файлы не выбраны")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Продление заявки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.extendRequest()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Продлить")
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .alert("Ошибка", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker { image in
                    if let image = image {
                        viewModel.addExtendImage(image)
                    }
                }
            }
        }
    }
    
    private func formatFileSize(_ size: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
} 
