//
//  EstablishmentAnnotationView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 14/5/25.
//

import SwiftUI

/// Pin del mapa: muestra el precio "desde" cuando la cancha lo tiene publicado;
/// si no, un punto gris (canchas importadas sin dueño).
struct MapEstablishmentAnnotationView: View {
    var establishment: EstablishmentResponse
    var isSelected: Bool = false

    var body: some View {
        Group {
            if let price = establishment.minPriceText {
                Text(price)
                    .font(.system(size: isSelected ? 13 : 12, weight: .heavy))
                    .foregroundStyle(isSelected ? Color.secondaryColorBlack : .white)
                    .padding(.horizontal, isSelected ? 12 : 10)
                    .frame(height: isSelected ? 34 : 30)
                    .background(isSelected ? Color.primaryColorGreen : Color.secondaryColorBlack, in: Capsule())
                    .overlay(Capsule().stroke(isSelected ? Color.secondaryColorBlack : .white, lineWidth: 2))
            } else {
                Circle()
                    .fill(establishment.hasOwner ? Color.secondaryColorBlack : Color.gray)
                    .frame(width: 22, height: 22)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
        .accessibilityLabel(Text(establishment.name))
    }
}

#Preview {
    MapEstablishmentAnnotationView(establishment: .sample)
}
