import SwiftUI
import PhotosUI

struct StudentRequestsScreen: View {
    @StateObject private var viewModel = StudentRequestsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.requests.isEmpty {
                    ProgressView()
                } else {
                    VStack {
                        statusPicker
                        
                        List {
                            ForEach(viewModel.requests) { request in
                                StudentRequestRow(request: request, onExtend: { request in
                                    viewModel.prepareForExtend(request: request)
                                })
                                .swipeActions {
                                    if !request.isAccepted {
                                        Button(role: .destructive) {
                                            Task {
                                                await viewModel.deleteRequest(id: request.id)
                                            }
                                        } label: {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            
                            if viewModel.hasMorePages {
                                ProgressView()
                                    .onAppear {
                                        Task {
                                            await viewModel.loadRequests()
                                        }
                                    }
                            }
                        }
                        .refreshable {
                            await viewModel.loadRequests(forceRefresh: true)
                        }
                    }
                }
            }
            .navigationTitle("Мои заявки")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingCreateForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateForm) {
                CreateRequestView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingExtendForm) {
                ExtendRequestView(viewModel: viewModel)
            }
            .alert("Ошибка", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
            .task {
                await viewModel.loadRequests(forceRefresh: true)
            }
        }
    }
    
    private var statusPicker: some View {
        Picker("Статус", selection: $viewModel.selectedStatus) {
            ForEach(StudentRequestsViewModel.RequestStatus.allCases) { status in
                Text(status.rawValue).tag(status)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .onChange(of: viewModel.selectedStatus) { _ in
            Task {
                await viewModel.loadRequests(forceRefresh: true)
            }
        }
    }
}

struct StudentRequestRow: View {
    let request: ShortPassRequestDTO
    var onExtend: (ShortPassRequestDTO) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Заявка #\(request.id.prefix(8))")
                    .font(.headline)
                Spacer()
                Text(request.isAccepted ? "Принято" : "На рассмотрении")
                    .foregroundColor(request.isAccepted ? .green : .orange)
            }
            
            Text("Период: \(request.dateStart.formattedPeriod(to: request.dateEnd))")
                .font(.subheadline)
            
            if let message = request.message, !message.isEmpty {
                Text("Сообщение: \(message)")
                    .font(.subheadline)
            }
            
            Text("Создано: \(request.createTimestamp.formattedInRussian(dateStyle: .medium, timeStyle: .short))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !request.minioFiles.isEmpty {
                Text("Прикрепленные файлы: \(request.minioFiles.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !request.extendPassTimeRequests.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Запросы на продление:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(request.extendPassTimeRequests, id: \.id) { extendRequest in
                        HStack {
                            Text("До \(extendRequest.dateEnd.formattedInRussian())")
                                .font(.caption)
                            
                            Spacer()
                            
                            Text(extendRequest.isAccepted ? "Принято" : "На рассмотрении")
                                .font(.caption)
                                .foregroundColor(extendRequest.isAccepted ? .green : .orange)
                        }
                        .padding(.leading, 8)
                    }
                }
            }
            
            if request.isAccepted {
                Button {
                    onExtend(request)
                } label: {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text("Продлить")
                    }
                    .foregroundColor(.blue)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
}

struct CreateRequestView: View {
    @ObservedObject var viewModel: StudentRequestsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Период") {
                    RussianDatePicker(selection: $viewModel.newRequestDateStart, label: "Начальная дата", displayedComponents: .date)
                        .onChange(of: viewModel.newRequestDateStart) { newValue in
                            if newValue > viewModel.newRequestDateEnd {
                                viewModel.newRequestDateEnd = newValue
                            }
                        }
                    
                    RussianDatePicker(selection: $viewModel.newRequestDateEnd, label: "Конечная дата", displayedComponents: .date)
                        .onChange(of: viewModel.newRequestDateEnd) { newValue in
                            if newValue < viewModel.newRequestDateStart {
                                viewModel.newRequestDateStart = newValue
                            }
                        }
                }
                
                Section("Сообщение") {
                    TextEditor(text: $viewModel.newRequestMessage)
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
                    
                    if !viewModel.selectedImages.isEmpty {
                        Text("Файлы будут автоматически сжаты перед отправкой")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0..<viewModel.selectedImages.count, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        VStack {
                                            Image(uiImage: viewModel.selectedImages[index])
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 100)
                                                .cornerRadius(8)
                                            
                                            if let size = viewModel.selectedImages[index].jpegData(compressionQuality: 0.5)?.count {
                                                Text("\(formatFileSize(size))")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Button {
                                            viewModel.removeImage(at: index)
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
                    
                    if viewModel.selectedImages.isEmpty {
                        Text("Файлы не выбраны")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Новая заявка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if viewModel.selectedImages.isEmpty {
                            viewModel.error = NetworkError.serverError("Необходимо прикрепить хотя бы один файл")
                        } else {
                            Task {
                                await viewModel.createRequest()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Создать")
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker { image in
                    if let image = image {
                        viewModel.addImage(image)
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

struct ImagePicker: UIViewControllerRepresentable {
    var onImagePicked: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else {
                parent.onImagePicked(nil)
                return
            }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        self.parent.onImagePicked(image as? UIImage)
                    }
                }
            }
        }
    }
} 
