//
//  RootView.swift
//  FieldFinder-App
//
//  Created by Andy Heredia on 8/5/25.
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenWelcome") var hasSeenWelcome = false
    @Environment(AppState.self) var appState
    
    var body: some View {
        switch appState.status {
        case .login:
            if hasSeenWelcome {
                AppTabBarView()
            } else {
                WelcomeView(hasSeenWelcome: $hasSeenWelcome)
            }
        case .loading:
            ProgressView()
        case .home:
            AppTabBarView()
        case .registerUser:
            RegisterUserView(appState: appState)
            
        case .loaded:
            if let role = appState.userRole {
                switch role {
                    
                case .dueno:
                    AppTabBarView()
                case .jugador:
                    AppTabBarView()
                }
            } else {
                ErrorStateView()
            }
            
        case .register:
            RegisterEstablishmentView(appState: appState)
        case .error(error: _):
            ErrorStateView()
        case .ownerView:
            OwnerView(appState: appState)
        case .registerCancha:
            if let estID = appState.selectedEstablishmentID {
                RegisterFieldView(establecimientoID: estID)
            } else {
                Text("No se ha seleccionado establecimiento.")
            }

        }
    }
}

#Preview {
    RootView()
        .environment(AppState())
}
