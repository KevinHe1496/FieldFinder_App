//
//  FavoriteUserRepositoryProtocol.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 13/5/25.
//
import Foundation

protocol UserFavoritesServiceRepositoryProtocol {
    func addFavorite(establishmentId: String) async throws
    func removeFavorite(establishmentId: String) async throws
    func fetchFavorites() async throws -> [FavoriteEstablishmentModel]
    func setLikeEstablishment(establishmentId: String) async throws -> Bool
}

