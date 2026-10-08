import Foundation

enum WishlistAmountFormatter {
    static var appLocale: Locale {
        let language = Bundle.main.preferredLocalizations.first ?? "en"
        return language.hasPrefix("de") ? Locale(identifier: "de_DE") : Locale(identifier: "en_US")
    }

    static func parse(_ text: String, locale: Locale = WishlistAmountFormatter.appLocale) -> Double? {
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

    static func format(_ value: Double, locale: Locale = WishlistAmountFormatter.appLocale) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    static func currencyString(_ value: Double, locale: Locale = WishlistAmountFormatter.appLocale) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: value)) ?? format(value, locale: locale)
    }
}
