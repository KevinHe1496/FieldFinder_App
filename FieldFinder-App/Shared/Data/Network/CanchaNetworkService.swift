import Foundation

protocol CanchaNetworkServiceProtocol {
    func createField(_ fieldModel: CanchaRequest) async throws -> String
    func uploadFieldImages(fieldID: String, images: [Data]) async throws
    func updateField(fieldID: String, fieldModel: CanchaRequest) async throws -> CanchaRequest
    func deleteField(fieldID: String) async throws
}


final class FieldService: CanchaNetworkServiceProtocol {
    
    
    func createField(_ fieldModel: CanchaRequest) async throws -> String {
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.registerCancha.rawValue)"
        
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = HttpMethods.post
        request.setValue(HttpHeader.content, forHTTPHeaderField: HttpHeader.contentTypeID)
        
        let tokenJWT = KeyChainFF().loadPK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
        request.setValue("\(HttpHeader.bearer) \(tokenJWT)", forHTTPHeaderField: HttpHeader.authorization)
        
        request.httpBody = try JSONEncoder().encode(fieldModel)
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 6. Verificar que la respuesta es válida y fue exitosa
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FFError.errorFromApi(statusCode: -1)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Aquí puedes decodificar un posible mensaje de error si el backend lo envía
            if let errorMessage = String(data: data, encoding: .utf8) {
                print("Error del servidor: \(errorMessage)")
            }
            throw FFError.errorFromApi(statusCode: httpResponse.statusCode)
        }
        do {
            print("✅ Cancha registrada con éxito.")
            let decoded = try JSONDecoder().decode(IDResponse.self, from: data)
            return decoded.id
            
            
        } catch {
            print("Error al registrar la cancha: \(error.localizedDescription)")
            throw FFError.errorParsingData
        }
        
    }
    
    
    func uploadFieldImages(fieldID: String, images: [Data]) async throws {
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.uploadImagesCancha.rawValue)/\(fieldID)"
        
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        let boundary = UUID().uuidString
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = HttpMethods.post
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: HttpHeader.contentTypeID)
        
        let jwtToken = KeyChainFF().loadPK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
        request.setValue("\(HttpHeader.bearer) \(jwtToken)", forHTTPHeaderField: HttpHeader.authorization)
        
        var body = Data()
        
        for (index, imageData) in images.enumerated() {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files[]\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let serverMessage = String(data: data, encoding: .utf8) ?? "Sin mensaje del servidor"
                print("Error al subir imágenes: \(serverMessage)")
                throw FFError.errorFromApi(statusCode: 500)
            }
            
            let responseMessage = String(data: data, encoding: .utf8) ?? "Subida completada"
            print("✅ Imágenes subidas correctamente: \(responseMessage)")
        } catch {
            print("❌ Error al subir las imágenes: \(error.localizedDescription)")
            throw FFError.requestWasNil
        }
    }
    
    func updateField(fieldID: String, fieldModel: CanchaRequest) async throws -> CanchaRequest {
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.getFieldById.rawValue)/\(fieldID)"
        
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = HttpMethods.put
        request.setValue(HttpHeader.content, forHTTPHeaderField: HttpHeader.contentTypeID)
        
        let tokenJWT = KeyChainFF().loadPK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
        request.setValue("\(HttpHeader.bearer) \(tokenJWT)", forHTTPHeaderField: HttpHeader.authorization)
        
        request.httpBody = try JSONEncoder().encode(fieldModel)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw FFError.errorFromApi(statusCode: -1)
        }
        
        do {
            let result = try JSONDecoder().decode(CanchaRequest.self, from: data)
            return result
        } catch {
            throw FFError.errorParsingData
        }
        
    }
    
    func deleteField(fieldID: String) async throws {
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.getFieldById.rawValue)/\(fieldID)"
        
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = HttpMethods.delete
        
        let tokenJWT = KeyChainFF().loadPK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
        request.setValue("\(HttpHeader.bearer) \(tokenJWT)", forHTTPHeaderField: HttpHeader.authorization)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                throw FFError.errorFromApi(statusCode: -1)
            }
        } 
        
        
    }
    
    
    
}
