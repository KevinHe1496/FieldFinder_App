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
                Image(systemName: "flag.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.secondaryColorBlack)
                    .frame(width: 36, height: 36)
                    .background(Color.primaryColorGreen, in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityHidden(true)
                Text("¿Es tu cancha?")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text("Reclámala gratis: agrega fotos, precios y tu WhatsApp para que los jugadores reserven contigo.")
                .font(.system(size: 14))
                .foregroundStyle(Color.white.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)

            Button("Reclamar gratis", action: onClaimTap)
                .buttonStyle(BrandPrimaryButtonStyle())
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondaryColorBlack, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.brandBorder, lineWidth: 1))
    }
}

#Preview {
    ClaimBannerView(onClaimTap: {})
        .padding()
}
