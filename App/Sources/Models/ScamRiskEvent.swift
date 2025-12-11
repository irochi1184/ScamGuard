import Foundation

struct ScamRiskEvent: Identifiable, Hashable {
    let id = UUID()
    let occurredAt: Date
    let message: String

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: occurredAt)
    }
}
