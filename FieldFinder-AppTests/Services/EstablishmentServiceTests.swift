//
//  EstablishmentServiceTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 27/5/25.
//

import XCTest
import CoreLocation

@testable import FieldFinder_App
final class EstablishmentServiceTests: XCTestCase {
    
    var sut: EstablishmentService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let stubbedSession = URLSession(configuration: config)
        
        sut = EstablishmentService(session: stubbedSession)
    }
    
    override func tearDownWithError() throws {
        
        URLProtocolStub.stubResponseData = nil
        URLProtocolStub.stubStatusCode = 200
        URLProtocolStub.error = nil
        
        sut = nil
        try super.tearDownWithError()
    }
    
    func testCreateEstablishment_ReturnsEstablishmentID_WhenRequestIsValid() async throws {
        // Arrange
        let data = try MockData.loadJSONData(name: "IDResponse")
        URLProtocolStub.stubResponseData = data
        URLProtocolStub.stubStatusCode = 200
        
        let request = EstablishmentRequest(
            name: "Bocha",
            info: "Cancha sintética de fútbol 7 con iluminación nocturna",
            address: "123 Main St",
            address2: "Carlota Jaramillo",
            parqueadero: true,
            vestidores: true,
            bar: true,
            banos: true,
            duchas: false,
            latitude: -0.2299,
            longitude: -78.5249,
            phone: "0998041792"
        )
        // Act
        let establishment = try await sut.createEstablishment(request)
        // Assert
        XCTAssertNotNil(establishment, "Expected a valid Establishment ID to be returned.")
        XCTAssertEqual(establishment, "1", "Expected Establishment ID to match the mocked response.")
    }
    
    func testCreateEstablishment_ThrowsErrorParsingData_WhenResponseIsEmpty() async throws {
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        
        let request = EstablishmentRequest(
            name: "Bocha",
            info: "Cancha sintética de fútbol 7 con iluminación nocturna",
            address: "123 Main St",
            address2: "Carlota Jaramillo",
            parqueadero: true,
            vestidores: true,
            bar: true,
            banos: true,
            duchas: false,
            latitude: -0.2299,
            longitude: -78.5249,
            phone: "0998041792"
        )
        // Act & Assert
        do {
            _ = try await sut.createEstablishment(request)
            XCTFail("Expected FFError to be thrown, but createEstablishment completed successfully.")
        } catch let error as FFError {
            XCTAssertEqual(error, .errorParsingData)
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
    }
    
    func testCreateEstablishment_ThrowsErrorFromApi_WhenStatusCodeIs400() async throws {
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        URLProtocolStub.stubStatusCode = 400
        
        let request = EstablishmentRequest(
            name: "Bocha",
            info: "Cancha sintética de fútbol 7 con iluminación nocturna",
            address: "123 Main St",
            address2: "Carlota Jaramillo",
            parqueadero: true,
            vestidores: true,
            bar: true,
            banos: true,
            duchas: false,
            latitude: -0.2299,
            longitude: -78.5249,
            phone: "0998041792"
        )
        // Act & Assert
        do {
            _ = try await sut.createEstablishment(request)
            XCTFail("Expected createEstablishment to throw FFError.errorFromApi with 400 status code")
        } catch let error as FFError {
            XCTAssertEqual(error, .errorFromApi(statusCode: 400))
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
    }
    
    func testUploadEstablishmentImages_Succeeds_WhenStatusCodeIs200() async throws {
        // Arrage
        URLProtocolStub.stubStatusCode = 200
        URLProtocolStub.stubResponseData = "Upload success".data(using: .utf8)
        
        let dummyImage = UIImage(systemName: "photo")?.jpegData(compressionQuality: 1.0)
        guard let imagesData = dummyImage else {
            return
        }
        let images = [imagesData]
        
        
        // Act & Assert
        do {
            try await sut.uploadEstablishmentImages(establishmentID: "1", images: images)
        } catch {
            XCTFail("Expected upload to succeed, but got error: \(error)")
        }
        
    }
    
    func testUploadEstablishmentImages_ThrowsError_WhenStatusCodeIs500() async {
        // Arrange
        URLProtocolStub.stubResponseData = "Internal Server Error".data(using: .utf8)
        URLProtocolStub.stubStatusCode = 500
        
        let dummyImage = UIImage(systemName: "photo")?.jpegData(compressionQuality: 1.0)
        guard let imagesData = dummyImage else {
            return
        }
        let images = [imagesData]
        
        
        // Act & Assert
        do {
            _ = try await sut.uploadEstablishmentImages(establishmentID: "1", images: images)
            XCTFail()
        } catch let error as FFError {
            XCTAssertEqual(error, .requestWasNil)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testUpdateEstablishment_Suceeds_WhenStatusCodeIs200() async throws {
        // Arrange
        URLProtocolStub.stubStatusCode = 200
        URLProtocolStub.stubResponseData = "Upload success".data(using: .utf8)
        
        // Act & Assert
        
        do {
            
            let request = EstablishmentRequest(
                name: "Show Gol",
                info: "Cancha sintética de fútbol 7 con iluminación nocturna",
                address: "123 Main St",
                address2: "Carlota Jaramillo",
                parqueadero: true,
                vestidores: true,
                bar: true,
                banos: true,
                duchas: false,
                latitude: -0.2299,
                longitude: -78.5249,
                phone: "0998041792"
            )
            
            try await sut.updateEstablishment(establishmentID: "1", establishmentModel: request)
        } catch {
            XCTFail("Expected update to succeed, but got error: \(error)")
        }
    }
    
    func testUpdateEstablishment_ThrowsError_WhenStatusCodeIs500() async {
        //Arrange
        URLProtocolStub.stubStatusCode = 500
        
        
        let request = EstablishmentRequest(
            name: "Show Gol",
            info: "Cancha sintética de fútbol 7 con iluminación nocturna",
            address: "123 Main St", address2: "Carlota Jaramillo",
            parqueadero: true,
            vestidores: true,
            bar: true,
            banos: true,
            duchas: false,
            latitude: -0.2299,
            longitude: -78.5249,
            phone: "0998041792"
        )
        
        do {
            try await sut.updateEstablishment(establishmentID: "1", establishmentModel: request)
            XCTFail()
        } catch let error as FFError {
            XCTAssertEqual(error, .errorFromApi(statusCode: -1))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchEstablishment_ReturnsEstablishment_WhenResponseIsValid() async throws {
        // Arrange
        let jsonData = try MockData.loadJSONData(name: "EstablishmentResponse")
        URLProtocolStub.stubResponseData = jsonData
        URLProtocolStub.stubStatusCode = 200
        // Act * Assert
        let establishment = try await sut.fetchEstablishment(with: "1")
        XCTAssertNotNil(establishment)
        XCTAssertEqual(establishment.id, "1")
        XCTAssertEqual(establishment.name, "Cancha Los Libertadores")
        XCTAssertEqual(establishment.ownerID, "1")
        XCTAssertEqual(establishment.info, "Complejo deportivo con canchas de fútbol 7 y servicios adicionales.")
        XCTAssertEqual(establishment.address, "Av. Amazonas y Naciones Unidas")
        XCTAssertTrue(establishment.isFavorite)
        XCTAssertEqual(establishment.phone, "+593987654321")
        XCTAssertEqual(establishment.userName, "kevin_heredia")
        XCTAssertEqual(establishment.userRol, "dueno")
        XCTAssertTrue(establishment.parquedero)
        XCTAssertTrue(establishment.vestidores)
        XCTAssertFalse(establishment.duchas)
        XCTAssertTrue(establishment.bar)
        
    }
    
    func testFetchEstablishment_ThrowsError_WhenResponseIsInvalid() async throws {
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        URLProtocolStub.stubStatusCode = 200
        // Act & Assert
        do {
            _ = try await sut.fetchEstablishment(with: "1")
            XCTFail("Expected to throw decodingError, but it did not.")
        } catch let error as FFError {
            XCTAssertEqual(error, .decodingError, "Expected a decodingError when the response JSON does not match the expected model.")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testFetchAllEstablishment_ReturnsAllEstablishments_WhenResponseIsValid() async throws {
        // Arrange
        let jsonData = try MockData.loadJSONData(name: "GetNearbyEstablishmentRequest")
        URLProtocolStub.stubResponseData = jsonData
        URLProtocolStub.stubStatusCode = 200
        
        let coordinate = CLLocationCoordinate2D(latitude: -0.2299, longitude: -78.5249)
        
        // Act & Assert
        let establishments = try await sut.fetchAllEstablishments(coordinate: coordinate)
        XCTAssertNotNil(establishments)
        XCTAssertEqual(establishments.count, 1)
        XCTAssertEqual(establishments.first?.id, "1")
        XCTAssertEqual(establishments.first?.name, "Cancha Los Libertadores")
        XCTAssertEqual(establishments.first?.info, "Complejo deportivo con canchas de fútbol 7 y servicios adicionales.")
        XCTAssertEqual(establishments.first?.address, "Av. Amazonas y Naciones Unidas")
        XCTAssertTrue(((establishments.first?.isFavorite) != nil))
        XCTAssertEqual(establishments.first?.phone, "+593987654321")
        XCTAssertEqual(establishments.first?.userName, "kevin_heredia")
        XCTAssertEqual(establishments.first?.userRol, "dueno")
        XCTAssertTrue(((establishments.first?.parquedero) != nil))
        XCTAssertTrue(((establishments.first?.vestidores) != nil))
        XCTAssertTrue(((establishments.first?.bar) != nil))
        
    }
    
    func testFetchAllEstablishment_ThrowsError_WhenResponseIsInvalid() async throws {
        // Arrange
        URLProtocolStub.stubResponseData = Data()
        URLProtocolStub.stubStatusCode = 200
        
        // Act & Assert
        do {
            _ = try await sut.fetchAllEstablishments(coordinate: CLLocationCoordinate2D(latitude: -0.2299, longitude: -78.5249))
            XCTFail("Expected to throw decodingError, but it did not.")
        } catch let error as FFError {
            XCTAssertEqual(error, .decodingError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func test_DeleteEstablishmentById_ShouldSucceed_WhenIdIsValid() async throws {
        // Arrange
        URLProtocolStub.stubStatusCode = 200
        // Act & Assert
        do {
            try await sut.deleteEstablishmentById(with: "1")
        } catch {
            XCTFail("Expected delete to succeed, but got error: \(error)")
        }
    }
}


