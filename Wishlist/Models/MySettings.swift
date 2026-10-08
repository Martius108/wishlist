//
//  Settings.swift
//  Wishlist
//
//  Created by Martin Lanius on 10.05.25.
//

import Foundation
import SwiftData

@Model
// Model class holding the data for user settings
final class MySettings {
    static let systemBackgroundColor = "system"

    var themeMode: String = "system"
    @Attribute(.externalStorage) var backgroundImageData: Data?
    var backgroundColor: String = MySettings.systemBackgroundColor
    
    init(
        themeMode: String = "system",
        backgroundImageData: Data? = nil,
        backgroundColor: String = MySettings.systemBackgroundColor
    ) {
        self.themeMode = themeMode
        self.backgroundImageData = backgroundImageData
        self.backgroundColor = backgroundColor
    }

    func applyTheme(_ themeMode: String) {
        self.themeMode = themeMode
        backgroundImageData = nil
        backgroundColor = Self.systemBackgroundColor
    }
}
