//
//  FavoriteUserRepository.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 13/5/25.
//
import Foundation

final class UserFavoritesServiceRepository: UserFavoritesServiceRepositoryProtocol {

    var network: UserFavoritesServiceProtocol

    init(network: UserFavoritesServiceProtocol = UserFavoritesService()) {
        self.network = network
    }

    func addFavorite(establishmentId: String) async throws {
        try await network.addFavorite(with: establishmentId)
    }

    func removeFavorite(establishmentId: String) async throws {
        try await network.removeFavorite(with: establishmentId)
    }
    
    func fetchFavorites() async throws -> [FavoriteEstablishmentModel] {
        try await network.fetchFavorites()
    }
    
    func setLikeEstablishment(establishmentId: String) async throws -> Bool {
        try await network.setLikeEstablishment(establishmentId: establishmentId)
    }
}
