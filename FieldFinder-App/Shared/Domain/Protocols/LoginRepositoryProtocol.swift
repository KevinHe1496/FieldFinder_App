import Foundation

protocol UserAuthServiceRepositoryProtocol {
    func login(email: String, password: String) async throws -> String
    func registerUser(name: String, email: String, password: String, role: String) async throws -> String
}
