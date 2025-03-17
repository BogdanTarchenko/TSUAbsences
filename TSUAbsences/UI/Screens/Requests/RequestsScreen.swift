import SwiftUI

struct RequestsScreen: View {
    @StateObject private var viewModel = RequestsViewModel()
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.requests.isEmpty {
                    ProgressView()
                } else {
                    List {
                        ForEach(viewModel.requests) { request in
                            RequestRow(request: request)
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
            .navigationTitle("Заявки")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                RequestsFilterView(filter: $viewModel.filter)
                    .onDisappear {
                        Task {
                            await viewModel.applyFilter()
                        }
                    }
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
}

struct RequestRow: View {
    let request: ShortPassRequestDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(request.user.fullName)
                    .font(.headline)
                Spacer()
                Text(request.isAccepted ? "Принято" : "На рассмотрении")
                    .foregroundColor(request.isAccepted ? .green : .orange)
            }
            
            Text("Роль: \(request.user.role.rawValue)")
                .font(.subheadline)
            
            Text("Период: \(request.dateStart.formatted(date: .long, time: .omitted)) - \(request.dateEnd.formatted(date: .long, time: .omitted))")
                .font(.subheadline)
            
            if !request.minioFiles.isEmpty {
                Text("Прикрепленные файлы: \(request.minioFiles.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !request.extendPassTimeRequests.isEmpty {
                Text("Запросы на продление: \(request.extendPassTimeRequests.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
} 
