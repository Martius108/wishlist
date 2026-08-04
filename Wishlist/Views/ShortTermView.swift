//
//  ShortTermView.swift
//  Wishlist
//
//  Created by Martin Lanius on 10.05.25.
//

import SwiftUI
import SwiftData

struct ShortTermView: View {
    
    // Include modelContext and colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    // Binding to settings object
    @Bindable var settings: MySettings
    // Create an instance of the data base
    var shortItem: [ShortItems]

    var body: some View {
        NavigationStack {
            ZStack {
                WishlistBackground(settings: settings)

                VStack {
                    Text("Short Term Wishes")
                        .font(.title)
                        .foregroundColor(settings.themeMode == "dark" ? .white :
                                settings.themeMode == "light" ? .black : .primary)
                        .padding()
                    
                    NavigationLink(destination: InputView(settings: settings, type: .short)) {
                        Label("Add a new wish", systemImage: "square.and.pencil")
                            .foregroundStyle(.tint)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.bar, in: Capsule())
                    }
                    .padding(.bottom, 30)
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(shortItem, id: \.id) { item in
                                NavigationLink(destination: DetailView(settings: settings, shortItem: item)) {
                                    itemRow(item: item)
                                }
                            }

                            WishlistShareLink(links: shortItem.map(\.link))
                                .padding(.vertical, 20)
                        }
                        .padding(.horizontal, horizontalSizeClass == .regular ? UIScreen.main.bounds.width * 0.1 : 0)
                    }
                }
            }
        }
    }
    
    // Row layout for a bought item, with a button to reactivate it
    private func itemRow(item: ShortItems) -> some View {
        HStack {
            HStack() {
                Text(item.name)
                    .font(.system(size: 18))
                    .foregroundColor(systemColorScheme == .dark ? .black : .black)
                    .background(systemColorScheme == .dark ? Color.white : Color.white)
                Spacer()
                if item.price != 0 {
                    Text(item.price, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.trailing, 10)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .padding(.leading, 15)
        .padding(.trailing, 15)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(8)
        .padding(.top, 3)
    }
}
