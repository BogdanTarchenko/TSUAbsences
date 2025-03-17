import Foundation

extension Date {
    func formattedInRussian(dateStyle: DateFormatter.Style = .long, timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
    
    func formattedPeriod(to endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        return "\(formatter.string(from: self)) - \(formatter.string(from: endDate))"
    }
} 