//
//  UserAuthServiceRepositoryTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 26/5/25.
//

import XCTest
@testable import FieldFinder_App

final class UserAuthServiceRepositoryTests: XCTestCase {
    
    var mockAuthService: MockAuthService!
    var repository: UserAuthServiceRepository!

    override func setUpWithError() throws {
        try super.setUpWithError() // Asegura que la preparación del test no rompa la cadena de herencia
        mockAuthService = MockAuthService()
        repository = UserAuthServiceRepository(network: mockAuthService)
    }

    override func tearDownWithError() throws {
        mockAuthService = nil
        repository = nil
        try super.tearDownWithError() // Asegura que la limpieza finalice correctamente
    }

    func testLogin_ReturnsToken_WhenSuccessful()  async throws {
        
        // Arrange
        mockAuthService.shouldReturnToken = "login-token"
        mockAuthService.shouldThrowError = false
        
        // Act
        let token = try await repository.login(email: "test@email.com", password: "123456")
        
        // Assert
        XCTAssertEqual(token, "login-token", "The token returned by login should match the mocked token.")
        XCTAssertTrue(mockAuthService.loginCalled, "The login function of the mock should have been called.")
    }
    
    func testRegisterUser_ReturnsToken_Whensuccesful() async throws {
        // Arrange
        mockAuthService.shouldReturnToken = "register-token"
        mockAuthService.shouldThrowError = false
        
        // Act
        let token = try await repository.registerUser(
            name: "Kevin",
            email: "kevin@email.com",
            password: "123456",
            role: "dueno"
        )
        
        XCTAssertEqual(token, "register-token", "The token returned by registerUser should match the mocked token.")
        XCTAssertTrue(mockAuthService.registerCalled, "The registerUser function of the mock should have been called.")
    }
    
    func testLogin_ThrowsError_WhenServiceFails() async throws {
        
        //Arrange
        mockAuthService.shouldThrowError = true
       
        // Act & Assert
        do {
            _ = try await repository.login(email: "fai@mail.com", password: "123")
            XCTFail("Expected login to throw an error, but it did not.")
        } catch {
            XCTAssertTrue(mockAuthService.loginCalled, "The login function of the mock should have been called even if it failed.")
        }
    }
    
    func testRegister_ThrowsError_WhenServiceFails() async throws {
        
        // Arrange
        mockAuthService.shouldThrowError = true
        
        //Act & Assert
        do {
            _ = try await repository.registerUser(
                name: "Kevin",
                email: "fail@mail.com",
                password: "1234",
                role: "dueno"
            )
            XCTFail("Expected registerUser to throw an error, but it did not.")
        } catch {
            XCTAssertTrue(mockAuthService.registerCalled, "The registerUser function of the mock should have been called even if it failed.")
        }
    }

}
