//
//  WishlistList.swift
//  Wishlist
//

import Foundation
import SwiftData

@Model
final class WishlistList {
    static let maximumCount = 4

    static func legacyPlaceholder(
        in wishlists: [WishlistList],
        occupiedIDs: Set<UUID>,
        hasUnassignedWishes: Bool
    ) -> WishlistList? {
        guard wishlists.count == 4, !hasUnassignedWishes else { return nil }

        let names = Set(wishlists.map(\.name))
        let hasDefaultLists = [
            Set(["Short Term", "Mid Term", "Long Term"]),
            Set(["Kurzfristig", "Mittelfristig", "Langfristig"])
        ].contains { $0.isSubset(of: names) }

        guard hasDefaultLists else { return nil }

        return wishlists.first {
            ["Wishlist", "Wunschliste"].contains($0.name)
                && !occupiedIDs.contains($0.id)
        }
    }

    var id: UUID = UUID()
    var name: String = ""
    var isVisible: Bool = true
    var sortOrder: Int = 0

    init(
        id: UUID = UUID(),
        name: String,
        isVisible: Bool = true,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.isVisible = isVisible
        self.sortOrder = sortOrder
    }
}
