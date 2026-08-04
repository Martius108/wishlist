//
//  ViewModifier.swift
//  Wishlist
//
//  Created by Martin Lanius on 12.05.25.
//

import Foundation
import SwiftUI
import UIKit

struct WishlistBackground: View {
    @Bindable var settings: MySettings

    var body: some View {
        GeometryReader { geometry in
            if let data = settings.backgroundImageData,
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            } else {
                Color(hex: settings.backgroundColor)
            }
        }
        .ignoresSafeArea()
    }
}

struct WishlistShareLink: View {
    let links: [String]

    var body: some View {
        ShareLink(item: WishlistShareText.make(links: links), subject: Text("My Wishlist")) {
            Label("Share Wishlist", systemImage: "square.and.arrow.up")
                .foregroundStyle(.tint)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.bar, in: Capsule())
        }
    }
}

enum WishlistShareText {
    static func make(links: [String]) -> String {
        let links = links
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return ([String(localized: "My Wishlist")] + links)
            .joined(separator: "\n\n")
    }
}

struct CardBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.regularMaterial)
            .cornerRadius(20)
            .shadow(radius: 4)
            .padding(.horizontal)
    }
}

struct RoundedTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 1, x: 0, y: 1)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardBackgroundModifier())
    }

    func roundedTextField() -> some View {
        self.modifier(RoundedTextFieldModifier())
    }

    func wishlistBackground(_ settings: MySettings) -> some View {
        background {
            WishlistBackground(settings: settings)
        }
    }
}
