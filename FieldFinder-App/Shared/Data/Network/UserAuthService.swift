import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> String
    func registerUser(name: String, email: String, password: String, role: String) async throws -> String
}

final class UserAuthService: AuthServiceProtocol {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func login(email: String, password: String) async throws -> String {
        
        var tokenJWT = ""
        
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.login.rawValue)"
        
        let encodeCredentials = "\(email):\(password)".data(using: .utf8)?.base64EncodedString()
        var segCredentials = ""
        
        if let credentials = encodeCredentials {
            segCredentials = "Basic \(credentials)"
        }
        
        // Request
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = HttpMethods.post
        
        // Headers
        request.addValue(HttpHeader.content, forHTTPHeaderField: HttpHeader.contentTypeID)
        request.addValue(segCredentials, forHTTPHeaderField: "Authorization")
        
        // Call to server
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let res = response as? HTTPURLResponse, res.statusCode == HttpResponseCodes.SUCCESS else {
                throw FFError.errorFromApi(statusCode: -1)
            }
            let result = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            tokenJWT = result.accessToken
            
        } catch {
            throw FFError.errorParsingData
        }
        
        return tokenJWT
    }
    
    
    func registerUser(name: String, email: String, password: String, role: String) async throws -> String {
        var tokenJWT = ""
        
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.registerUsers.rawValue)"
        
        // Construct the URL for the consumer registration endpoint
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        // Create the request body with the user details
        let requestBody = RegisterUserRequest(name: name, email: email, password: password, rol: role)
        let jsonData = try JSONEncoder().encode(requestBody)
        
        // Create the URL Request
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = HttpMethods.post
        request.setValue(HttpHeader.content, forHTTPHeaderField: HttpHeader.contentTypeID)
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let res = response as? HTTPURLResponse, res.statusCode == HttpResponseCodes.SUCCESS else {
                throw FFError.errorFromApi(statusCode: -1)
            }
            
            let result = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            tokenJWT = result.accessToken
            
            
        } catch {
            throw FFError.errorParsingData
        }
        
        
        return tokenJWT
    }
    
}
