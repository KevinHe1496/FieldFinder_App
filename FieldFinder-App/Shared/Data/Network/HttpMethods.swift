import Foundation

struct HttpMethods {
    static let post = "POST"
    static let get = "GET"
    static let put = "PUT"
    static let delete = "DELETE"
}

struct HttpHeader {
    static let content = "application/json"
    static let contentTypeID = "Content-Type"
    static let multipartFormData = "multipart/form-data; boundary="
    static let bearer = "Bearer"
    static let authorization = "Authorization"
}
