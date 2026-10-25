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
    @Query(sort: \WishlistList.sortOrder) private var wishlists: [WishlistList]
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
        ScrollView {
            if let item = shortItem {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Name:")
                        .foregroundStyle(.primary)
                    TextField("Name", text: $name)
                        .roundedTextField()

                    Text("Remark:")
                        .foregroundStyle(.primary)
                    TextField("Remark", text: $remark)
                        .roundedTextField()

                    Text("URL:")
                        .foregroundStyle(.primary)
                    TextField("URL", text: $link)
                        .roundedTextField()

                    Text("Price:")
                        .foregroundStyle(.primary)
                    TextField("Price", text: $priceString)
                        .keyboardType(.decimalPad)
                        .roundedTextField()

                    ShareLink(item: link) {
                        Label("Share URL", systemImage: "square.and.arrow.up")
                            .padding(.top, 10)
                            .padding(.bottom, 15)
                    }

                    moveMenu(currentWishlistID: item.wishlistID) { destinationID in
                        item.name = name
                        item.remark = remark
                        item.link = link
                        if let priceValue = parseAmount(priceString) {
                            item.price = priceValue
                        }
                        item.wishlistID = destinationID
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
                .cardStyle(settings)
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
                        .foregroundStyle(.primary)
                    TextField("Name", text: $name)
                        .roundedTextField()

                    Text("Remark:")
                        .foregroundStyle(.primary)
                    TextField("Remark", text: $remark)
                        .roundedTextField()

                    Text("URL:")
                        .foregroundStyle(.primary)
                    TextField("URL", text: $link)
                        .roundedTextField()

                    Text("Price:")
                        .foregroundStyle(.primary)
                    TextField("Price", text: $priceString)
                        .keyboardType(.decimalPad)
                        .roundedTextField()

                    ShareLink(item: link) {
                        Label("Share URL", systemImage: "square.and.arrow.up")
                            .padding(.top, 10)
                            .padding(.bottom, 15)
                    }

                    moveMenu(currentWishlistID: item.wishlistID) { destinationID in
                        item.name = name
                        item.remark = remark
                        item.link = link
                        if let priceValue = parseAmount(priceString) {
                            item.price = priceValue
                        }
                        item.wishlistID = destinationID
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
                .cardStyle(settings)
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
                        .foregroundStyle(.primary)
                    TextField("Name", text: $name)
                        .roundedTextField()

                    Text("Remark:")
                        .foregroundStyle(.primary)
                    TextField("Remark", text: $remark)
                        .roundedTextField()

                    Text("URL:")
                        .foregroundStyle(.primary)
                    TextField("URL", text: $link)
                        .roundedTextField()

                    Text("Price:")
                        .foregroundStyle(.primary)
                    TextField("Price", text: $priceString)
                        .keyboardType(.decimalPad)
                        .roundedTextField()

                    ShareLink(item: link) {
                        Label("Share URL", systemImage: "square.and.arrow.up")
                            .padding(.top, 10)
                            .padding(.bottom, 15)
                    }

                    moveMenu(currentWishlistID: item.wishlistID) { destinationID in
                        item.name = name
                        item.remark = remark
                        item.link = link
                        if let priceValue = parseAmount(priceString) {
                            item.price = priceValue
                        }
                        item.wishlistID = destinationID
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
                .cardStyle(settings)
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
        .wishlistBackground(settings)
    }
    
    func parseAmount(_ string: String) -> Double? {
        WishlistAmountFormatter.parse(string)
    }

    /// Formats a value for editing without a currency symbol.
    func formatAmountForEditing(_ value: Double) -> String {
        WishlistAmountFormatter.format(value)
    }

    @ViewBuilder
    private func moveMenu(
        currentWishlistID: UUID?,
        move: @escaping (UUID) -> Void
    ) -> some View {
        let destinations = wishlists.filter {
            $0.isVisible && $0.id != currentWishlistID
        }

        if !destinations.isEmpty {
            Menu {
                ForEach(destinations) { wishlist in
                    Button(wishlist.name) {
                        move(wishlist.id)
                        try? modelContext.save()
                        dismiss()
                    }
                }
            } label: {
                Label("Move", systemImage: "arrow.right.arrow.left")
            }
        }
    }
}
