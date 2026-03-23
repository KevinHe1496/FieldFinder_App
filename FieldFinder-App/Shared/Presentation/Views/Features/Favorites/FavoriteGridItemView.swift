//
//  FavoriteEstablishmentRowView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 13/5/25.
//
import SwiftUI

struct FavoriteGridItemView: View {
    let establishment: FavoriteEstablishmentModel
    var viewModel: PlayerGetNearbyEstablishmentsViewModel
    
    @State private var isFavorite: Bool = true // Asume que viene desde favoritos

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: establishment.photoEstablishment.first) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } placeholder: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 180)
                        ProgressView()
                    }
                }

                FavoriteButton(isFavorite: $isFavorite) { 
                    Task {
                        try await viewModel.setLikeHero(establishmentId: establishment.id)
                        await MainActor.run {
                            isFavorite = viewModel.isFavorite(establishmentId: establishment.id)
                        }
                    }
                }
                .padding(12)
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
                        .foregroundStyle(.colorBlack)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(.thirdColorWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
        .padding(.horizontal)
        .onAppear {
            isFavorite = viewModel.isFavorite(establishmentId: establishment.id)
        }
    }
}


#Preview {
    FavoriteGridItemView(establishment: FavoriteEstablishmentModel(id: "asd", name: "asd", address: "asd", fotos: ["asd", "asd"]), viewModel: PlayerGetNearbyEstablishmentsViewModel())
}
