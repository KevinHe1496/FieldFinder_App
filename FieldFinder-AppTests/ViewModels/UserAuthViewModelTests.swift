//
//  UserAuthViewModelTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 27/5/25.
//

import XCTest

@testable import FieldFinder_App
final class UserAuthViewModelTests: XCTestCase {
    
    var mockAuthService: MockAuthService!
    var repo: UserAuthServiceRepository!
    var useCase: UserAuthServiceUseCase!
    var viewModel: UserAuthViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAuthService = MockAuthService()
        repo = UserAuthServiceRepository(network: mockAuthService)
        useCase = UserAuthServiceUseCase(repo: repo)
        viewModel = UserAuthViewModel(appState: AppState(), useCase: useCase)
    }
    
    override func tearDownWithError() throws {
        mockAuthService = nil
        repo = nil
        useCase = nil
        viewModel = nil
        
        try super.tearDownWithError()
    }
    
    // MARK: ValidateFields Function
    
    func testValidateFields_WhenFieldsAreEmpty_ShouldReturnErrorMessage() throws {
        let result = viewModel.validateFields(name: "", email: "", password: "")
        XCTAssertEqual(result, "Todos los campos son requeridos.")
    }
    
    func testValidateFields_WhenEmailIsInvalid_ShouldReturnErrorMessage() {
        let result = viewModel.validateFields(name: "Andy", email: "andyemailcom", password: "123456")
        XCTAssertEqual(result, "Ingresa un correo electrónico válido, por ejemplo: usuario@ejemplo.com")
    }
    
    func testValidateFields_WhenPasswordIsInvalid_ShouldReturnErrorMessage() {
        let result = viewModel.validateFields(name: "Andy", email: "andy@mail.com", password: "123")
        XCTAssertEqual(result, "La contraseña debe tener al menos 6 caracteres.")
    }
    
    // MARK: Register Function
    
    func testRegisterUser_WhenAuthServiceFails_ShouldShowError() async throws {
        // Arrange
        mockAuthService.shouldThrowError = true
        
        // Act & Assert
        let result = await viewModel.registerUser(name: "Andy", email: "andy@hotmail.com", password: "123456", rol: "dueno")
        
        XCTAssertEqual(result, "Algo salió mal")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testRegisterUser_WhenValidAsDueno_ShouldUpdateAppStateToRegister() async {
        
        let result = await viewModel.registerUser(name: "Andy", email: "andy@hotmail.com", password: "123456", rol: "dueno")
        XCTAssertNotNil(result)
        XCTAssertFalse(viewModel.isLoading)
    }
}
