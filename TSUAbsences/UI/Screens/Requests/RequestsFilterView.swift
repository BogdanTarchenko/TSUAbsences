import SwiftUI

private enum RequestStatus {
    case all
    case accepted
    case rejected
    
    var title: String {
        switch self {
        case .all: return "Все"
        case .accepted: return "Принятые"
        case .rejected: return "Отклоненные"
        }
    }
}

struct RequestsFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filter: RequestsFilter
    
    @State private var userSearchString: String = ""
    @State private var dateStart: Date?
    @State private var dateEnd: Date?
    @State private var selectedStatus: RequestStatus = .all
    
    private var dateStartBinding: Binding<Date> {
        Binding(
            get: { dateStart ?? Date() },
            set: { dateStart = $0 }
        )
    }
    
    private var dateEndBinding: Binding<Date> {
        Binding(
            get: { dateEnd ?? Date() },
            set: { dateEnd = $0 }
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                searchSection
                datesSection
                statusSection
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Сбросить") {
                        resetFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Применить") {
                        applyFilters()
                    }
                }
            }
            .onAppear {
                userSearchString = filter.userSearchString ?? ""
                dateStart = filter.dateStart
                dateEnd = filter.dateEnd
                
                if let isAccepted = filter.isAccepted {
                    selectedStatus = isAccepted ? .accepted : .rejected
                } else {
                    selectedStatus = .all
                }
            }
        }
    }
    
    private var searchSection: some View {
        Section("Поиск") {
            TextField("Поиск по имени", text: $userSearchString)
        }
    }
    
    private var datesSection: some View {
        Section("Даты") {
            RussianDatePicker(selection: dateStartBinding, label: "Начальная дата", displayedComponents: .date)
                .onChange(of: dateStart) { newValue in
                    if let newDate = newValue,
                       let endDate = dateEnd,
                       newDate > endDate {
                        dateEnd = newDate
                    }
                }
            
            RussianDatePicker(selection: dateEndBinding, label: "Конечная дата", displayedComponents: .date)
                .onChange(of: dateEnd) { newValue in
                    if let newDate = newValue,
                       let startDate = dateStart,
                       newDate < startDate {
                        dateStart = newDate
                    }
                }
        }
    }
    
    private var statusSection: some View {
        Section("Статус") {
            Picker("Статус", selection: $selectedStatus) {
                ForEach([RequestStatus.all, .accepted, .rejected], id: \.self) { status in
                    Text(status.title).tag(status)
                }
            }
        }
    }
    
    private func resetFilters() {
        userSearchString = ""
        dateStart = nil
        dateEnd = nil
        selectedStatus = .all
    }
    
    private func applyFilters() {
        let (isAccepted, explicitlyNull): (Bool?, Bool) = {
            switch selectedStatus {
            case .all:
                return (nil, false)
            case .accepted:
                return (true, false)
            case .rejected:
                return (false, false)
            }
        }()
        
        filter = RequestsFilter(
            userSearchString: userSearchString.isEmpty ? nil : userSearchString,
            dateStart: dateStart,
            dateEnd: dateEnd,
            isAccepted: isAccepted,
            isAcceptedExplicitlyNull: explicitlyNull
        )
        dismiss()
    }
} 
