//
//  WelcomeView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 19/5/25.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(AppState.self) var appState
    @Binding var hasSeenWelcome: Bool

    var body: some View {
        ZStack {
            Color.secondaryColorBlack.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 28) {
                HStack(spacing: 10) {
                    Image(.splashLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityHidden(true)
                    Text("Field Finder")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(.white)
                }

                (Text("Encuentra cancha y ")
                 + Text("juega hoy").foregroundColor(.primaryColorGreen)
                 + Text("."))
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 18) {
                    benefit(icon: "mappin.and.ellipse",
                            title: "Canchas cerca de ti",
                            detail: "Sintéticas, cubiertas, de fútbol 5, 7 u 11.")
                    benefit(icon: "dollarsign.circle",
                            title: "Precios claros",
                            detail: "Compara el valor por hora antes de llamar.")
                    benefit(icon: "bubble.left.fill",
                            title: "Reserva por WhatsApp",
                            detail: "Escribe directo al dueño, con tu día y hora listos.")
                }

                Spacer(minLength: 0)

                VStack(spacing: 12) {
                    Button("Ver canchas cerca") {
                        hasSeenWelcome = true
                        appState.status = .home
                    }
                    .buttonStyle(BrandPrimaryButtonStyle())

                    Text("Te pediremos tu ubicación solo para ordenar las canchas por distancia.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 24)
        }
    }

    private func benefit(icon: String, title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.primaryColorGreen)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    WelcomeView(hasSeenWelcome: .constant(false))
        .environment(AppState())
}
