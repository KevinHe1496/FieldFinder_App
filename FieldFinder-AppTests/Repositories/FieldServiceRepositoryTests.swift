//
//  FieldServiceRepositoryTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 30/5/25.
//

import XCTest

@testable import FieldFinder_App
final class FieldServiceRepositoryTests: XCTestCase {
    
    var mockFieldService: MockFieldService!
    var repository: FieldServiceRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockFieldService = MockFieldService()
        repository = FieldServiceRepository(network: mockFieldService)
        
    }

    override func tearDownWithError() throws {
        
        mockFieldService = nil
        repository = nil
        
        try super.tearDownWithError()
    }

    func test_GivenValidRequest_WhenCreateField_ThenReturnsFieldId() async throws {
        // Act
        let resultID = try await repository.createField(mockFieldService.getMockFieldRequest(), establishmentID: "2")
        // Assert
        XCTAssertEqual(resultID, "mock_field_id")
    }
    
    func test_UploadFieldImages_CallsServiceWithCorrectData() async throws {
        // Arrange
        let fakeImages = [Data("image1".utf8), Data("image2".utf8)]
        // Act
        try await repository.uploadFieldImages(fieldID: "1", images: fakeImages)
        // Assert
        XCTAssertEqual(mockFieldService.lastUploadedImages.count, 2)
        XCTAssertTrue(mockFieldService.didCallUploadImages)
    }
    
    func test_UpdateField_callsServiceWithCorrectModel() async throws {
        // Arrange
        let updatedRequest = FieldRequest(
            tipo: "Césped",
            modalidad: "11-11",
            precio: 50.0,
            iluminada: false,
            cubierta: true,
            establecimientoID: "2"
        )
        
        // Act
       let result = try await repository.updateField(fieldID: "1", fieldModel: updatedRequest)
        // Assert
        //Updated Request
        XCTAssertTrue(mockFieldService.didCallUpdateField)
        XCTAssertEqual(mockFieldService.lastUpdatedField?.precio, 50.0)
        XCTAssertEqual(mockFieldService.lastUpdatedField?.tipo, "Césped")
        XCTAssertEqual(mockFieldService.lastUpdatedField?.modalidad, "11-11")
        XCTAssertEqual(mockFieldService.lastUpdatedField?.iluminada, false)
        XCTAssertEqual(mockFieldService.lastUpdatedField?.cubierta, true)
        
        
        // Original Request
        XCTAssertEqual(result.tipo, "Sintético")
        XCTAssertEqual(result.precio, 40.0)
        XCTAssertEqual(result.modalidad, "7-7")
        XCTAssertTrue(result.iluminada)
        XCTAssertTrue(result.cubierta)
    }
    
    func test_FetchField_ShouldReturnField_WhenIDIsValid() async throws {
        // Act
        let field = try await repository.fetchField(with: "1")
        // Assert
        XCTAssertEqual(field.id, "cancha001")
        XCTAssertEqual(field.tipo, "Fútbol 7")
        XCTAssertEqual(field.modalidad, "Partido completo")
        XCTAssertEqual(field.precio, 30.0)
        XCTAssertTrue(field.iluminada)
        XCTAssertTrue(field.cubierta)
    }
    
    func test_DeleteField_ShouldDeleteField_WhenIdIsValid() async throws {
        // Act
        try await repository.deleteField(fieldID: "1")
        XCTAssertTrue(mockFieldService.didCallDeleteField)
    }
}
