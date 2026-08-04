import Foundation

enum WishlistAmountFormatter {
    static func parse(_ text: String, locale: Locale = .current) -> Double? {
        let decimalSeparator = locale.decimalSeparator ?? "."
        let groupingSeparator = locale.groupingSeparator ?? ","
        let currencySymbol = locale.currencySymbol ?? ""

        var normalized = text
        if !currencySymbol.isEmpty {
            normalized = normalized.replacingOccurrences(of: currencySymbol, with: "")
        }
        normalized = normalized
            .replacingOccurrences(of: "\u{00A0}", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: groupingSeparator, with: "")

        if decimalSeparator != "." {
            normalized = normalized.replacingOccurrences(of: decimalSeparator, with: ".")
        }

        return Double(normalized.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    static func format(_ value: Double, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}
