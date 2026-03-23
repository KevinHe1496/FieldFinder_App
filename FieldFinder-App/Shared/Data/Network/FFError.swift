import Foundation

enum FFError: Error, CustomStringConvertible {
    case requestWasNil
    case errorFromServer(reason: Error)
    case errorFromApi(statusCode: Int)
    case dataNoReveiced
    case errorParsingData
    case sessionTokenMissing
    case badUrl
    case authenticationFailed
    case locationDisabled
    case noLocationFound
    case decodingError
    case locationPermissionDenied
    case invalidResponse
    
    var description: String {
        switch self {
            
        case .requestWasNil:
            return "Error creating request"
        case .errorFromServer(reason: let reason):
            return "Received error from server \((reason as NSError).code)"
        case .errorFromApi(statusCode: let statusCode):
            return "Received error from api status code \(statusCode)"
        case .dataNoReveiced:
            return "Data no received from server"
        case .errorParsingData:
            return "There was un error parsing data"
        case .sessionTokenMissing:
            return "Seesion token is missing"
        case .badUrl:
            return "Bad url"
        case .authenticationFailed:
            return "Authentication Failed"
        case .locationDisabled:
            return "Location disabled"
        case .noLocationFound:
            return "No location found"
        case .decodingError:
            return "Decoding error"
        case .locationPermissionDenied:
            return "Location permission denied"
        case .invalidResponse:
            return "Invalid Response"
        }
    }
}

extension FFError: Equatable {
    static func == (lhs: FFError, rhs: FFError) -> Bool {
        switch (lhs, rhs) {
        case (.requestWasNil, .requestWasNil),
             (.dataNoReveiced, .dataNoReveiced),
             (.errorParsingData, .errorParsingData),
             (.sessionTokenMissing, .sessionTokenMissing),
             (.badUrl, .badUrl),
             (.authenticationFailed, .authenticationFailed),
             (.locationDisabled, .locationDisabled),
             (.noLocationFound, .noLocationFound),
             (.decodingError, .decodingError),
             (.locationPermissionDenied, .locationPermissionDenied):
            return true

        case let (.errorFromApi(code1), .errorFromApi(code2)):
            return code1 == code2

        case (.errorFromServer, .errorFromServer):
            return true // ⚠️ No se compara el error interno

        default:
            return false
        }
    }
}
