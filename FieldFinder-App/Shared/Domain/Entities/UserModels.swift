//
//  Untitled.swift
//  FieldFinder-App
//
//  Created by Andy Heredia on 21/5/25.
//

// Register
struct RegisterUserRequest: Codable {
    let name: String
    let email: String
    let password: String
    let rol: String
}

// Response
struct LoginResponse: Codable {
    let refreshToken: String
    let accessToken: String
}


// Get
struct UserProfileResponse: Codable {
    let email: String
    let id: String
    let rol: String
    let name: String
    let establecimiento: [EstablishmentResponse]
    
    var userRole: UserRole? {
        switch rol.lowercased() {
        case "jugador":
            return .jugador
        case "dueno":
            return .dueno
        default:
            return nil
        }
    }
}
// Update
struct UserProfileRequest: Codable {
    let name: String
}
