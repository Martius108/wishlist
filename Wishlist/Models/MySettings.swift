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
    var themeMode: String = "system"
    @Attribute(.externalStorage) var backgroundImageData: Data?
    var backgroundColor: String = "#FFFFFF"
    
    init(
        themeMode: String = "system",
        backgroundImageData: Data? = nil,
        backgroundColor: String = "#FFFFFF"
    ) {
        self.themeMode = themeMode
        self.backgroundImageData = backgroundImageData
        self.backgroundColor = backgroundColor
    }
}
