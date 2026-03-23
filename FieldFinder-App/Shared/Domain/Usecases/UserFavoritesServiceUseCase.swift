//
//  FavoriteUserUseCase.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 13/5/25.
//
import Foundation

protocol UserFavoritesServiceUseCaseProtocol {
    func addFavorite(establishmentId: String) async throws
    func removeFavorite(establishmentId: String) async throws
    func fetchFavorites() async throws -> [FavoriteEstablishmentModel]
    func setLikeEstablishment(establishmentId: String) async throws -> Bool
}

final class UserFavoritesServiceUseCase: UserFavoritesServiceUseCaseProtocol {
    private let repository: UserFavoritesServiceRepositoryProtocol

    init(repository: UserFavoritesServiceRepositoryProtocol = UserFavoritesServiceRepository()) {
        self.repository = repository
    }

    func addFavorite(establishmentId: String) async throws {
        try await repository.addFavorite(establishmentId: establishmentId)
    }

    func removeFavorite(establishmentId: String) async throws {
        try await repository.removeFavorite(establishmentId: establishmentId)
    }
    
    func fetchFavorites() async throws -> [FavoriteEstablishmentModel] {
        try await repository.fetchFavorites()
    }
    
    func setLikeEstablishment(establishmentId: String) async throws -> Bool {
        try await repository.setLikeEstablishment(establishmentId: establishmentId)
    }
}
