import Foundation
import CoreLocation

protocol EstablishmentServiceProtocol {
    func createEstablishment(_ establishmentModel: EstablishmentRequest) async throws -> String
    func uploadEstablishmentImages(establishmentID: String, images: [Data]) async throws
    func updateEstablishment(establishmentID: String, establishmentModel: EstablishmentRequest) async throws
    func fetchEstablishment(with establishmentId: String) async throws -> EstablishmentResponse
    func fetchAllEstablishments(coordinate: CLLocationCoordinate2D) async throws -> [EstablishmentResponse]
    func deleteEstablishmentById(with establishmentId: String) async throws
}

final class EstablishmentService: EstablishmentServiceProtocol {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func createEstablishment(_ establishmentModel: EstablishmentRequest) async throws -> String  {
        
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
        
        let (data, response) = try await session.data(for: request)
        
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
            throw FFError.errorParsingData
        }
        
    }
    
    
    // Upload Images Network
    
    func uploadEstablishmentImages(establishmentID: String, images: [Data]) async throws {
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
            let (data, response) = try await session.data(for: request)
            
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
    
    func updateEstablishment(establishmentID: String, establishmentModel: EstablishmentRequest) async throws {
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
        
        let (_, response) = try await session.data(for: request)
        
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw FFError.errorFromApi(statusCode: -1)
        }
        print("Se edito correctamente")
    }
    
    // Get
    func fetchEstablishment(with establishmentId: String) async throws -> EstablishmentResponse {
        
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.getEstablishmentById.rawValue)/\(establishmentId)"
        
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.get
        
        let (data, response) = try await session.data(for: request)
        
        // Verifica que la respuesta sea válida y del tipo HTTPURLResponse.
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FFError.errorFromApi(statusCode: -1)
        }
        
        // Valida que el código de respuesta HTTP sea exitoso.
        guard httpResponse.statusCode == HttpResponseCodes.SUCCESS else {
            throw FFError.errorFromApi(statusCode: httpResponse.statusCode)
        }
        
        do {
            let result = try JSONDecoder().decode(EstablishmentResponse.self, from: data)
            return result
        } catch {
            print("Decoding error: \(error.localizedDescription)")
            throw FFError.decodingError
        }
    }
    
    func fetchAllEstablishments(coordinate: CLLocationCoordinate2D) async throws -> [EstablishmentResponse] {
        var modelReturn = [EstablishmentResponse]()
        
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.getNearbyEstablishments.rawValue)"
        
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        let requestBody = GetNearbyEstablishmentsRequest(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let jsonData = try JSONEncoder().encode(requestBody)
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = HttpMethods.post
        request.setValue(HttpHeader.content, forHTTPHeaderField: HttpHeader.contentTypeID)
        request.httpBody = jsonData
        
        let (data, response) = try await session.data(for: request)
        
        guard let res = response as? HTTPURLResponse, res.statusCode == HttpResponseCodes.SUCCESS else {
            throw FFError.errorFromApi(statusCode: -1)
        }
        
        do {
            let result = try JSONDecoder().decode([EstablishmentResponse].self, from: data)
            modelReturn = result
        } catch {
            print("Decoding error: \(error.localizedDescription)")
            throw FFError.decodingError
        }
        return modelReturn
    }
    
    func deleteEstablishmentById(with establishmentId: String) async throws {
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.getEstablishmentById.rawValue)/\(establishmentId)"
        
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = HttpMethods.delete
        
        let tokenJWT = KeyChainFF().loadPK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
        request.setValue("\(HttpHeader.bearer) \(tokenJWT)", forHTTPHeaderField: HttpHeader.authorization)
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                throw FFError.errorFromApi(statusCode: -1)
            }
        }
    }
    
}
