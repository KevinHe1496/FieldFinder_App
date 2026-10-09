import Foundation

public struct ConstantsApp {
    // Backend URL
    //
    // Por defecto la app (Debug y Release) usa el servidor de producción.
    // Para probar contra el backend local, en Xcode: Product > Scheme > Edit Scheme > Run >
    // Arguments > Environment Variables, agrega FF_API_URL = http://localhost:8080/api
    // La variable solo se lee en builds Debug, así que nunca llega a la versión del App Store.
    public static let productionAPIURL = "https://fieldfinder-db.fly.dev/api"

    public static let CONS_API_URL: String = {
        #if DEBUG
        if let override = ProcessInfo.processInfo.environment["FF_API_URL"], !override.isEmpty {
            return override
        }
        #endif
        return productionAPIURL
    }()

    // ID Keychain Token JWT
    public static let CONS_TOKEN_ID_KEYCHAIN = "com.kevinhe.FieldFinder-App"

    // ID Keychain Refresh Token JWT
    public static let CONS_REFRESH_TOKEN_ID_KEYCHAIN = "com.kevinhe.FieldFinder-App.refresh"
}
