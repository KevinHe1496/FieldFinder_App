//
//  FavoriteEstablishmentRowView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 13/5/25.
//
import SwiftUI

struct FavoriteGridItemView: View {
    let establishment: FavoriteEstablishment
    @State private var isFavorite: Bool
    var viewModel: PlayerGetNearbyEstablishmentsViewModel

    init(establishment: FavoriteEstablishment, viewModel: PlayerGetNearbyEstablishmentsViewModel) {
        self.establishment = establishment
        self.viewModel = viewModel
        _isFavorite = State(initialValue: true) // ya está en favoritos
    }

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

    }
}

