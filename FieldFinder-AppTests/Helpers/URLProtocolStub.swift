import Foundation


final class URLProtocolStub: URLProtocol {
    
    static var stubResponseData: Data?
    static var stubStatusCode: Int = 200
    static var error: Error?

    override class func canInit(with request: URLRequest) -> Bool {
        return true // Interceptamos todas las peticiones
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = URLProtocolStub.error {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else {
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: URLProtocolStub.stubStatusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = URLProtocolStub.stubResponseData {
                self.client?.urlProtocol(self, didLoad: data)
            }
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
