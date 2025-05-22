//
//  ViewModifier.swift
//  Wishlist
//
//  Created by Martin Lanius on 12.05.25.
//

import SwiftUI

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
}
