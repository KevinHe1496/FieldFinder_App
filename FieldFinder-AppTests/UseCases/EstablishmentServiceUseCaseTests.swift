//
//  EstablishmentServiceUseCaseTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 29/5/25.
//

import XCTest
import CoreLocation

@testable import FieldFinder_App
final class EstablishmentServiceUseCaseTests: XCTestCase {
    
    var mockEstablishmentService: MockEstablishmentService!
    var repository: EstablishmentServiceRepository!
    var useCase: EstablishmentServiceUseCase!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockEstablishmentService = MockEstablishmentService()
        repository = EstablishmentServiceRepository(network: mockEstablishmentService)
        useCase = EstablishmentServiceUseCase(repo: repository)
    }

    override func tearDownWithError() throws {
        mockEstablishmentService = nil
        repository = nil
        useCase = nil
        try super.tearDownWithError()
    }

    func testGivenValidRequest_WhenCreateEstablishment_ThenReturnsEstablishmentId() async throws {
        // Arrange
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
        
        //Act
        let id = try await useCase.createEstablishment(request)
        // Assert
        XCTAssertEqual(id, "mock_establishment_id")
    }
    
    func testuploadEstablishmentImages_callsServiceWithCorrectData() async throws {
        // Arrange
        let fakeImages = [Data("image1".utf8), Data("image2".utf8)]
        
        // Act
        try await useCase.uploadEstablishmentImages(establishmentID: "MockID", images: fakeImages)
        
        // Assert
        XCTAssertTrue(mockEstablishmentService.didCallUploadImages)
        XCTAssertEqual(mockEstablishmentService.lastUploadedImages.count, 2)
    }
    
    func testupdateEstablishment_callsServiceWithCorrectModel() async throws {
        // Arrange
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
        try await useCase.updateEstablishment(establishmentID: "mockID", establishmentModel: request)
        
        // Arrange
        XCTAssertTrue(mockEstablishmentService.didCallUpdateEstablishment)
        XCTAssertEqual(mockEstablishmentService.lastUpdatedEstablishment?.name, "Bocha")
    }

    func testFetchEstablishment_ShouldReturnEstablishment_WhenIDIsValid() async throws {
        let establishmentResponse = try await useCase.fetchEstablishment(with: "mock123")
        XCTAssertNotNil(establishmentResponse)
        XCTAssertEqual(establishmentResponse.id, "mock123")
        XCTAssertEqual(establishmentResponse.name, "Mock Cancha")
        XCTAssertEqual(establishmentResponse.info, "Cancha de prueba para tests unitarios.")
    }
    
    func testFetchAllEstablishments_ShouldReturnAllEstablishment_WhenCoordinatesAreValid() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 0.123456, longitude: -0.123456)
        let establishmentResponse = try await repository.fetchAllEstablishments(coordinate: coordinate)
        XCTAssertNotNil(establishmentResponse)
        XCTAssertEqual(establishmentResponse.first?.id, "mock123")
        XCTAssertEqual(establishmentResponse.first?.name, "Mock Cancha")
        XCTAssertEqual(establishmentResponse.first?.info, "Cancha de prueba para tests unitarios.")
    }
    
    func test_DeleteEstablishmentById_ShouldSucceed_WhenIdIsValid() async throws {
        try await useCase.deleteEstablishmentById(with: "1")
        XCTAssertTrue(mockEstablishmentService.didCallDeleteEstablishment)
    }



}
