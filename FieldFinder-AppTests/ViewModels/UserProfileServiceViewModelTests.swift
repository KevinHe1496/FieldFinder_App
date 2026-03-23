//
//  UserProfileServiceViewModelTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 3/6/25.
//

import XCTest

@testable import FieldFinder_App
final class UserProfileServiceViewModelTests: XCTestCase {
    
    var mockUserProfileService: MockUserProfileService!
    var repository: UserProfileServiceRepository!
    var useCase: UserProfileServiceUseCase!
    var viewModel: ProfileUserViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockUserProfileService = MockUserProfileService()
        repository = UserProfileServiceRepository(network: mockUserProfileService)
        useCase = UserProfileServiceUseCase(repo: repository)
        viewModel =  ProfileUserViewModel(useCase: useCase)
        
    }
    
    override func tearDownWithError() throws {
        
        mockUserProfileService = nil
        repository = nil
        useCase = nil
        viewModel = nil
        
        try super.tearDownWithError()
    }
    
    func test_getMe_ShouldReturnUser_WhenSuccessful() async throws {
        try await viewModel.getMe()
        
        switch viewModel.status {
        case .success(let user):
            XCTAssertEqual(user.email, "andy@example.com")
            XCTAssertEqual(user.name, "Andy")
            XCTAssertEqual(user.id, "1")
            XCTAssertEqual(user.rol, "dueno")
        default:
            XCTFail("Expected success state")
        }
    }
    
    func test_updateUser_ShouldCallUseCase_WhenCalled() async throws {
        let nameToUpdate = "NewName"
        try await viewModel.updateUser(name: nameToUpdate)
        XCTAssertTrue(mockUserProfileService.didCallUpdateUser)
    }
    
    func test_delete_ShouldCallUseCase_WhenCalled() async throws {
        try await viewModel.delete()
        XCTAssertTrue(mockUserProfileService.didCallDeleteUser)
    }
    
    
}
