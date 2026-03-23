//
//  UserFavoritesServiceRepository.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 3/6/25.
//

import XCTest

@testable import FieldFinder_App
final class UserFavoritesServiceRepositoryTests: XCTestCase {
    
    var mock: MockUserFavoritesService!
    var repository: UserFavoritesServiceRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mock = MockUserFavoritesService()
        repository = UserFavoritesServiceRepository(network: mock)
        
    }

    override func tearDownWithError() throws {
       
        mock = nil
        repository = nil
        
        try super.tearDownWithError()
    }

    func test_AddFavorite_ShouldAddEstablishment_WhenIdIsValid() async throws {
        try await repository.addFavorite(establishmentId: "123")
        XCTAssertTrue(mock.didCallAddFavorite)
    }
    
    func test_RemoveFavorite_ShouldRemoveEstablishment_WhenIdIsValid() async throws {
        try await repository.removeFavorite(establishmentId: "123")
        XCTAssertTrue(mock.didCallRemoveFavorite)
    }

    
    func test_FecthEstablishments_ShouldReturnEstablishments_WhenSuccessful() async throws {
        let establishments = try await repository.fetchFavorites()
        XCTAssertNotNil(establishments)
        XCTAssertEqual(establishments.count, 2)
        
        XCTAssertEqual(establishments.first?.id, "1")
        XCTAssertEqual(establishments.first?.name, "Show Gol")
        XCTAssertEqual(establishments.first?.address, "Av. Amazonas")
        
        XCTAssertEqual(establishments.last?.id, "2")
        XCTAssertEqual(establishments.last?.name, "Bocha")
        XCTAssertEqual(establishments.last?.address, "San Gabriel")
    }
}


