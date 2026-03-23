import Foundation

final class UserProfileServiceRepository: UserProfileServiceRepositoryProtocol {
    
    let network: UserProfileServiceProtocol
    
    init(network: UserProfileServiceProtocol = UserProfileService()) {
        self.network = network
    }
    
    func fetchUser() async throws -> UserProfileResponse {
        try await network.fetchUser()
    }
    
    func updateUser(name: String) async throws -> UserProfileRequest {
        try await network.updateUser(name: name)
    }
    
    func deleteUser() async throws {
        try await network.deleteUser()
    }
}
