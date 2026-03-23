//
//  EndpointsTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 3/6/25.
//

import XCTest

@testable import FieldFinder_App
final class EndpointsTests: XCTestCase {
    
    func test_LoginEndpoint_ShouldBeCorrect() {
        XCTAssertEqual(Endpoints.login.rawValue, "/auth/login")
    }
    
    func test_RegisterUsersEndpoint_ShouldBeCorrect() {
        XCTAssertEqual(Endpoints.registerUsers.rawValue, "/auth/register")
    }
    
    func test_RegisterEstablishmentEndpoint_ShouldBeCorrect() {
        XCTAssertEqual(Endpoints.registerEstablishment.rawValue, "/establecimiento/register")
    }
    
    func test_UploadImagesEstablishmentEndpoint_ShouldBeCorrect() {
        XCTAssertEqual(Endpoints.uploadImagesEstablishment.rawValue, "/establecimiento/fotos")
    }
    
    func test_RegisterCanchaEndpoint_ShouldBeCorrect() {
        XCTAssertEqual(Endpoints.registerCancha.rawValue, "/cancha/register")
    }
    
    func test_UploadImagesCanchaEndpoint_ShouldBeCorrect() {
        XCTAssertEqual(Endpoints.uploadImagesCancha.rawValue, "/cancha/fotos")
    }
    
    func test_GetNearbyEstablishmentsEndpoint_ShouldBeCorrect() {
        XCTAssertEqual(Endpoints.getNearbyEstablishments.rawValue, "/establecimiento/nearby")
    }
    
    func test_GetEstablishmentByIdEndpoint_ShouldBeCorrect() {
        XCTAssertEqual(Endpoints.getEstablishmentById.rawValue, "/establecimiento")
    }
    
    func test_GetFieldByIdEndpoint_ShouldBeCorrect() {
        XCTAssertEqual(Endpoints.getFieldById.rawValue, "/cancha")
    }
    
    func test_GetMeEndpoint_ShouldBeCorrect() {
        XCTAssertEqual(Endpoints.getMe.rawValue, "/users/me")
    }
    
    func test_GetEstablishmentsEndpoint_ShouldBeCorrect() {
        XCTAssertEqual(Endpoints.getEstablishments.rawValue, "/establecimiento/getEstablecimientos")
    }
    
    func test_FavoriteUserEndpoint_ShouldBeCorrect() {
        XCTAssertEqual(Endpoints.favoriteUser.rawValue, "/users/favoritos")
    }
    
}
