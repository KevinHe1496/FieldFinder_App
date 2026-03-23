//
//  UserFavoritesServiceViewModelTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 3/6/25.
//

import XCTest

@testable import FieldFinder_App
final class UserFavoritesServiceViewModelTests: XCTestCase {

    var mock: MockUserFavoritesService!
    var repository: UserFavoritesServiceRepository!
    var useCase: UserFavoritesServiceUseCase!
    var viewModel: PlayerGetNearbyEstablishmentsViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mock = MockUserFavoritesService()
        repository = UserFavoritesServiceRepository(network: mock)
        useCase = UserFavoritesServiceUseCase(repository: repository)
        viewModel = PlayerGetNearbyEstablishmentsViewModel(favoriteUseCase: useCase)
        
    }

    override func tearDownWithError() throws {
       
        mock = nil
        repository = nil
        useCase = nil
        viewModel = nil
        
        try super.tearDownWithError()
    }

    func test_ToggleFavorite_CallsAddFavorite_WhenIsFavoriteTrue() async throws {

        // Act
        try await viewModel.toggleFavorite(establishmentId: "123", isFavorite: true)

        // Assert
        XCTAssertTrue(mock.didCallAddFavorite, "addFavorite should have been called.")
      
    }
    
    func test_ToggleFavorite_CallsRemoveFavorite_WhenIsFavoriteFalse() async throws {
        // Act
        try await viewModel.toggleFavorite(establishmentId: "123", isFavorite: false)

        // Assert
        XCTAssertTrue(mock.didCallRemoveFavorite, "removeFavorite should have been called.")
     
    }


}
