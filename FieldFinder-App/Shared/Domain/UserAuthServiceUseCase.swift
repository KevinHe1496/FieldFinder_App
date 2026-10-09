//
//  LoginUseCase.swift
//  FieldFinder-App
//
//  Created by Andy Heredia on 8/5/25.
//

import Foundation

protocol UserAuthServiceUseCaseProtocol {
    var repo: UserAuthServiceRepositoryProtocol { get set }
    func login(email: String, password: String) async throws -> Bool
    func logout() async throws -> Void
    func validateToken() async -> Bool
    func registerUser(name: String, email: String, password: String, rol: String) async throws -> Bool
}


final class UserAuthServiceUseCase: UserAuthServiceUseCaseProtocol {
    
    var repo: UserAuthServiceRepositoryProtocol
    
    @FFPersistenceKeyChain(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
    var tokenJWT
    
    init(repo: UserAuthServiceRepositoryProtocol = UserAuthServiceRepository()) {
        self.repo = repo
    }
    
    func login(email: String, password: String) async throws -> Bool {
        // Guardamos el token
        let token = try await repo.login(email: email, password: password)
        // Verificamos si el token nos vino vacio o no
        if token != "" {
           // KeyChainFF().savePK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN, value: token)
            tokenJWT = token
            return true // Success
        } else {
           // KeyChainFF().deletePK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
            tokenJWT = ""
            return false // Error
        }
    }
    
    func logout() async throws {
        FFSessionTokens.clear()
    }
    
    /// Devuelve `false` solo si no hay sesión o el servidor rechazó el refresh token.
    /// Si no hay internet se asume que la sesión sigue siendo válida para no cerrarla por error.
    func validateToken() async -> Bool {
        let token = tokenJWT
        guard !token.isEmpty else { return false }
        
        if !FFSessionTokens.isExpired(token) {
            return true
        }
        
        switch await FFTokenRefresher.shared.refresh() {
        case .refreshed, .unreachable:
            return true
        case .rejected:
            return false
        }
    }
    
    // Create user
    
    func registerUser(name: String, email: String, password: String, rol: String) async throws -> Bool {
        let token = try await repo.registerUser(name: name, email: email, password: password, role: rol)
        
        if token != "" {
            tokenJWT = token
            return true
        } else {
            tokenJWT = ""
            return false
        }
    }
    
    
}
