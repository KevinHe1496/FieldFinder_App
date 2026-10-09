//
//  ClaimBannerView.swift
//  FieldFinder-App
//
//  Tarjeta que se muestra en el detalle de un establecimiento sin dueño.
//

import SwiftUI

struct ClaimBannerView: View {
    let onClaimTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "building.2.crop.circle.fill")
                    .font(.title)
                    .foregroundStyle(.primaryColorGreen)
                Text("¿Eres el dueño de este lugar?")
                    .font(.headline)
                    .foregroundStyle(.primaryColorGreen)
            }

            Text("Esta ficha aún no está verificada por el dueño. Reclámala gratis y agrega fotos, canchas, precios y tu teléfono para que más jugadores te encuentren.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            CustomButtonView(
                title: "Reclamar establecimiento",
                color: .primaryColorGreen,
                textColor: .white,
                action: onClaimTap
            )
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thirdColorWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ClaimBannerView(onClaimTap: {})
        .padding()
}
