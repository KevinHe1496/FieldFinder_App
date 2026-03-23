//
//  DefaultProfile.swift
//  FieldFinder-App
//
//  Created by Andy Heredia on 19/5/25.
//

import SwiftUI

struct DefaultProfile: View {
    @Environment(AppState.self) var appState
    @State var viewModel = ProfileUserViewModel()
    
    @State var showRegisterSheet: Bool = false
    @State var showLoginSheet: Bool = false
    
    var body: some View {
        Group {
            switch viewModel.status {
            case .success(let user):
                switch user.rol {
                case "dueno":
                    ProfileOwnerView()
                case "jugador":
                    ProfileUserView(appState: _appState)
                default:
                    unauthenticatedView
                }
                
            case .loading:
                LoadingProgressView()

            case .error:
                unauthenticatedView
            case .idle:
                unauthenticatedView
            }
        }
        .onAppear {
            Task {
                try await viewModel.getMe()
            }
        }
        .sheet(isPresented: $showRegisterSheet) {
            RegisterUserView(appState: appState)
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
        }
    }
    
    private var unauthenticatedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.primaryColorGreen)
            
            Text("¿Aún no tienes cuenta?")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Inicia sesión si ya tienes una cuenta o regístrate como jugador o dueño para guardar tus canchas o administrarlas.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                CustomButtonView(
                    title: "Iniciar Sesión",
                    color: Color.primaryColorGreen,
                    textColor: Color.white
                ) {
                    showLoginSheet.toggle()
                }

                CustomButtonView(
                    title: "Registrarse",
                    color: Color.primaryColorGreen,
                    textColor: Color.white
                ) {
                    showRegisterSheet.toggle()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    DefaultProfile()
        .environment(AppState())
}
