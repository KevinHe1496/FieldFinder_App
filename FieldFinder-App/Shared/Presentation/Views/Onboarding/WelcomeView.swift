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
        NavigationStack {
            VStack {
                Image(.splashLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                
                VStack(spacing: 20) {
                    Text("BIENVENIDO A FIELD FINDER")
                        .font(.appTitle)
                        .foregroundStyle(.primaryColorGreen)
                    
                    Text("Explora canchas deportivas cerca de ti. Si quieres guardar tus favoritas o administrar tus propias canchas, regístrate desde el perfil.")
                        .font(.appDescription)
                        .foregroundStyle(.white)
                    
                    NavigationLink {
                        AppTabBarView()
                    } label: {
                        CustomButtonView(title: "Continuar", color: .primaryColorGreen, textColor: .white) {
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
                            hasSeenWelcome = true
                            appState.status = .home
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.secondaryColorBlack)
        }
    }
}

#Preview {
    WelcomeView(hasSeenWelcome: .constant(false))
        .environment(AppState())
}
