//
//  ContentView.swift
//  Wishlist
//
//  Created by Martin Lanius on 10.05.25.
//

import SwiftUI
import SwiftData

// Main View as TabView holding all data
struct ContentView: View {
    
    // Prepare for use of modelContext and system theme settings
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var systemColorScheme
    // Set the query to hold the item names
    @Query(sort: \LongItems.name) var longItems: [LongItems]
    @Query(sort: \MidItems.name) var midItems: [MidItems]
    @Query(sort: \ShortItems.name) var shortItems: [ShortItems]
    // Set the query to get hold the settings
    @Query var mySettings: [MySettings]
    
    @State private var cachedSettings: MySettings?

    var settings: MySettings {
        cachedSettings ?? MySettings(
            themeMode: "system",
            backgroundColor: systemColorScheme == .dark ? "#000000" : "#FFFFFF"
        )
    }
    
    var body: some View {
        TabView {
            ShortTermView(settings: settings, shortItem: shortItems)
                .tabItem {
                    Image(systemName: "list.star")
                    Text("Short Term")
                }
            
            MidTermView(settings: settings, midItem: midItems)
                .tabItem {
                    Image(systemName: "list.star")
                    Text("Mid Term")
                }
            
            LongTermView(settings: settings, longItem: longItems)
                .tabItem {
                    Image(systemName: "list.star")
                    Text("Long Term")
                }

            SettingsView(settings: settings)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .onAppear {
            if cachedSettings == nil {
                if let loaded = mySettings.first {
                    cachedSettings = loaded
                } else {
                    let fallback = MySettings(
                        themeMode: "system",
                        backgroundColor: systemColorScheme == .dark ? "#000000" : "#FFFFFF"
                    )
                    modelContext.insert(fallback)
                    cachedSettings = fallback
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [MySettings.self, ShortItems.self, MidItems.self, LongItems.self], inMemory: true)
}
