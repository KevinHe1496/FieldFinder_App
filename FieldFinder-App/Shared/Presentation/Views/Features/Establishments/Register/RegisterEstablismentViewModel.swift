import Foundation
import UIKit
import CoreLocation

@Observable
final class RegisterEstablismentViewModel {
    
    private var appState: AppState
    var isLoading = false
    var latitude: Double?
    var longitude: Double?
    var alertMessage: String?
    var coordinatesFromMap = CLLocationCoordinate2D()
    var userLatitude = Double()
    var userLongitude = Double()

    @ObservationIgnored
    var useCase: EstablishmentServiceUseCaseProtocol
    
    init(useCase: EstablishmentServiceUseCaseProtocol = EstablishmentServiceUseCase(), appState: AppState = AppState()) {
        self.useCase = useCase
        self.appState = appState
    }
    
    @MainActor
    func registerEstablishment(
        name: String,
        info: String,
        address: String,
        address2: String?,
        parqueadero: Bool,
        vestidores: Bool,
        bar: Bool,
        banos: Bool,
        duchas: Bool,
        phone: String,
        images: [Data],
        userCoordinates: CLLocationCoordinate2D
    ) async throws {
        
        isLoading = true

        guard !address.isEmpty, !info.isEmpty, !name.isEmpty, !phone.isEmpty else {
            self.alertMessage = String(localized: "Todos los campos son obligatorios. Revisa los datos ingresados.")
            isLoading = false
            return
        }
        
        guard !images.isEmpty else {
            alertMessage = String(localized: "Es obligatorio subir imágenes.")
            isLoading = false
            return
        }
        
        do {
        
            let newModel = EstablishmentRequest(
                name: name,
                info: info,
                address: address,
                address2: address2,
                parqueadero: parqueadero,
                vestidores: vestidores,
                bar: bar,
                banos: banos,
                duchas: duchas,
                latitude: userCoordinates.latitude,
                longitude: userCoordinates.longitude,
                phone: phone
            )
            
            let establismentID = try await useCase.createEstablishment(newModel)
            try await useCase.uploadEstablishmentImages(establishmentID: establismentID, images: images)
            userLatitude = userCoordinates.latitude
            userLongitude = userCoordinates.longitude
            
            alertMessage = String(localized: "Establecimiento registrado con éxito.")
            appState.status = .home
        } catch {
            alertMessage = String(localized: "Error al registrar: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    @MainActor
    func editEstablishment(
        establishmentID: String,
        name: String,
        info: String,
        address: String,
        address2: String?,
        parqueadero: Bool,
        vestidores: Bool,
        bar: Bool,
        banos: Bool,
        duchas: Bool,
        phone: String
    )  async throws {
        
        do {
            
            let newModel = EstablishmentRequest(
                name: name,
                info: info,
                address: address,
                address2: address2,
                parqueadero: parqueadero,
                vestidores: vestidores,
                bar: bar,
                banos: banos,
                duchas: duchas,
                latitude: userLatitude,
                longitude: userLongitude,
                phone: phone
            )
            
          
            
            try await useCase.updateEstablishment(establishmentID: establishmentID, establishmentModel: newModel)
            
            
            alertMessage = String(localized: "Establecimiento registrado con éxito.")
        } catch {
            print("Error al registrar: \(error.localizedDescription)")
            isLoading = false
        }
        
        
    }
    
}
