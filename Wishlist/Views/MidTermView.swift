//
//  MidTermView.swift
//  Wishlist
//
//  Created by Martin Lanius on 10.05.25.
//

import SwiftUI
import SwiftData

struct MidTermView: View {
    // Include modelContext and colorScheme
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var systemColorScheme
    // Binding to the settings object
    @Bindable var settings: MySettings
    // Create an instance of the data base
    var midItem: [MidItems]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: settings.backgroundColor).ignoresSafeArea()

                VStack {
                    Text("Mid Term Wishes")
                        .font(.title)
                        .foregroundColor(settings.themeMode == "dark" ? .white :
                                settings.themeMode == "light" ? .black : .primary)
                        .padding()
                    
                    NavigationLink(destination: InputView(settings: settings, type: .mid)) {
                        Label("Add a new wish", systemImage: "square.and.pencil")
                            .padding(.bottom, 30)
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(midItem, id: \.id) { item in
                                NavigationLink(destination: DetailView(settings: settings, midItem: item)) {
                                    itemRow(item: item)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Row layout for a bought item, with a button to reactivate it
    private func itemRow(item: MidItems) -> some View {
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
                        .padding(.trailing, 20)
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
        .frame(maxWidth: 0.92 * UIScreen.main.bounds.width)
        .background(Color.white)
        .cornerRadius(8)
        .padding(.top, 3)
    }
}
