import Foundation

protocol NetworkRegisterEstablishmentProtocol {
    func registerEstablishment(_ establishmentModel: EstablishmentRequest) async throws -> String
    func uploadImages(establishmentID: String, images: [Data]) async throws
    func editEstablishment(establishmentID: String, establishmentModel: EstablishmentRequest) async throws
}

final class EstablishmentService: NetworkRegisterEstablishmentProtocol {
    
    func registerEstablishment(_ establishmentModel: EstablishmentRequest) async throws -> String  {
        
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.registerEstablishment.rawValue)"
        
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = HttpMethods.post
        request.setValue(HttpHeader.content, forHTTPHeaderField: HttpHeader.contentTypeID)
        
        let jwtToken = KeyChainFF().loadPK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try JSONEncoder().encode(establishmentModel)
        
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
            let establishmentID = try JSONDecoder().decode(IDResponse.self, from: data)
            print("✅ Establecimiento registrado con éxito.")
            
            return establishmentID.id
        } catch {
            print("Error al registrar: \(error.localizedDescription)")
            throw FFError.requestWasNil
        }
        
    }
    
    
    // Upload Images Network
    
    func uploadImages(establishmentID: String, images: [Data]) async throws {
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.uploadImagesEstablishment.rawValue)/\(establishmentID)"
        
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        let boundary = UUID().uuidString
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = HttpMethods.post
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: HttpHeader.contentTypeID)
        
        let jwtToken = KeyChainFF().loadPK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
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
    
    // Edit establishment
    
    func editEstablishment(establishmentID: String, establishmentModel: EstablishmentRequest) async throws {
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.getEstablishmentById.rawValue)/\(establishmentID)"
        
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = HttpMethods.put
        request.setValue(HttpHeader.content, forHTTPHeaderField: HttpHeader.contentTypeID)
        
        let tokenJWT = KeyChainFF().loadPK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
        request.setValue("\(HttpHeader.bearer) \(tokenJWT)", forHTTPHeaderField: HttpHeader.authorization)
        
        request.httpBody = try JSONEncoder().encode(establishmentModel)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw FFError.errorFromApi(statusCode: -1)
        }
        print("Se edito correctamente")
    }
    
}



