//
//  WishlistView.swift
//  Wishlist
//

import SwiftUI

struct WishlistView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Bindable var settings: MySettings
    @Bindable var wishlist: WishlistList
    let shortItems: [ShortItems]
    let midItems: [MidItems]
    let longItems: [LongItems]

    var body: some View {
        NavigationStack {
            ZStack {
                WishlistBackground(settings: settings)

                VStack {
                    Text(wishlist.name)
                        .font(.title)
                        .wishlistImageLabelStyle(
                            settings,
                            fallbackColor: .blue
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()

                    NavigationLink(
                        destination: InputView(
                            settings: settings,
                            wishlistID: wishlist.id
                        )
                    ) {
                        Label("Add a new wish", systemImage: "square.and.pencil")
                            .wishlistImageLabelStyle(
                                settings,
                                fallbackColor: .accentColor
                            )
                    }
                    .padding(.bottom, 30)

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(entries) { entry in
                                NavigationLink(destination: detailView(for: entry)) {
                                    itemRow(entry)
                                }
                                .buttonStyle(.plain)
                            }

                            WishlistShareLink(
                                links: entries.map(\.link),
                                settings: settings
                            )
                                .padding(.vertical, 20)
                        }
                        .padding(
                            .horizontal,
                            UIScreen.main.bounds.width
                                * (horizontalSizeClass == .regular ? 0.1 : 0.025)
                        )
                    }
                }
            }
        }
    }

    private var entries: [WishlistEntry] {
        let shortEntries = shortItems
            .filter { $0.wishlistID == wishlist.id }
            .map(WishlistEntry.short)
        let midEntries = midItems
            .filter { $0.wishlistID == wishlist.id }
            .map(WishlistEntry.mid)
        let longEntries = longItems
            .filter { $0.wishlistID == wishlist.id }
            .map(WishlistEntry.long)

        return (shortEntries + midEntries + longEntries).sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    @ViewBuilder
    private func detailView(for entry: WishlistEntry) -> some View {
        switch entry {
        case .short(let item):
            DetailView(settings: settings, shortItem: item)
        case .mid(let item):
            DetailView(settings: settings, midItem: item)
        case .long(let item):
            DetailView(settings: settings, longItem: item)
        }
    }

    private func itemRow(_ entry: WishlistEntry) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(entry.name)
                .font(.system(size: 18))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if entry.price != 0 {
                Text(WishlistAmountFormatter.currencyString(entry.price))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize()
                    .padding(.trailing, 6)
            }

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .padding(.leading, 15)
        .padding(.trailing, 8)
        .frame(maxWidth: .infinity)
        .background(WishlistElementBackground(opacity: settings.elementOpacity))
        .padding(.top, 3)
    }
}

private enum WishlistEntry: Identifiable {
    case short(ShortItems)
    case mid(MidItems)
    case long(LongItems)

    var id: ObjectIdentifier {
        switch self {
        case .short(let item): ObjectIdentifier(item)
        case .mid(let item): ObjectIdentifier(item)
        case .long(let item): ObjectIdentifier(item)
        }
    }

    var name: String {
        switch self {
        case .short(let item): item.name
        case .mid(let item): item.name
        case .long(let item): item.name
        }
    }

    var link: String {
        switch self {
        case .short(let item): item.link
        case .mid(let item): item.link
        case .long(let item): item.link
        }
    }

    var price: Double {
        switch self {
        case .short(let item): item.price
        case .mid(let item): item.price
        case .long(let item): item.price
        }
    }
}
