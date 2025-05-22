//
//  InputView.swift
//  Wishlist
//
//  Created by Martin Lanius on 10.05.25.
//

import SwiftUI
import SwiftData

struct InputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.dismiss) private var dismiss
    // Binding to settings object
    @Bindable var settings: MySettings
    
    @State private var name: String = ""
    @State private var remark: String = ""
    @State private var link: String = ""
    @State private var priceString: String = ""
    @State private var showInvalidLinkAlert = false
    
    var type: WishType

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $name)
                    TextField("Remark", text: $remark)
                    TextField("Link", text: $link)
                    TextField("Price", text: $priceString)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button(action: {
                        addWish()
                    }) {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                }
            }
            .alert("Invalid URL!", isPresented: $showInvalidLinkAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a valid URL.")
            }
        }
        // Apply new background if settings are available
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: settings.backgroundColor))
    }
    
    private func addWish() {
        withAnimation {
            if !link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                guard let url = URL(string: link), UIApplication.shared.canOpenURL(url) else {
                    showInvalidLinkAlert = true
                    return
                }
            }
            guard let price = parseAmount(priceString) else { return }

            switch type {
            case .short:
                let newWish = ShortItems(name: name, remark: remark, link: link, price: price)
                modelContext.insert(newWish)
            case .mid:
                let newWish = MidItems(name: name, remark: remark, link: link, price: price)
                modelContext.insert(newWish)
            case .long:
                let newWish = LongItems(name: name, remark: remark, link: link, price: price)
                modelContext.insert(newWish)
            }
            hideKeyboard()
            dismiss()
        }
    }
    
    func parseAmount(_ string: String) -> Double? {
        Double(string.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces))
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

enum WishType {
    case short, mid, long
}
