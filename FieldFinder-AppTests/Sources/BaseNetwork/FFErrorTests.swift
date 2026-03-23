//
//  FFErrorTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 3/6/25.
//

import XCTest

@testable import FieldFinder_App
final class FFErrorTests: XCTestCase {
    
    
    func test_RequestWasNilDescription_ShouldBeCorrect() {
        let error = FFError.requestWasNil
        XCTAssertEqual(error.description, "Error creating request")
    }
    
    func test_ErrorFromServerDescription_ShouldContainErrorCode() {
        let underlyingError = NSError(domain: "", code: 404, userInfo: nil)
        let error = FFError.errorFromServer(reason: underlyingError)
        XCTAssertEqual(error.description, "Received error from server 404")
    }
    
    func test_ErrorFromApiDescription_ShouldContainStatusCode() {
        let error = FFError.errorFromApi(statusCode: 500)
        XCTAssertEqual(error.description, "Received error from api status code 500")
    }
    
    func test_DataNoReceivedDescription_ShouldBeCorrect() {
        let error = FFError.dataNoReveiced
        XCTAssertEqual(error.description, "Data no received from server")
    }
    
    func test_ErrorParsingDataDescription_ShouldBeCorrect() {
        let error = FFError.errorParsingData
        XCTAssertEqual(error.description, "There was un error parsing data")
    }
    
    func test_SessionTokenMissingDescription_ShouldBeCorrect() {
        let error = FFError.sessionTokenMissing
        XCTAssertEqual(error.description, "Seesion token is missing")
    }
    
    func test_BadUrlDescription_ShouldBeCorrect() {
        let error = FFError.badUrl
        XCTAssertEqual(error.description, "Bad url")
    }
    
    func test_AuthenticationFailedDescription_ShouldBeCorrect() {
        let error = FFError.authenticationFailed
        XCTAssertEqual(error.description, "Authentication Failed")
    }
    
    func test_LocationDisabledDescription_ShouldBeCorrect() {
        let error = FFError.locationDisabled
        XCTAssertEqual(error.description, "Location disabled")
    }
    
    func test_NoLocationFoundDescription_ShouldBeCorrect() {
        let error = FFError.noLocationFound
        XCTAssertEqual(error.description, "No location found")
    }
    
    func test_DecodingErrorDescription_ShouldBeCorrect() {
        let error = FFError.decodingError
        XCTAssertEqual(error.description, "Decoding error")
    }
    
    func test_LocationPermissionDeniedDescription_ShouldBeCorrect() {
        let error = FFError.locationPermissionDenied
        XCTAssertEqual(error.description, "Location permission denied")
    }
    
}
