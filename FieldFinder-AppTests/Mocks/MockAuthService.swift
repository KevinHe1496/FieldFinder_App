import Foundation

@testable import FieldFinder_App
final class MockAuthService: AuthServiceProtocol {
    // Propiedades configurables para simular resultados
    
    var loginCalled = false
    var registerCalled = false
    
    var shouldReturnToken = "mockedToken"
    var shouldThrowError = false
    
    func login(email: String, password: String) async throws -> String {
        loginCalled = true
        
        if shouldThrowError {
            throw NSError(domain: "MockAuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Login failed"])
        }
        
        return shouldReturnToken
    }
    
    func registerUser(name: String, email: String, password: String, role: String) async throws -> String {
        registerCalled = true
        
        if shouldThrowError {
            throw NSError(domain: "MockAuthService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Register failed"])
        }
        
        return shouldReturnToken
    }
}
