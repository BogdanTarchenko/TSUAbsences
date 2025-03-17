import SwiftUI

struct RequestsFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filter: RequestsFilter
    
    @State private var userSearchString: String = ""
    @State private var dateStart: Date?
    @State private var dateEnd: Date?
    @State private var isAccepted: Bool?
    
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
    
    private var isAcceptedBinding: Binding<Bool?> {
        Binding(
            get: { isAccepted },
            set: { isAccepted = $0 }
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
                isAccepted = filter.isAccepted
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
            Picker("Статус", selection: isAcceptedBinding) {
                Text("Все").tag(Optional<Bool>.none)
                Text("Принятые").tag(Optional<Bool>.some(true))
                Text("На рассмотрении").tag(Optional<Bool>.some(false))
            }
        }
    }
    
    private func resetFilters() {
        userSearchString = ""
        dateStart = nil
        dateEnd = nil
        isAccepted = nil
    }
    
    private func applyFilters() {
        filter = RequestsFilter(
            userSearchString: userSearchString.isEmpty ? nil : userSearchString,
            dateStart: dateStart,
            dateEnd: dateEnd,
            isAccepted: isAccepted
        )
        dismiss()
    }
} 
