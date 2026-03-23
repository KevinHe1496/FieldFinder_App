import Foundation

/// Extensión para permitir añadir un string como `Data` codificado en UTF-8.
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

/// Crea el cuerpo de una petición HTTP en formato multipart/form-data.
func createMultipartBody(from fields: [String: String], imageData: Data?, imageFieldName: String, boundary: String) -> Data {
    var body = Data()

    for (key, value) in fields {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }

    if let data = imageData {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(imageFieldName)\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(data)
        body.append("\r\n")
    }

    body.append("--\(boundary)--\r\n")
    return body
}
