//
//  ContentView.swift
//  Wishlist
//
//  Created by Martin Lanius on 10.05.25.
//

import Foundation
import SwiftUI
import SwiftData

// Main View as TabView holding all data
struct ContentView: View {
    
    // Prepare for use of modelContext and system theme settings
    @Environment(\.modelContext) private var modelContext
    // Set the query to hold the item names
    @Query(sort: \LongItems.name) var longItems: [LongItems]
    @Query(sort: \MidItems.name) var midItems: [MidItems]
    @Query(sort: \ShortItems.name) var shortItems: [ShortItems]
    @Query(sort: \WishlistList.sortOrder) private var wishlists: [WishlistList]
    // Set the query to get hold the settings
    @Query var mySettings: [MySettings]
    
    @State private var cachedSettings: MySettings?

    var settings: MySettings {
        cachedSettings ?? MySettings(
            themeMode: "system",
            backgroundColor: MySettings.systemBackgroundColor
        )
    }
    
    var body: some View {
        TabView {
            ForEach(visibleWishlists) { wishlist in
                WishlistView(
                    settings: settings,
                    wishlist: wishlist,
                    shortItems: shortItems,
                    midItems: midItems,
                    longItems: longItems
                )
                .tabItem {
                    Image(systemName: "list.star")
                    Text(wishlist.name)
                }
            }

            SettingsView(settings: settings)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .preferredColorScheme(preferredColorScheme)
        .onAppear {
            if cachedSettings == nil {
                let activeSettings: MySettings
                if let loaded = mySettings.first {
                    activeSettings = loaded
                } else {
                    activeSettings = MySettings(
                        themeMode: "system",
                        backgroundColor: MySettings.systemBackgroundColor
                    )
                    modelContext.insert(activeSettings)
                }
                cachedSettings = activeSettings
                prepareWishlists()
            }
        }
    }

    private var visibleWishlists: [WishlistList] {
        wishlists.filter(\.isVisible)
    }

    private func prepareWishlists() {
        let availableLists: [WishlistList]

        if wishlists.isEmpty {
            let shortList = WishlistList(name: String(localized: "Short Term"), sortOrder: 0)
            let midList = WishlistList(name: String(localized: "Mid Term"), sortOrder: 1)
            let longList = WishlistList(name: String(localized: "Long Term"), sortOrder: 2)
            [shortList, midList, longList].forEach(modelContext.insert)
            availableLists = [shortList, midList, longList]
        } else {
            availableLists = wishlists
        }

        if !availableLists.contains(where: \.isVisible) {
            availableLists[0].isVisible = true
        }

        let shortList = availableLists.first {
            ["Short Term", "Kurzfristig"].contains($0.name)
        } ?? availableLists[0]
        let midList = availableLists.first {
            ["Mid Term", "Mittelfristig"].contains($0.name)
        } ?? availableLists[min(1, availableLists.count - 1)]
        let longList = availableLists.first {
            ["Long Term", "Langfristig"].contains($0.name)
        } ?? availableLists[min(2, availableLists.count - 1)]

        shortItems.filter { $0.wishlistID == nil }.forEach {
            $0.wishlistID = shortList.id
        }
        midItems.filter { $0.wishlistID == nil }.forEach {
            $0.wishlistID = midList.id
        }
        longItems.filter { $0.wishlistID == nil }.forEach {
            $0.wishlistID = longList.id
        }

        do {
            try modelContext.save()
        } catch {
            return
        }

        let cleanupKey = "didCleanUpLegacyWishlistPlaceholder"
        guard !UserDefaults.standard.bool(forKey: cleanupKey) else { return }

        let occupiedIDs = Set(
            shortItems.compactMap(\.wishlistID)
                + midItems.compactMap(\.wishlistID)
                + longItems.compactMap(\.wishlistID)
        )
        let hasUnassignedWishes = shortItems.contains { $0.wishlistID == nil }
            || midItems.contains { $0.wishlistID == nil }
            || longItems.contains { $0.wishlistID == nil }

        if let placeholder = WishlistList.legacyPlaceholder(
            in: availableLists,
            occupiedIDs: occupiedIDs,
            hasUnassignedWishes: hasUnassignedWishes
        ) {
            modelContext.delete(placeholder)
            do {
                try modelContext.save()
            } catch {
                modelContext.rollback()
                return
            }
        }
        UserDefaults.standard.set(true, forKey: cleanupKey)
    }

    private var preferredColorScheme: ColorScheme? {
        switch settings.themeMode {
        case "light": .light
        case "dark": .dark
        default: nil
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [MySettings.self, WishlistList.self, ShortItems.self, MidItems.self, LongItems.self],
            inMemory: true
        )
}
