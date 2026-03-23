//
//  UserFavoritesServiceTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 2/6/25.
//

import XCTest

@testable import FieldFinder_App
final class UserFavoritesServiceTests: XCTestCase {
    
    var sut: UserFavoritesService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let stubbedSession = URLSession(configuration: config)
        
        sut = UserFavoritesService(session: stubbedSession)
    }
    
    override func tearDownWithError() throws {
        
        URLProtocolStub.stubResponseData = nil
        URLProtocolStub.stubStatusCode = 200
        URLProtocolStub.error = nil
        sut = nil
        
        try super.tearDownWithError()
    }
    
    func test_AddFavorite_Succeeds_WhenStatusCodeIs200() async throws {
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        URLProtocolStub.stubStatusCode = 200
        
        let establishmentId = "123"
        
        // Act & Assert
        do {
            try await sut.addFavorite(with: establishmentId)
            XCTAssertTrue(true, "The addFavorite call succeeded as expected.")
        } catch {
            XCTFail("Expected to succeed but got error: \(error)")
        }
    }
    
    func test_AddFavorite_ShouldThrowError_WhenStatusCodeIs400() async throws {
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        URLProtocolStub.stubStatusCode = 400
        
        let establishmentId = "123"
        
        // Act & Assert
        do {
            try await sut.addFavorite(with: establishmentId)
            XCTFail("Expected errorFromApi to be thrown, but no error was thrown.")
        } catch let error as FFError {
            XCTAssertEqual(error, .errorFromApi(statusCode: 400))
        } catch {
            XCTFail("Expected to succeed but got error: \(error)")
        }
    }
    
    
    func test_RemoveFavorite_Succeeds_WhenStatusCodeIs200() async throws {
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        URLProtocolStub.stubStatusCode = 200
        
        let establishmentId = "123"
        // Act & Assert
        do {
            try await sut.removeFavorite(with: establishmentId)
            XCTAssertTrue(true, "The removeFavorite call succeeded as expected.")
        } catch {
            XCTFail("Expected to succeed but got error: \(error)")
        }
    }
    
    func test_RemoveFavorite_ShouldThrowError_WhenStatusCodeIs400() async throws {
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        URLProtocolStub.stubStatusCode = 400
        
        let establishmentId = "123"
        // Act & Assert
        do {
            try await sut.removeFavorite(with: establishmentId)
            XCTFail("Expected errorFromApi to be thrown, but no error was thrown.")
        } catch let error as FFError {
            XCTAssertEqual(error, .errorFromApi(statusCode: 400))
        } catch {
            XCTFail("Expected to succeed but got error: \(error)")
        }
    }
    
    func test_FetchFavorites_ShouldReturnEstablishments_WhenResponseIsValid() async throws {
        // Arrange
        let jsonData = try MockData.loadJSONData(name: "FavoriteEstablishmentModel")
        URLProtocolStub.stubResponseData = jsonData
        URLProtocolStub.stubStatusCode = 200
        // Act
        let favorites = try await sut.fetchFavorites()
        // Assert
        XCTAssertNotNil(favorites)
        XCTAssertEqual(favorites.count, 2)
    }
    
    
    func test_FetchFavorites_ShouldThrowError_WhenResponseIsInvalid() async throws {
        
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        URLProtocolStub.stubStatusCode = 200
        // Act & Assert
        do {
            _ = try await sut.fetchFavorites()
            XCTFail()
        } catch let error as FFError {
            XCTAssertEqual(error, .dataNoReveiced)
        } catch {
            XCTFail("Expected to succeed but got error: \(error)")
        }
    }
    
    
    
    
    
}
