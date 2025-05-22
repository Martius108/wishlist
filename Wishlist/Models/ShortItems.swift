//
//  ShortItems.swift
//  Wishlist
//
//  Created by Martin Lanius on 10.05.25.
//

import Foundation
import SwiftData

@Model
// Class holding the data for short term wishes
final class ShortItems {
    var name: String = ""
    var remark: String = ""
    var link: String = ""
    var price: Double = 0.0
    
    init(name: String, remark: String, link: String, price: Double) {
        self.name = name
        self.remark = remark
        self.link = link
        self.price = price
    }
}
