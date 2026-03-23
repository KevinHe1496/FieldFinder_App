//
//  UserProfileServiceTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 2/6/25.
//

import XCTest

@testable import FieldFinder_App
final class UserProfileServiceTests: XCTestCase {
    
    var sut: UserProfileService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let stubbedSession = URLSession(configuration: config)
        
        sut = UserProfileService(session: stubbedSession)
        
    }
    
    override func tearDownWithError() throws {
        
        URLProtocolStub.stubResponseData = nil
        URLProtocolStub.stubStatusCode = 200
        URLProtocolStub.error = nil
        sut = nil
        
        try super.tearDownWithError()
    }
    
    func test_FetchUser_ShouldReturnUser_WhenResponseIsValid() async throws {
        // Arrange
        let jsonData = try MockData.loadJSONData(name: "UserProfileResponse")
        URLProtocolStub.stubResponseData = jsonData
        URLProtocolStub.stubStatusCode = 200
        // Act
        let user = try await sut.fetchUser()
        // Assert
        XCTAssertNotNil(user)
        XCTAssertEqual(user.email, "usuario@ejemplo.com")
        XCTAssertEqual(user.id, "12345")
        XCTAssertEqual(user.rol, "dueno")
        XCTAssertEqual(user.name, "Juan Pérez")
    }
    
    func test_FectchUser_ShouldThrowError_WhenResponseIsInvalid() async throws {
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        // Act & Assert
        do {
            _ = try await sut.fetchUser()
            XCTFail("Expected errorParsingData to be thrown, but no error was thrown.")
        } catch let error as FFError {
            XCTAssertEqual(error, .errorParsingData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_UpdateUser_Suceeds_WhenStatusCodeIs200() async throws {
        // Arrange
        let jsonData = try MockData.loadJSONData(name: "UserProfileRequest")
        URLProtocolStub.stubResponseData = jsonData
        URLProtocolStub.stubStatusCode = 200
        // Act
        let updatedUser = try await sut.updateUser(name: "Andy Heredia")
        // Assert
        XCTAssertNotNil(updatedUser, "The updated user should not be nil.")
        XCTAssertEqual(updatedUser.name, "Andy Heredia", "The updated user's name does not match the expected name.")
    }
    
    func test_UpdateUser_ShouldThrowError_WhenResponseIsInvalid() async throws {
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        URLProtocolStub.stubStatusCode = 200
        // Act
        do {
            _ = try await sut.updateUser(name: "Andy Heredia")
            XCTFail("Expected errorParsingData to be thrown, but no error was thrown.")
        } catch let error as FFError {
            XCTAssertEqual(error, .dataNoReveiced)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_UpdateUser_ShouldThrowError_WhenStatusCodeIs400() async throws {
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        URLProtocolStub.stubStatusCode = 400
        // Act
        do {
            _ = try await sut.updateUser(name: "Andy Heredia")
            XCTFail("Expected errorParsingData to be thrown, but no error was thrown.")
        } catch let error as FFError {
            XCTAssertEqual(error, .errorFromApi(statusCode: 400))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_DeleteUser_ShouldSucceed_WhenIsValid() async throws {
        // Arrange
        URLProtocolStub.stubStatusCode = 200
        URLProtocolStub.stubResponseData = "Delete success".data(using: .utf8)
        // Act & Assert
        do {
            try await sut.deleteUser()
        } catch {
            XCTFail("Expected delete to succeed, but got error: \(error)")
        }
    }
    
    func test_DeleteUser_ShouldThrowError_WhenStatusCodeIs400() async throws {
        // Arrange
        URLProtocolStub.stubStatusCode = 400
        // Act & Assert
        do {
            try await sut.deleteUser()
        } catch let error as FFError {
            XCTAssertEqual(error, .errorFromApi(statusCode: -1))
        } catch {
            XCTFail("Expected delete to succeed, but got error: \(error)")
        }
    }
    
    
    
    
}
