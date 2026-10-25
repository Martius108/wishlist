//
//  ViewModifier.swift
//  Wishlist
//
//  Created by Martin Lanius on 12.05.25.
//

import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers

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
                Color(wishlistBackground: settings.backgroundColor)
            }
        }
        .ignoresSafeArea()
    }
}

struct WishlistShareLink: View {
    let links: [String]
    let settings: MySettings
    @State private var isShareSheetPresented = false

    var body: some View {
        Button {
            isShareSheetPresented = true
        } label: {
            Label("Share Wishlist", systemImage: "square.and.arrow.up")
                .wishlistImageLabelStyle(
                    settings,
                    fallbackColor: .accentColor
                )
        }
        .sheet(isPresented: $isShareSheetPresented) {
            WishlistShareSheet(text: WishlistShareText.make(links: links))
        }
    }
}

private struct WishlistShareSheet: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [WishlistActivityItemSource(text: text)],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private final class WishlistActivityItemSource: NSObject, UIActivityItemSource {
    private let text: String

    init(text: String) {
        self.text = text
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        WishlistShareText.withoutLinkPreviews(text) as NSString
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType _: UIActivity.ActivityType?
    ) -> Any? {
        WishlistShareText.withoutLinkPreviews(text) as NSString
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        UTType.utf8PlainText.identifier
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

    static func withoutLinkPreviews(_ text: String) -> String {
        text
            .replacingOccurrences(of: "https://", with: "https://\u{200B}")
            .replacingOccurrences(of: "http://", with: "http://\u{200B}")
    }
}

struct WishlistElementBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    let opacity: Double

    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill((colorScheme == .dark ? Color.black : Color.white).opacity(opacity))
    }
}

struct CardBackgroundModifier: ViewModifier {
    let settings: MySettings
    func body(content: Content) -> some View {
        content
            .padding()
            .background(WishlistElementBackground(opacity: settings.elementOpacity))
            .padding(.horizontal)
    }
}

struct RoundedTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                    .allowsHitTesting(false)
            )
    }
}

extension View {
    func cardStyle(_ settings: MySettings) -> some View {
        self.modifier(CardBackgroundModifier(settings: settings))
    }

    func roundedTextField() -> some View {
        self.modifier(RoundedTextFieldModifier())
    }

    func wishlistBackground(_ settings: MySettings) -> some View {
        background {
            WishlistBackground(settings: settings)
        }
    }

    @ViewBuilder
    func wishlistImageLabelStyle(_ settings: MySettings, fallbackColor: Color) -> some View {
        if settings.backgroundImageData != nil {
            self
                .foregroundStyle(.tint)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    WishlistElementBackground(opacity: settings.elementOpacity)
                        .padding(.top, 3)
                )
        } else {
            self.foregroundStyle(fallbackColor)
        }
    }

}
