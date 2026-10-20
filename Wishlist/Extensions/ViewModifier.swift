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
    let imageBackground: Bool
    @State private var isShareSheetPresented = false

    var body: some View {
        Button {
            isShareSheetPresented = true
        } label: {
            Label("Share Wishlist", systemImage: "square.and.arrow.up")
                .wishlistImageLabelStyle(
                    imageBackground,
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

    @ViewBuilder
    func wishlistImageLabelStyle(_ imageBackground: Bool, fallbackColor: Color) -> some View {
        if imageBackground {
            self
                .foregroundStyle(Color(uiColor: .systemBlue))
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    .bar,
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                )
        } else {
            self.foregroundStyle(fallbackColor)
        }
    }

}
