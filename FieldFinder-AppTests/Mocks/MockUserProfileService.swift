import Foundation

@testable import FieldFinder_App
final class MockUserProfileService: UserProfileServiceProtocol {
    

    var didCallDeleteUser = false
    var didCallUpdateUser = false
    var lastUpdatedUser: String?
    
    func fetchUser() async throws -> UserProfileResponse {
        mockUserProfileResponse()
    }
    
    func updateUser(name: String) async throws -> UserProfileRequest {
        didCallUpdateUser = true
        lastUpdatedUser = name
        return mockUserProfileRequest()
    }
    
    func deleteUser() async throws {
        didCallDeleteUser = true
    }
    
    
    func mockUserProfileResponse() -> UserProfileResponse {
        return UserProfileResponse(
            email: "andy@example.com",
            id: "1",
            rol: "dueno",
            name: "Andy",
            establecimiento: []
        )
    }
    
    func mockUserProfileRequest() -> UserProfileRequest {
        return UserProfileRequest(name: "Andy Heredia")
    }
    
}

