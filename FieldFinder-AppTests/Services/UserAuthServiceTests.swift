//
//  UserAuthServiceTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 26/5/25.
//

import XCTest

@testable import FieldFinder_App
final class UserAuthServiceTests: XCTestCase {
    
    var sut: UserAuthService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let stubbedSession = URLSession(configuration: config)
        
        sut = UserAuthService(session: stubbedSession)
    }
    
    override func tearDownWithError() throws {
        
        URLProtocolStub.stubResponseData = nil
        URLProtocolStub.stubStatusCode = 200
        URLProtocolStub.error = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLogin_ReturnsToken_WhenResponseIsValid() async throws {
        // Arrange
        let refreshToken = "refreshTokenExample123"
        let accessToken = "accessTokenExample456"
        let json = """
        {
          "refreshToken": "\(refreshToken)",
          "accessToken": "\(accessToken)"
        }
        """.data(using: .utf8)
        URLProtocolStub.stubResponseData = json
        URLProtocolStub.stubStatusCode = 200
        
        // Act
        let result = try await sut.login(email: "test@mail.com", password: "123456")
        
        //Assert
        XCTAssertEqual(result, accessToken, "Expected token to be returned when the response is valid.")
    }
    
    func testLogin_ThrowsError_WhenResponseIsInvalid() async throws {
        // Arrage
        let refreshToken = "refreshTokenExample123"
        let accessToken = "accessTokenExample456"
        let invalidJson = """
        {
          "InvalidrefreshToken": "\(refreshToken)",
          "InvalidaccessToken": "\(accessToken)"
        }
        """.data(using: .utf8)
        URLProtocolStub.stubResponseData = invalidJson

        // Act & Assert
        do {
             _ = try await sut.login(email: "test@mail.com", password: "123456")
            XCTFail("Expected to throw errorParsingData, but it did not.")
        } catch let error as FFError {
            XCTAssertEqual(error, .errorParsingData)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRegisterUser_RetunrsToken_WhenResponseIsValid() async throws {
        // Arrange
        let refreshToken = "refreshTokenExample123"
        let accessToken = "accessTokenExample456"
        let json = """
        {
          "refreshToken": "\(refreshToken)",
          "accessToken": "\(accessToken)"
        }
        """.data(using: .utf8)
        URLProtocolStub.stubResponseData = json
        URLProtocolStub.stubStatusCode = 200
        
        // Act
        let result = try await sut.registerUser(
            name: "Kevin",
            email: "kevin@mail.com",
            password: "123456",
            role: "dueno"
        )
        
        // Assert
        XCTAssertEqual(result, accessToken, "Expected accessToken from successful registration response.")
    }
 
    func testRegister_ThrowsError_WhenResponseIsInvalid() async throws {
        // Arrage
        let refreshToken = "refreshTokenExample123"
        let accessToken = "accessTokenExample456"
        let invalidJson = """
        {
          "InvalidrefreshToken": "\(refreshToken)",
          "InvalidaccessToken": "\(accessToken)"
        }
        """.data(using: .utf8)
        URLProtocolStub.stubResponseData = invalidJson
        
        // Act & Assert
        do {
            _ = try await sut.registerUser(
                name: "Kevin",
                email: "kevin@email,com",
                password: "123456",
                role: "jugador"
            )
            XCTFail("Expected to throw errorParsingData, but it did not.")
        } catch let error as FFError {
            XCTAssertEqual(error, .errorParsingData, "Expected a errorParsingData when the response JSON does not match the expected model.")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    
}
