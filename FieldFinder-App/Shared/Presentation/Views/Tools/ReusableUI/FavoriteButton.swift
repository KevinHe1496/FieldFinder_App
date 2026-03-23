//
//  FavoriteButton.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 12/5/25.
//
import SwiftUI

struct FavoriteButton: View {
    @Binding var isFavorite: Bool
    var onToggle: (() -> Void)? = nil

    @State private var animate = false

    var body: some View {
        Button(action: {
            animate = true
            onToggle?()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animate = false
            }
        }) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 24))
                .foregroundStyle(.red)
                .padding(8)
                .background(Color.white)
                .clipShape(Circle())
                .scaleEffect(animate ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: animate)
        }
    }
}

