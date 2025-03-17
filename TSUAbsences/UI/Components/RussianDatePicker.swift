import SwiftUI

struct RussianDatePicker: View {
    @Binding var selection: Date
    var label: String
    var displayedComponents: DatePickerComponents = .date
    
    var body: some View {
        DatePicker(
            label,
            selection: $selection,
            displayedComponents: displayedComponents
        )
        .environment(\.locale, Locale(identifier: "ru_RU"))
    }
} 