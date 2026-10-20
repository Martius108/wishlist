//
//  SettingsView.swift
//  Wishlist
//
//  Created by Martin Lanius on 10.05.25.
//

import SwiftUI
import SwiftData
import PhotosUI

// View for adjusting app settings like theme, background, and opacity
struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Bindable var settings: MySettings
    @Query(sort: \WishlistList.sortOrder) private var wishlists: [WishlistList]
    @Query private var shortItems: [ShortItems]
    @Query private var midItems: [MidItems]
    @Query private var longItems: [LongItems]
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var wishlistPendingDeletion: WishlistList?
    @State private var showWishlistLimitAlert = false

    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Settings")
                    .font(.title)
                    .wishlistImageLabelStyle(
                        settings.backgroundImageData != nil,
                        fallbackColor: .blue
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityAddTraits(.isHeader)

                sectionTitle("Wishlists")

                ForEach(wishlists) { wishlist in
                    @Bindable var wishlist = wishlist

                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Wishlist Name", text: $wishlist.name)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                            .onSubmit {
                                saveName(of: wishlist)
                            }

                        HStack(spacing: 16) {
                            Toggle("Visible", isOn: visibilityBinding(for: wishlist))

                            Button {
                                saveName(of: wishlist)
                            } label: {
                                Label("Save", systemImage: "square.and.arrow.down")
                            }

                            Button(role: .destructive) {
                                hideKeyboard()
                                wishlistPendingDeletion = wishlist
                            } label: {
                                Image(systemName: "trash")
                            }
                            .disabled(wishlists.count == 1)
                            .accessibilityLabel(Text("Delete"))
                        }
                    }
                    .padding()
                    .background(.bar, in: RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    hideKeyboard()
                    if wishlists.count >= WishlistList.maximumCount {
                        showWishlistLimitAlert = true
                    } else {
                        addWishlist()
                    }
                } label: {
                    Label("Add Wishlist", systemImage: "plus")
                }
                .wishlistImageLabelStyle(
                    settings.backgroundImageData != nil,
                    fallbackColor: .blue
                )

                sectionTitle("Theme Mode")

                HStack(spacing: 4) {
                    themeButton("System", value: "system")
                    themeButton("Light", value: "light")
                    themeButton("Dark", value: "dark")
                }
                .padding(4)
                .background {
                    if settings.backgroundImageData != nil {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.bar)
                    } else {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.primary.opacity(0.12))
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(Text("Select Theme"))

                sectionTitle("Background Color")

                ColorPicker("Select Background Color", selection: Binding(
                    get: { Color(wishlistBackground: settings.backgroundColor) },
                    set: { newColor in
                        selectedPhoto = nil
                        settings.backgroundImageData = nil
                        settings.backgroundColor = newColor.toHex()
                        try? modelContext.save()
                    }
                ))
                .wishlistImageLabelStyle(
                    settings.backgroundImageData != nil,
                    fallbackColor: .primary
                )

                sectionTitle("Background Image")

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Select Background Image", systemImage: "photo")
                        .wishlistImageLabelStyle(
                            settings.backgroundImageData != nil,
                            fallbackColor: .blue
                        )
                }
            }
            .padding()
            .foregroundColor(
                settings.themeMode == "dark" ? .white :
                settings.themeMode == "light" ? .black :
                .primary
            )
        }
        .scrollDismissesKeyboard(.interactively)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .wishlistBackground(settings)
        .onChange(of: selectedPhoto) { _, photo in
            guard let photo else { return }
            Task {
                guard
                    let data = try? await photo.loadTransferable(type: Data.self),
                    selectedPhoto == photo
                else { return }
                settings.backgroundImageData = data
                selectedPhoto = nil
                try? modelContext.save()
            }
        }
        .onDisappear {
            wishlists.forEach(normalizeName)
            do {
                try modelContext.save()
                print("Settings saved on view disappear.")
            } catch {
                print("Saving settings on disappear failed: \(error.localizedDescription)")
            }
        }
        .sheet(item: $wishlistPendingDeletion) { wishlist in
            WishlistDeletionView(
                wishlistName: wishlist.name,
                destinations: wishlists.filter { $0.id != wishlist.id },
                hasWishes: wishlistContainsWishes(wishlist)
            ) { action in
                deleteWishlist(wishlist, action: action)
            }
        }
        .alert("Wishlist Limit Reached", isPresented: $showWishlistLimitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You can create up to four wishlists.")
        }
    }

    private func sectionTitle(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.headline)
            .wishlistImageLabelStyle(
                settings.backgroundImageData != nil,
                fallbackColor: .primary
            )
    }

    private func themeButton(_ title: LocalizedStringKey, value: String) -> some View {
        let isSelected = settings.themeMode == value

        return Button {
            settings.applyTheme(value)
            selectedPhoto = nil
            try? modelContext.save()
        } label: {
            Text(title)
                .font(.headline)
                .foregroundStyle(
                    isSelected
                        ? Color.white
                        : settings.backgroundImageData != nil
                            ? Color(uiColor: .systemBlue)
                            : Color.primary
                )
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(
                    isSelected ? Color.accentColor : Color.clear,
                    in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func visibilityBinding(for wishlist: WishlistList) -> Binding<Bool> {
        Binding(
            get: { wishlist.isVisible },
            set: { isVisible in
                guard isVisible || wishlists.filter(\.isVisible).count > 1 else { return }
                wishlist.isVisible = isVisible

                try? modelContext.save()
            }
        )
    }

    private func addWishlist() {
        guard wishlists.count < WishlistList.maximumCount else { return }

        let baseName = String(localized: "Wishlist")
        let existingNames = Set(wishlists.map(\.name))
        let preferredNumber = min(wishlists.count + 1, WishlistList.maximumCount)
        let candidateNumbers = [preferredNumber]
            + (1...WishlistList.maximumCount).filter { $0 != preferredNumber }
        let number = candidateNumbers.first {
            !existingNames.contains("\(baseName) \($0)")
        } ?? wishlists.count + 1
        let nextOrder = (wishlists.map(\.sortOrder).max() ?? -1) + 1
        let wishlist = WishlistList(name: "\(baseName) \(number)", sortOrder: nextOrder)

        modelContext.insert(wishlist)
        try? modelContext.save()
    }

    private func deleteWishlist(
        _ wishlist: WishlistList,
        action: WishlistDeletionAction
    ) {
        guard wishlists.count > 1 else { return }

        let remaining = wishlists.filter { $0.id != wishlist.id }
        let selectedDestination: WishlistList?

        switch action {
        case .deleteWishes:
            shortItems.filter { $0.wishlistID == wishlist.id }.forEach(modelContext.delete)
            midItems.filter { $0.wishlistID == wishlist.id }.forEach(modelContext.delete)
            longItems.filter { $0.wishlistID == wishlist.id }.forEach(modelContext.delete)
            selectedDestination = nil
        case .moveWishes(let destinationID):
            guard let destination = remaining.first(where: { $0.id == destinationID }) else { return }
            shortItems.filter { $0.wishlistID == wishlist.id }.forEach { $0.wishlistID = destination.id }
            midItems.filter { $0.wishlistID == wishlist.id }.forEach { $0.wishlistID = destination.id }
            longItems.filter { $0.wishlistID == wishlist.id }.forEach { $0.wishlistID = destination.id }
            destination.isVisible = true
            selectedDestination = destination
        }

        let nextVisible = selectedDestination
            ?? remaining.first(where: \.isVisible)
            ?? remaining[0]
        nextVisible.isVisible = true
        modelContext.delete(wishlist)
        remaining.enumerated().forEach { index, list in
            list.sortOrder = index
        }
        wishlistPendingDeletion = nil
        try? modelContext.save()
    }

    private func wishlistContainsWishes(_ wishlist: WishlistList) -> Bool {
        shortItems.contains { $0.wishlistID == wishlist.id }
            || midItems.contains { $0.wishlistID == wishlist.id }
            || longItems.contains { $0.wishlistID == wishlist.id }
    }

    private func normalizeName(of wishlist: WishlistList) {
        let trimmedName = wishlist.name.trimmingCharacters(in: .whitespacesAndNewlines)
        wishlist.name = trimmedName.isEmpty ? String(localized: "Wishlist") : trimmedName
    }

    private func saveName(of wishlist: WishlistList) {
        normalizeName(of: wishlist)
        try? modelContext.save()
        hideKeyboard()
    }
}

private enum WishlistDeletionAction {
    case deleteWishes
    case moveWishes(to: UUID)
}

private enum WishlistDeletionHandling {
    case delete
    case move
}

private struct WishlistDeletionView: View {
    @Environment(\.dismiss) private var dismiss

    let wishlistName: String
    let destinations: [WishlistList]
    let hasWishes: Bool
    let confirm: (WishlistDeletionAction) -> Void

    @State private var handling: WishlistDeletionHandling?
    @State private var destinationID: UUID?

    init(
        wishlistName: String,
        destinations: [WishlistList],
        hasWishes: Bool,
        confirm: @escaping (WishlistDeletionAction) -> Void
    ) {
        self.wishlistName = wishlistName
        self.destinations = destinations
        self.hasWishes = hasWishes
        self.confirm = confirm
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(wishlistName)
                        .font(.headline)
                }

                if hasWishes {
                    Section("Existing Wishes") {
                        Picker("Existing Wishes", selection: $handling) {
                            Text("Delete Wishes")
                                .tag(Optional(WishlistDeletionHandling.delete))
                            Text("Move Wishes")
                                .tag(Optional(WishlistDeletionHandling.move))
                        }
                        .pickerStyle(.segmented)

                        if handling == .move {
                            Picker("Destination Wishlist", selection: $destinationID) {
                                Text("Select Wishlist")
                                    .tag(nil as UUID?)
                                ForEach(destinations) { wishlist in
                                    Text(wishlist.name)
                                        .tag(Optional(wishlist.id))
                                }
                            }
                        }
                    }
                } else {
                    Section {
                        Text("This wishlist is empty.")
                    }
                }

                if canConfirmDeletion {
                    Section {
                        Button(role: .destructive) {
                            confirmDeletion()
                        } label: {
                            Text(confirmationTitle)
                        }
                    }
                }
            }
            .navigationTitle("Delete Wishlist")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var confirmationTitle: LocalizedStringKey {
        guard hasWishes else { return "Delete Wishlist" }
        return handling == .move
            ? "Move Wishes and Delete Wishlist"
            : "Delete Wishlist and Wishes"
    }

    private var canConfirmDeletion: Bool {
        guard hasWishes else { return true }
        guard let handling else { return false }
        return handling == .delete || destinationID != nil
    }

    private func confirmDeletion() {
        guard hasWishes else {
            confirm(.deleteWishes)
            dismiss()
            return
        }

        guard let handling else { return }
        switch handling {
        case .delete:
            confirm(.deleteWishes)
        case .move:
            guard let destinationID else { return }
            confirm(.moveWishes(to: destinationID))
        }
        dismiss()
    }
}
