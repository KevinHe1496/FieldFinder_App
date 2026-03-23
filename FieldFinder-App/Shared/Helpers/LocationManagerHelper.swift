//
//  LocationManagerHelper.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 12/5/25.
//

import Foundation
import CoreLocation

/// Clase que maneja la ubicación del usuario usando CoreLocation con soporte para async/await.
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    /// Objeto que gestiona las actualizaciones de ubicación.
    private let locationManager = CLLocationManager()
    
    /// Continuación para devolver la coordenada cuando esté disponible (usada en async/await).
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    
    /// Continuación para esperar a que el usuario responda el permiso de ubicación.
    private var authorizationContinuation: CheckedContinuation<Void, Error>?
    
    /// Ubicación actual del usuario, publicada para poder usarla en interfaces SwiftUI.
    @Published var userLocation: CLLocationCoordinate2D?

    /// Inicializador que configura el delegado.
    override init() {
        super.init()
        locationManager.delegate = self
    }

    /// Solicita permiso de ubicación y devuelve la ubicación del usuario.
    /// - Returns: Coordenadas actuales del usuario.
    /// - Throws: FFError si el permiso fue denegado o si la ubicación falla.
    func requestLocation() async throws -> CLLocationCoordinate2D {
        // Verifica si los servicios de ubicación están activados en el dispositivo.
        guard CLLocationManager.locationServicesEnabled() else {
            throw FFError.locationDisabled
        }

        // Verifica el estado actual de autorización.
        let status = locationManager.authorizationStatus
        
        // Si el usuario no ha respondido aún, pedimos el permiso y esperamos la respuesta.
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            try await withCheckedThrowingContinuation { continuation in
                self.authorizationContinuation = continuation
            }
        }
        // Si ya denegó o está restringido, no continuamos.
        else if status == .denied || status == .restricted {
            throw FFError.locationPermissionDenied
        }

        // Cuando tenemos permiso, solicitamos la ubicación actual.
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    /// Método del delegado que se llama cuando cambia el permiso de ubicación.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Si el usuario aceptó el permiso, se continúa la ejecución.
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            authorizationContinuation?.resume()
        }
        // Si el usuario lo negó, lanzamos un error.
        else if status == .denied || status == .restricted {
            authorizationContinuation?.resume(throwing: FFError.locationPermissionDenied)
        }
        // Limpiamos la continuación.
        authorizationContinuation = nil
    }

    /// Método del delegado que se llama cuando se obtiene una nueva ubicación.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Tomamos la primera ubicación válida.
        if let coordinate = locations.first?.coordinate {
            userLocation = coordinate
            locationContinuation?.resume(returning: coordinate)
        } else {
            locationContinuation?.resume(throwing: FFError.noLocationFound)
        }
        locationContinuation = nil
    }

    /// Método del delegado que se llama cuando falla la obtención de la ubicación.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}
