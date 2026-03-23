//
//  FieldServiceTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 29/5/25.
//

import XCTest

@testable import FieldFinder_App
final class FieldServiceTests: XCTestCase {
    
    var sut: FieldService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let stubbedSession = URLSession(configuration: config)
        
        sut = FieldService(session: stubbedSession)
    }
    
    override func tearDownWithError() throws {
        
        URLProtocolStub.stubResponseData = nil
        URLProtocolStub.stubStatusCode = 200
        URLProtocolStub.error = nil
        sut = nil
        
        try super.tearDownWithError()
    }
    
    func test_CreateField_ReturnsFieldID_WhenRequestIsValid() async throws {
        // Arrange
        let jsonData =  try MockData.loadJSONData(name: "IDResponse")
        URLProtocolStub.stubResponseData = jsonData
        URLProtocolStub.stubStatusCode = 200
        
        // Act
        
        let request = FieldRequest(
            tipo: "Céspec",
            modalidad: "7-7",
            precio: 40,
            iluminada: true,
            cubierta: true,
            establecimientoID: "1"
        )
        let field = try await sut.createField(request, establishmentID: "1")
        
        // Assert
        XCTAssertNotNil(field, "Expected a valid Field ID to be returned.")
        XCTAssertEqual(field, "1", "Expected Field ID to match the mocked response.")
        
        
    }
    
    func test_CreateField_ThrowsErrorParsingData_WhenResponseIsEmpty() async throws {
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        URLProtocolStub.stubStatusCode = 200
        
        let request = FieldRequest(
            tipo: "Céspec",
            modalidad: "7-7",
            precio: 40,
            iluminada: true,
            cubierta: true,
            establecimientoID: "1"
        )
        
        // Act & Assert
        do {
            _ = try await sut.createField(request, establishmentID: "1")
            XCTFail("Expected FFError to be thrown, but createField completed successfully.")
        } catch let error as FFError {
            XCTAssertEqual(error, .errorParsingData)
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
    }
    
    func test_CreateField_ThrowsErrorFromApi_WhenStatusCodeIs400() async throws {
        
        // Arrange
        
        URLProtocolStub.stubResponseData = Data()
        URLProtocolStub.stubStatusCode = 400
        
        let request = FieldRequest(
            tipo: "Céspec",
            modalidad: "7-7",
            precio: 40,
            iluminada: true,
            cubierta: true,
            establecimientoID: "1"
        )
        
        // Act & Assert
        
        do {
            _ = try await sut.createField(request, establishmentID: "1")
            XCTFail("Expected FFError to be thrown, but createField completed successfully.")
        } catch let error as FFError {
            XCTAssertEqual(error, .errorFromApi(statusCode: 400))
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
    }
    
    func test_UploadFieldImages_Succeeds_WhenStatusCodeIs200() async throws {
        // Arrange
        URLProtocolStub.stubStatusCode = 200
        URLProtocolStub.stubResponseData = "Upload success".data(using: .utf8)
        
        let dummyImage = UIImage(systemName: "photo")?.jpegData(compressionQuality: 1.0)
        guard let imagesData = dummyImage else {
            return
        }
        let images = [imagesData]
        
        do {
            try await sut.uploadFieldImages(fieldID: "1", images: images)
        } catch {
            XCTFail("Expected upload to succeed, but got error: \(error)")
        }
    }
    
    func test_UploadFieldImages_ThrowsError_WhenStatusCodeIs500() async {
        // Arrange
        URLProtocolStub.stubResponseData = "Internal Server Error".data(using: .utf8)
        URLProtocolStub.stubStatusCode = 500
        
        let dummyImage = UIImage(systemName: "photo")?.jpegData(compressionQuality: 1.0)
        guard let imagesData = dummyImage else {
            return
        }
        let images = [imagesData]
        
        do {
            _ = try await sut.uploadFieldImages(fieldID: "1", images: images)
        } catch let error as FFError {
            XCTAssertEqual(error, .requestWasNil)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    
    func test_UpdateField_Suceeds_WhenStatusCodeIs200() async throws {
        // Arrange
        
        let jsonData = try MockData.loadJSONData(name: "FieldRequest")
        
        URLProtocolStub.stubStatusCode = 200
        URLProtocolStub.stubResponseData = jsonData
        
        let request = FieldRequest(
            tipo: "Céspec",
            modalidad: "7-7",
            precio: 40,
            iluminada: true,
            cubierta: true,
            establecimientoID: "1"
        )
        
        // Act & Assert
        do {
            _ = try await sut.updateField(fieldID: "1", fieldModel: request)
        } catch {
            XCTFail("Expected update to succeed, but got error: \(error)")
        }
    }
    
    func test_UpdateField_ThrowsError_WhenStatusCodeIs500() async {
        //Arrange
        URLProtocolStub.stubStatusCode = 500
        
        let request = FieldRequest(
            tipo: "Céspec",
            modalidad: "7-7",
            precio: 40,
            iluminada: true,
            cubierta: true,
            establecimientoID: "1"
        )
        
        // Act & Assert
        
        do {
            _ = try await sut.updateField(fieldID: "1", fieldModel: request)
        } catch let error as FFError {
            XCTAssertEqual(error, .errorFromApi(statusCode: -1))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
    }
    
    func test_FetchField_ReturnsField_WhenResponseIsValid() async throws {
        
        // Arrange
        let jsonData = try MockData.loadJSONData(name: "FieldResponse")
        URLProtocolStub.stubResponseData = jsonData
        URLProtocolStub.stubStatusCode = 200
        
        // Act
        let field = try await sut.fetchField(with: "1")
        
        // Assert
        XCTAssertNotNil(field)
        XCTAssertEqual(field.id, "abc123")
        XCTAssertEqual(field.tipo, "Fútbol 11")
        XCTAssertEqual(field.modalidad, "Torneo")
        XCTAssertEqual(field.precio, 60.0)
        XCTAssertTrue(field.cubierta)
        XCTAssertTrue(field.iluminada)
        XCTAssertEqual(field.fotos.first, "https://fieldfinder.com/uploads/canchas/cancha1.jpg")
        
    }
    
    func test_FetchField_ThrowsError_WhenResponseIsInvalid() async throws {
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        URLProtocolStub.stubStatusCode = 200
        // Act & Assert
        do {
            _ = try await sut.fetchField(with: "1")
            XCTFail("Expected to throw decodingError, but it did not.")
        } catch let error as FFError {
            XCTAssertEqual(error, .decodingError, "Expected a decodingError when the response JSON does not match the expected model.")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    
    func test_DeleteField_ShouldSucceed_WhenIdIsValid() async  throws{
        // Arrange
        URLProtocolStub.stubStatusCode = 200
        URLProtocolStub.stubResponseData = "Delete success".data(using: .utf8)
        
        // Act
        do {
            try await sut.deleteField(fieldID: "1")
        } catch {
            XCTFail("Expected delete to succeed, but got error: \(error)")
        }
    }
    
    func test_DeleteField_ShouldThrowError_WhenStatusCodeIs400() async throws {
        // Arrange
        URLProtocolStub.stubStatusCode = 400
        // Act & Assert
        do {
            _ = try await sut.deleteField(fieldID: "1")
            XCTFail("Expected error, but got success")
        } catch let error as FFError {
            XCTAssertEqual(error, .errorFromApi(statusCode: -1))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
}
