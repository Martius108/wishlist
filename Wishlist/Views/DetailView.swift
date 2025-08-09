//
//  DetailView.swift
//  Wishlist
//
//  Created by Martin Lanius on 10.05.25.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    
    // Include modelContext and colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.dismiss) private var dismiss
    // Binding to the settings object
    @Bindable var settings: MySettings

    var shortItem: ShortItems?
    var midItem: MidItems?
    var longItem: LongItems?
    
    @State private var name: String = ""
    @State private var remark: String = ""
    @State private var link: String = ""
    @State private var priceString: String = ""
    
    var body: some View {
        VStack {
            if let item = shortItem {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Name:")
                        .foregroundColor(
                            settings.themeMode == "dark" ? .white :
                            settings.themeMode == "light" ? .black :
                            .primary
                        )
                    TextField("Name", text: $name)
                        .roundedTextField()

                    Text("Remark:")
                        .foregroundColor(
                            settings.themeMode == "dark" ? .white :
                            settings.themeMode == "light" ? .black :
                            .primary
                        )
                    TextField("Remark", text: $remark)
                        .roundedTextField()

                    Text("URL:")
                        .foregroundColor(
                            settings.themeMode == "dark" ? .white :
                            settings.themeMode == "light" ? .black :
                            .primary
                        )
                    TextField("URL", text: $link)
                        .roundedTextField()

                    Text("Price:")
                        .foregroundColor(
                            settings.themeMode == "dark" ? .white :
                            settings.themeMode == "light" ? .black :
                            .primary
                        )
                    TextField("Price", text: $priceString)
                        .keyboardType(.decimalPad)
                        .roundedTextField()

                    ShareLink(item: link) {
                        Label("Share URL", systemImage: "square.and.arrow.up")
                            .padding(.top, 10)
                            .padding(.bottom, 15)
                    }

                    HStack {
                        Button("Save") {
                            item.name = name
                            item.remark = remark
                            item.link = link
                            if let priceValue = parseAmount(priceString) {
                                item.price = priceValue
                            }
                            dismiss()
                        }
                        Spacer()
                        Button(role: .destructive) {
                            modelContext.delete(item)
                            dismiss()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .padding(.bottom, 20)
                }
                .cardStyle()
                .onAppear {
                    name = item.name
                    remark = item.remark
                    link = item.link
                    priceString = formatAmountForEditing(item.price)
                }
                Spacer()
            } else if let item = midItem {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Name:")
                        .foregroundColor(
                            settings.themeMode == "dark" ? .white :
                            settings.themeMode == "light" ? .black :
                            .primary
                        )
                    TextField("Name", text: $name)
                        .roundedTextField()

                    Text("Remark:")
                        .foregroundColor(
                            settings.themeMode == "dark" ? .white :
                            settings.themeMode == "light" ? .black :
                            .primary
                        )
                    TextField("Remark", text: $remark)
                        .roundedTextField()

                    Text("URL:")
                        .foregroundColor(
                            settings.themeMode == "dark" ? .white :
                            settings.themeMode == "light" ? .black :
                            .primary
                        )
                    TextField("URL", text: $link)
                        .roundedTextField()

                    Text("Price:")
                        .foregroundColor(
                            settings.themeMode == "dark" ? .white :
                            settings.themeMode == "light" ? .black :
                            .primary
                        )
                    TextField("Price", text: $priceString)
                        .keyboardType(.decimalPad)
                        .roundedTextField()

                    ShareLink(item: link) {
                        Label("Share URL", systemImage: "square.and.arrow.up")
                            .padding(.top, 10)
                            .padding(.bottom, 15)
                    }

                    HStack {
                        Button("Save") {
                            item.name = name
                            item.remark = remark
                            item.link = link
                            if let priceValue = parseAmount(priceString) {
                                item.price = priceValue
                            }
                            dismiss()
                        }
                        Spacer()
                        Button(role: .destructive) {
                            modelContext.delete(item)
                            dismiss()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .padding(.bottom, 20)
                }
                .cardStyle()
                .onAppear {
                    name = item.name
                    remark = item.remark
                    link = item.link
                    priceString = formatAmountForEditing(item.price)
                }
                Spacer()
            } else if let item = longItem {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Name:")
                        .foregroundColor(
                            settings.themeMode == "dark" ? .white :
                            settings.themeMode == "light" ? .black :
                            .primary
                        )
                    TextField("Name", text: $name)
                        .roundedTextField()

                    Text("Remark:")
                        .foregroundColor(
                            settings.themeMode == "dark" ? .white :
                            settings.themeMode == "light" ? .black :
                            .primary
                        )
                    TextField("Remark", text: $remark)
                        .roundedTextField()

                    Text("URL:")
                        .foregroundColor(
                            settings.themeMode == "dark" ? .white :
                            settings.themeMode == "light" ? .black :
                            .primary
                        )
                    TextField("URL", text: $link)
                        .roundedTextField()

                    Text("Price:")
                        .foregroundColor(
                            settings.themeMode == "dark" ? .white :
                            settings.themeMode == "light" ? .black :
                            .primary
                        )
                    TextField("Price", text: $priceString)
                        .keyboardType(.decimalPad)
                        .roundedTextField()

                    ShareLink(item: link) {
                        Label("Share URL", systemImage: "square.and.arrow.up")
                            .padding(.top, 10)
                            .padding(.bottom, 15)
                    }

                    HStack {
                        Button("Save") {
                            item.name = name
                            item.remark = remark
                            item.link = link
                            guard let priceValue = parseAmount(priceString) else { return }
                            item.price = priceValue
                            dismiss()
                        }
                        Spacer()
                        Button(role: .destructive) {
                            modelContext.delete(item)
                            dismiss()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .padding(.bottom, 20)
                }
                .cardStyle()
                .onAppear {
                    name = item.name
                    remark = item.remark
                    link = item.link
                    priceString = formatAmountForEditing(item.price)
                }
            } else {
                Text("No entry found.")
            }
            Spacer()
        }
        // Apply new background if settings are available
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: settings.backgroundColor))
    }
    
    func parseAmount(_ string: String) -> Double? {
        let locale = Locale.current
        let decimalSep = locale.decimalSeparator ?? "."
        let groupSep = locale.groupingSeparator ?? ","
        let currencySym = locale.currencySymbol ?? ""

        var s = string
        // Remove currency symbol and spaces
        if !currencySym.isEmpty { s = s.replacingOccurrences(of: currencySym, with: "") }
        s = s.replacingOccurrences(of: "\u{00A0}", with: "") // non-breaking space
        s = s.replacingOccurrences(of: " ", with: "")
        // Remove grouping separators
        s = s.replacingOccurrences(of: groupSep, with: "")
        // Normalize decimal separator to '.' for Double init
        if decimalSep != "." { s = s.replacingOccurrences(of: decimalSep, with: ".") }
        // Trim
        s = s.trimmingCharacters(in: .whitespacesAndNewlines)

        return Double(s)
    }

    /// Formats a Double for editing (no currency symbol, localized decimal/grouping)
    func formatAmountForEditing(_ value: Double) -> String {
        let f = NumberFormatter()
        f.locale = Locale.current
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: value)) ?? String(value)
    }
}
