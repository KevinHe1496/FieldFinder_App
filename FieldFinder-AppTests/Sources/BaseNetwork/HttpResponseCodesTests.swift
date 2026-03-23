//
//  HttpResponseCodesTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 3/6/25.
//

import XCTest

@testable import FieldFinder_App
final class HttpResponseCodesTests: XCTestCase {
    
    func test_HttpResponseCodes_Success_ShouldBe200() {
        XCTAssertEqual(HttpResponseCodes.SUCCESS, 200)
    }
    
    func test_HttpResponseCodes_NotAuthorized_ShouldBe401() {
        XCTAssertEqual(HttpResponseCodes.NOT_AUTHORIZED, 401)
    }
    
    func test_HttpResponseCodes_Error_ShouldBe502() {
        XCTAssertEqual(HttpResponseCodes.ERROR, 502)
    }
    
}
