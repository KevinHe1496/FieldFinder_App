//
//  RegisterFieldViewModelTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 30/5/25.
//

import XCTest

@testable import FieldFinder_App
final class RegisterFieldViewModelTests: XCTestCase {
    
    var mockFieldService: MockFieldService!
    var repository: FieldServiceRepository!
    var useCase: FieldServiceUseCase!
    var viewModel: RegisterFieldViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockFieldService = MockFieldService()
        repository = FieldServiceRepository(network: mockFieldService)
        useCase = FieldServiceUseCase(repo: repository)
        viewModel = RegisterFieldViewModel(useCase: useCase)
    }
    
    override func tearDownWithError() throws {
        
        mockFieldService = nil
        repository = nil
        useCase = nil
        viewModel = nil
        
        try super.tearDownWithError()
    }
    
    func test_RegisterField_ShouldShowMessage_WhenPriceIsEmpty() async   {
        // Arrange
        let request = FieldRequest(
            tipo: "Césped",
            modalidad: "7-7",
            precio: 0,
            iluminada: true,
            cubierta: true,
            establecimientoID: "1"
        )
        
        let fakeImages = [Data("image1".utf8), Data("image2".utf8)]
        // Act
        await viewModel.registerCancha(request, images: fakeImages, establishmentID: "1")
        // Assert
        XCTAssertEqual(viewModel.alertMessage, "The price field is required")
        XCTAssertFalse(viewModel.isLoading)
        
    }
    
    func test_RegisterField_ShouldShowMessage_WhenImagesAreEmpty() async {
        // Arrange
        let request = FieldRequest(
            tipo: "Césped",
            modalidad: "7-7",
            precio: 40.0,
            iluminada: true,
            cubierta: true,
            establecimientoID: "1"
        )
        // Act
        await viewModel.registerCancha(request, images: [], establishmentID: "1")
        // Assert
        XCTAssertEqual(viewModel.alertMessage, "Es obligatorio subir imágenes")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_RegisterField_ShouldShowMessage_WhenSuccesful() async {
        // Arrange
        let request = FieldRequest(
            tipo: "Césped",
            modalidad: "7-7",
            precio: 40.0,
            iluminada: true,
            cubierta: true,
            establecimientoID: "1"
        )
        let fakeImages = [Data("image1".utf8), Data("image2".utf8)]
        // Act
        await viewModel.registerCancha(request, images: fakeImages, establishmentID: "1")
        // Assert
        XCTAssertEqual(viewModel.alertMessage, "Field successfully registered")
        XCTAssertTrue(viewModel.shouldDismissAfterAlert)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    
    func test_EditField_ShouldShowMessage_WhenSuccesfull() async throws {
        // Arrange
        let request = FieldRequest(
            tipo: "Césped",
            modalidad: "7-7",
            precio: 40.0,
            iluminada: true,
            cubierta: true,
            establecimientoID: "1"
        )
        _ = [Data("image1".utf8), Data("image2".utf8)]
        // Act
        try await viewModel.editCancha(canchaID: "1", canchaModel: request)
        // Assert
        XCTAssertEqual(viewModel.alertMessage, "The field has been successfully updated.")
    }
    
    func test_DeleteField_ShouldShowMessage_WhenSuccesfull() async throws {
        // Act
        try await viewModel.deleteCancha(canchaID: "1")
        // Assert
        XCTAssertEqual(viewModel.alertMessage, "The field has been successfully deleted.")
    }
    
}

