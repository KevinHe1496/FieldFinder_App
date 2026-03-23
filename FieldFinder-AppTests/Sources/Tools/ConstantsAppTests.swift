//
//  ConstantsAppTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 3/6/25.
//

import XCTest

@testable import FieldFinder_App
final class ConstantsAppTests: XCTestCase {
    
    func test_ConsApiUrl_ShouldBeCorrect() {
        XCTAssertEqual(ConstantsApp.CONS_API_URL, "https://fieldfinder-db.fly.dev/api")
    }
    
    func test_ConsTokenIdKeychain_ShouldBeCorrect() {
        XCTAssertEqual(ConstantsApp.CONS_TOKEN_ID_KEYCHAIN, "com.kevinhe.FieldFinder-App")
    }
}
