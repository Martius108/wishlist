//
//  SettingsView.swift
//  Wishlist
//
//  Created by Martin Lanius on 10.05.25.
//

import SwiftUI
import SwiftData

// View for adjusting app settings like theme, background, and opacity
struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Bindable var settings: MySettings

    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Theme Mode")
                    .font(.headline)

                Picker("Select Theme", selection: $settings.themeMode) {
                    Text("System")
                        .tag("system")
                        .foregroundColor(settings.themeMode == "dark" ? .white : .black)
                    Text("Light")
                        .tag("light")
                        .foregroundColor(settings.themeMode == "dark" ? .white : .black)
                    Text("Dark")
                        .tag("dark")
                        .foregroundColor(settings.themeMode == "dark" ? .white : .black)
                }
                .pickerStyle(.segmented)
                .onChange(of: settings.themeMode) { oldValue, newValue in
                    if newValue == "dark" {
                        settings.backgroundColor = "#000000"
                    } else if newValue == "light" {
                        settings.backgroundColor = "#FFFFFF"
                    }
                    try? modelContext.save()
                }

                Text("Background Color")
                    .font(.headline)

                ColorPicker("Select Background Color", selection: Binding(
                    get: { Color(hex: settings.backgroundColor) },
                    set: { newColor in
                        settings.backgroundColor = newColor.toHex()
                        try? modelContext.save()
                    }
                ))
            }
            .padding()
            .foregroundColor(
                settings.themeMode == "dark" ? .white :
                settings.themeMode == "light" ? .black :
                .primary
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: settings.backgroundColor))
        .navigationTitle("Settings")
        .onDisappear {
            do {
                try modelContext.save()
                print("Settings saved on view disappear.")
            } catch {
                print("Saving settings on disappear failed: \(error.localizedDescription)")
            }
        }
    }
}
