//
//  ErrorStateView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 29/5/25.
//


import SwiftUI

struct ErrorStateView: View {
    @Environment(AppState.self) var appState
    var title: String = "¡Ups! Algo salió mal"
    var message: String = "No pudimos cargar los datos. Intenta de nuevo más tarde."
    var systemImage: String = "exclamationmark.triangle.fill"
    var retryAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.primaryColorGreen)
                .padding(.bottom)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                appState.status = .home
            } label: {
                Text("Reintentar")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.primaryColorGreen)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 12)
            
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorStateView(
        title: "¡Ups! Algo salió mal",
        message: "No pudimos cargar los datos. Intenta de nuevo más tarde.",
        systemImage: "exclamationmark.triangle.fill")
    .environment(AppState())
}
