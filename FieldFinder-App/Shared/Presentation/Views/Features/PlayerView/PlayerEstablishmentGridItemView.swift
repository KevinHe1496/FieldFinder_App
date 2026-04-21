//
//  EstablishmentRowView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 12/5/25.
//

import SwiftUI

struct PlayerEstablishmentGridItemView: View {
    let establishment: EstablishmentResponse
    @State var viewModelUser = ProfileUserViewModel()
    @Bindable var viewModel: PlayerGetNearbyEstablishmentsViewModel
    @State private var favoriteState: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RemoteImageCardView(url: establishment.photoEstablishment.first)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 4)
                
                if case .success(let user) = viewModelUser.status, user.rol == "jugador" {
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
                
                // MARK: - Reclaim Owner Button
                Button {
                    print("Botón presionado")
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sportscourt.fill")
                            .foregroundStyle(.primaryColorGreen)
                        Text("Reclaim your field")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity) // Lo expande horizontalmente
                    .padding(.vertical, 12)     // Lo hace más alto y fácil de tocar
                    .background(Color.colorBlack)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
        .onAppear {
            favoriteState = viewModel.isFavorite(establishmentId: establishment.id)
            Task {
                try await viewModelUser.getMe()
            }
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
}



