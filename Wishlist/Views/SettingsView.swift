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
    @State private var selectedPhoto: PhotosPickerItem?

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

                sectionTitle("Theme Mode")

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
                .onChange(of: settings.themeMode) { _, newValue in
                    settings.applyTheme(newValue)
                    selectedPhoto = nil
                    try? modelContext.save()
                }

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
            do {
                try modelContext.save()
                print("Settings saved on view disappear.")
            } catch {
                print("Saving settings on disappear failed: \(error.localizedDescription)")
            }
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
}
