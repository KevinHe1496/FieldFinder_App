import XCTest

@testable import FieldFinder_App
final class UserAuthServiceUseCaseTests: XCTestCase {
    
    var mockAuthService: MockAuthService!
    var repo: UserAuthServiceRepository!
    var useCase: UserAuthServiceUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAuthService = MockAuthService()
        repo = UserAuthServiceRepository(network: mockAuthService)
        useCase = UserAuthServiceUseCase(repo: repo)
    }
    
    override func tearDownWithError() throws {
        
        mockAuthService = nil
        repo = nil
        useCase = nil
        
        try super.tearDownWithError()
    }
    
    // MARK: Login
    
    func testLogin_Successful_ReturnsTrueAndStoresToken() async throws {
        
        //Arrange
        mockAuthService.shouldReturnToken = "mockedLoginToken"
        mockAuthService.shouldThrowError = false
        
        // Act
        let result = try await useCase.login(email: "andy@hotmail.com", password: "123456")
        // Assert
        XCTAssertTrue(result, "Expected login to return true for valid credentials.")
        XCTAssertTrue(mockAuthService.loginCalled, "Expected login to be called in repository.")
        XCTAssertEqual(useCase.tokenJWT, "mockedLoginToken", "Expected token to be saved.")
    }
    
    func testLogin_ThrowsError_WhenServiceFails() async throws {
        // Arrange
        mockAuthService.shouldThrowError = true
        // Act & Assert
        do {
            _ = try await useCase.login(email: "test@mail.com", password: "1234")
            XCTFail("Expected login to throw an error, but it did not.")
        } catch let error as NSError {
            XCTAssertEqual(error, NSError(domain: "MockAuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Login failed"]))
        }
    }
    
    
    // MARK: Register
    
    func testRegister_Succesful_ReturnsTrueAndStoresToken() async throws {
        
        //Arrange
        mockAuthService.shouldReturnToken = "mockedRegisterToken"
        mockAuthService.shouldThrowError = false
        
        //Act
        let result = try await useCase.registerUser(
            name: "Andy",
            email: "andy@hotmail.com",
            password: "123456",
            rol: "dueno"
        )
        
        // Assert
        XCTAssertTrue(result)
        XCTAssertEqual(useCase.tokenJWT, "mockedRegisterToken")
        XCTAssertTrue(mockAuthService.registerCalled)
    }
    
    func testRegister_ThrowsError_WhenServiceFails() async throws {
        // Arrage
        mockAuthService.shouldThrowError = true
        
        // Act & Assert
        do {
             _ = try await useCase.registerUser(
                name: "Andy",
                email: "fail@mail.com",
                password: "1234",
                rol: "jugador"
            )
            XCTFail("Expected login to throw an error, but it did not.")
        } catch let error as NSError {
            XCTAssertEqual(error, NSError(domain: "MockAuthService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Register failed"]))
        }
    }
    
    
}
