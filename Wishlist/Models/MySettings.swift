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
    var themeMode: String
    var backgroundColor: String
    
    init(themeMode: String = "system", backgroundColor: String = "#FFFFFF") {
        self.themeMode = themeMode
        self.backgroundColor = backgroundColor
    }
}
