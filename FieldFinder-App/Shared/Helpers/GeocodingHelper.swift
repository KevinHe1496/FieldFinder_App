import Foundation
import CoreLocation

struct GeocodingHelper {
    
    /// Convierte una dirección completa (con calle, código postal, ciudad y país) en coordenadas.
    static func getCoordinates(
        street: String,
        zipCode: String,
        city: String,
        country: String
    ) async throws -> CLLocationCoordinate2D {
        
        // Une los componentes en una dirección completa tipo "Av. Amazonas 123, 170150, Quito, Ecuador"
        let fullAddress = "\(street), \(zipCode), \(city), \(country)"
        
        // Llama al método que realiza la geocodificación usando esa dirección completa
        return try await getCoordinates(for: fullAddress)
    }

    /// Convierte una dirección (en texto) en coordenadas geográficas (latitud y longitud)
    static func getCoordinates(for address: String) async throws -> CLLocationCoordinate2D {
        return try await withCheckedThrowingContinuation { continuation in
            let geocoder = CLGeocoder()
            
            // Llama a la API de Apple para obtener coordenadas a partir de una dirección
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    print("❌ Error al geocodificar dirección: \(error)")
                    continuation.resume(throwing: error)
                } else if let coordinate = placemarks?.first?.location?.coordinate {
                    print("✅ Coordenadas obtenidas: \(coordinate)")
                    continuation.resume(returning: coordinate)
                } else {
                    // Si no se encontraron coordenadas, lanza un error personalizado
                    let geocodeError = NSError(
                        domain: "GeocodingError",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "No se encontraron coordenadas para la dirección."]
                    )
                    print("❌ No se encontraron coordenadas: \(geocodeError.localizedDescription)")
                    continuation.resume(throwing: geocodeError)
                }
            }
        }
    }
}
