//
//  MyClaimsView.swift
//  FieldFinder-App
//
//  Lista de solicitudes de reclamo del usuario y su estado.
//

import SwiftUI

struct MyClaimsView: View {
    @State private var viewModel = MyClaimsViewModel()

    var body: some View {
        Group {
            switch viewModel.status {
            case .idle, .loading:
                LoadingProgressView()

            case .success(let claims) where claims.isEmpty:
                emptyView

            case .success(let claims):
                List(claims) { claim in
                    ClaimRowView(claim: claim)
                }
                .refreshable { await viewModel.load() }

            case .error(let message):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.primaryColorGreen)
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Button("Reintentar") {
                        Task { await viewModel.load() }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Mis solicitudes")
        .task { await viewModel.load() }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2.crop.circle")
                .font(.system(size: 56))
                .foregroundStyle(.primaryColorGreen)
            Text("Aún no has reclamado ningún establecimiento")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("Si eres dueño de una cancha que aparece en la app, ábrela y toca \"Reclamar establecimiento\".")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

private struct ClaimRowView: View {
    let claim: ClaimResponse

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: claim.status.iconName)
                .font(.title2)
                .foregroundStyle(claim.status.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(claim.establecimientoNombre)
                    .font(.headline)
                Text(claim.relacionConEstablecimiento.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if claim.status == .aprobada {
                    Text("Cierra y vuelve a abrir la app para administrarlo.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(claim.status.displayName)
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(claim.status.color.opacity(0.15))
                .foregroundStyle(claim.status.color)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        MyClaimsView()
    }
    .environment(AppState())
}
