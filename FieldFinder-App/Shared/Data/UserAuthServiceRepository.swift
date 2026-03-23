import Foundation

final class UserAuthServiceRepository: UserAuthServiceRepositoryProtocol {
     
    var network: AuthServiceProtocol
    
    init(network: AuthServiceProtocol = UserAuthService()) {
        self.network = network
    }
    
    func login(email: String, password: String) async throws -> String {
        try await network.login(email: email, password: password)
    }
    
    func registerUser(name: String, email: String, password: String, role: String) async throws -> String {
        try await network.registerUser(name: name, email: email, password: password, role: role)
    }
    
}
