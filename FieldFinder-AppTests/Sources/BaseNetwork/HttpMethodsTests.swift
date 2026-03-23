//
//  HttpMethodsTests.swift
//  FieldFinder-AppTests
//
//  Created by Andy Heredia on 3/6/25.
//

import XCTest

@testable import FieldFinder_App
final class HttpMethodsTests: XCTestCase {
    
    func test_HttpMethod_Post_ShouldBeCorrect() {
        XCTAssertEqual(HttpMethods.post, "POST")
    }
    
    func test_HttpMethod_Get_ShouldBeCorrect() {
        XCTAssertEqual(HttpMethods.get, "GET")
    }
    
    func test_HttpMethod_Put_ShouldBeCorrect() {
        XCTAssertEqual(HttpMethods.put, "PUT")
    }
    
    func test_HttpMethod_Delete_ShouldBeCorrect() {
        XCTAssertEqual(HttpMethods.delete, "DELETE")
    }
    
    // MARK: Headers
    
    func test_HttpHeader_Content_ShouldBeCorrect() {
        XCTAssertEqual(HttpHeader.content, "application/json")
    }
    
    func test_HttpHeader_ContentTypeID_ShouldBeCorrect() {
        XCTAssertEqual(HttpHeader.contentTypeID, "Content-Type")
    }
    
    func test_HttpHeader_MultipartFormData_ShouldBeCorrect() {
        XCTAssertEqual(HttpHeader.multipartFormData, "multipart/form-data; boundary=")
    }
    
    func test_HttpHeader_Bearer_ShouldBeCorrect() {
        XCTAssertEqual(HttpHeader.bearer, "Bearer")
    }
    
    func test_HttpHeader_Authorization_ShouldBeCorrect() {
        XCTAssertEqual(HttpHeader.authorization, "Authorization")
    }
    
}
