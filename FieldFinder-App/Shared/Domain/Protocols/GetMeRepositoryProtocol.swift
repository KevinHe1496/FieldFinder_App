import Foundation

protocol UserProfileServiceRepositoryProtocol {
    func getUser() async throws -> UserProfileResponse
    func updateUser(name: String) async throws -> UserProfileRequest
    func deleteUser() async throws
}
