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
    
    var wishlistID: UUID

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Details").wishlistImageLabelStyle(settings, fallbackColor: .secondary)) {
                    TextField("Name", text: $name)
                        .listRowBackground(WishlistElementBackground(opacity: settings.elementOpacity))
                    TextField("Remark", text: $remark)
                        .listRowBackground(WishlistElementBackground(opacity: settings.elementOpacity))
                    TextField("Link", text: $link)
                        .listRowBackground(WishlistElementBackground(opacity: settings.elementOpacity))
                    TextField("Price", text: $priceString)
                        .listRowBackground(WishlistElementBackground(opacity: settings.elementOpacity))
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button(action: {
                        addWish()
                    }) {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                    .listRowBackground(WishlistElementBackground(opacity: settings.elementOpacity))
                }
            }
            .scrollContentBackground(.hidden)
            .alert("Invalid URL!", isPresented: $showInvalidLinkAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a valid URL.")
            }
        }
        // Apply new background if settings are available
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .wishlistBackground(settings)
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

            // shortcut: Keep legacy item models readable until a versioned data migration can unify them.
            let newWish = ShortItems(
                name: name,
                remark: remark,
                link: link,
                price: price,
                wishlistID: wishlistID
            )
            modelContext.insert(newWish)
            hideKeyboard()
            dismiss()
        }
    }
    
    func parseAmount(_ string: String) -> Double? {
        WishlistAmountFormatter.parse(string)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
