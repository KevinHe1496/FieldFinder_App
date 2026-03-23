import Foundation

@testable import FieldFinder_App
final class MockUserFavoritesService: UserFavoritesServiceProtocol {
    func setLikeEstablishment(establishmentId: String) async throws -> Bool {
        true
    }
    
    
    var didCallRemoveFavorite = false
    var didCallAddFavorite = false
    var didCallUpdateField = false
    
    
    func addFavorite(with establishmentId: String) async throws {
        didCallAddFavorite = true
    }
    
    func removeFavorite(with establishmentId: String) async throws {
        didCallRemoveFavorite = true
    }
    
    func fetchFavorites() async throws -> [FavoriteEstablishmentModel] {
        mockFavoriteEstablishmentModel()
    }
    
    func mockFavoriteEstablishmentModel() -> [FavoriteEstablishmentModel] {
        return [
            FavoriteEstablishmentModel(id: "1", name: "Show Gol", address: "Av. Amazonas", fotos: []),
            FavoriteEstablishmentModel(id: "2", name: "Bocha", address: "San Gabriel", fotos: [])
        ]
    }
    
    
}
