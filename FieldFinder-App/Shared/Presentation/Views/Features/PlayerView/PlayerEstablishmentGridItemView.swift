//
//  EstablishmentRowView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 12/5/25.
//

import SwiftUI

struct PlayerEstablishmentGridItemView: View {
    let establishment: EstablishmentResponse
    @Environment(AppState.self) private var appState
    @Bindable var viewModel: PlayerGetNearbyEstablishmentsViewModel
    @State private var favoriteState: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RemoteImageCardView(url: establishment.photoEstablishment.first)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 4)

                // El rol ya está en AppState; antes cada tarjeta pedía /users/me al aparecer.
                if appState.userRole == .jugador {
                    FavoriteButton(isFavorite: $favoriteState) {
                        Task {
                            try await viewModel.setLikeHero(establishmentId: establishment.id)
                            favoriteState = viewModel.isFavorite(establishmentId: establishment.id)
                        }
                    }
                    .padding(12)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(establishment.name)
                    .font(.headline)
                    .foregroundStyle(.primaryColorGreen)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(.primaryColorGreen)
                    Text(establishment.address)
                        .font(.subheadline)
                        .foregroundStyle(Color.colorBlack)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 4)
        }
        .onAppear {
            favoriteState = viewModel.isFavorite(establishmentId: establishment.id)
        }
        .onChange(of: viewModel.favoritesData) { _, _ in
            favoriteState = viewModel.isFavorite(establishmentId: establishment.id)
        }
        .padding()
        .background(.thirdColorWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}




#Preview {
    PlayerEstablishmentGridItemView(establishment: .sample, viewModel: PlayerGetNearbyEstablishmentsViewModel())
        .environment(AppState())
}



