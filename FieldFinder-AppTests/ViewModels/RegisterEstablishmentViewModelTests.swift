//
//  RegisterEstablishmentUseCaseTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 29/5/25.
//

import XCTest
import CoreLocation

@testable import FieldFinder_App
final class RegisterEstablishmentViewModelTests: XCTestCase {
    
    var mockEstablishmentService: MockEstablishmentService!
    var repository: EstablishmentServiceRepository!
    var useCase: EstablishmentServiceUseCase!
    var viewModel: RegisterEstablismentViewModel!

    override func setUpWithError() throws {
       try super.setUpWithError()
        mockEstablishmentService = MockEstablishmentService()
        repository = EstablishmentServiceRepository(network: mockEstablishmentService)
        useCase = EstablishmentServiceUseCase(repo: repository)
        viewModel = RegisterEstablismentViewModel(useCase: useCase, appState: AppState())
    }

    override func tearDownWithError() throws {
       
        mockEstablishmentService = nil
        repository = nil
        useCase = nil
        viewModel = nil
        
        try super.tearDownWithError()
    }

    func test_RegisterEstablishment_ShouldShowError_WhenFieldsAreEmpty() async {

        try? await viewModel.registerEstablishment(
            name: "",
            info: "",
            address: "",
            address2: "",
            parqueadero: true,
            vestidores: true,
            bar: true,
            banos: true,
            duchas: true,
            phone: "",
            images: [],
            userCoordinates: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        )

        XCTAssertEqual(viewModel.alertMessage, "All fields are required. Please check the entered data.")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_RegisterEstablishment_ShouldShowError_WhenImagesAreEmpty() async {
        try? await viewModel.registerEstablishment(
            name: "Bocha",
            info: "Canchas naturales",
            address: "Av. Amazonas",
            address2: "Carlota Jaramillo",
            parqueadero: true,
            vestidores: true,
            bar: true,
            banos: true,
            duchas: true,
            phone: "0998041792",
            images: [],
            userCoordinates: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        )
        
        XCTAssertEqual(viewModel.alertMessage, "Uploading images is required.")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_RegisterEstablishment_ShouldSetSuccessMessage_WhenSuccessful() async {
        
        let fakeImages = [Data("image1".utf8), Data("image2".utf8)]
        
        try? await viewModel.registerEstablishment(
            name: "Bocha",
            info: "Canchas naturales",
            address: "Av. Amazonas",
            address2: "Carlota Jaramillo",
            parqueadero: true,
            vestidores: true,
            bar: true,
            banos: true,
            duchas: true,
            phone: "0998041792",
            images: fakeImages,
            userCoordinates: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        )
        
        XCTAssertEqual(viewModel.alertMessage, "Establishment successfully registered.")
    }
    
    



}
