//
//  EstablishmentDetailViewModel.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 12/5/25.
//

import Foundation
import UIKit

@Observable
final class EstablishmentDetailViewModel {
    var status: ViewState<EstablishmentResponse> = .idle
    var showOpenInMapsAlert = false
    var mapsURL: URL?
    
    var showCallAlert = false
    var callURL: URL?
    
    let callManager = ExternalLinkManager()
    let mapsManager = ExternalLinkManager()
    
    @ObservationIgnored
    private var useCase: EstablishmentServiceUseCaseProtocol
    
    @ObservationIgnored
    private var favoriteUseCase: UserFavoritesServiceUseCaseProtocol
    
    init(useCase: EstablishmentServiceUseCaseProtocol = EstablishmentServiceUseCase(), favoriteUseCase: UserFavoritesServiceUseCaseProtocol = UserFavoritesServiceUseCase()) {
        self.useCase = useCase
        self.favoriteUseCase = favoriteUseCase
    }
    
    @MainActor
    func getEstablishmentDetail(establishmentId: String) async throws {
        status = .loading
        do {
            let establecimiento = try await useCase.fetchEstablishment(with: establishmentId)
            status = .success(establecimiento)
        } catch {
            status = .error("No se pudo cargar el establecimiento")
        }
    }
    
    @MainActor
    func addToFavorites(establishmentId: String) async throws {
        try await favoriteUseCase.addFavorite(establishmentId: establishmentId)
    }
    
    @MainActor
    func removeFromFavorites(establishmentId: String) async throws {
        try await favoriteUseCase.removeFavorite(establishmentId: establishmentId)
    }
    
    @MainActor
    func prepareMapsURL(for establishment: EstablishmentResponse) {
        let coordinate = establishment.coordinate

        guard coordinate.latitude != 0.0, coordinate.longitude != 0.0 else {
            return // Coordenadas vacías, no hacemos nada
        }

        let placeName = establishment.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Ubicación"

        if let url = URL(string: "maps://?q=\(placeName)&ll=\(coordinate.latitude),\(coordinate.longitude)") {
            mapsURL = url
            showOpenInMapsAlert = true
        }
    }

    
    @MainActor
    func openMapsURL() {
        if let url = mapsURL {
            UIApplication.shared.open(url)
        }
    }
    
    @MainActor
    func prepareCall(phone: String) {
        let formatted = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        let url = URL(string: "tel://\(formatted)")
        callManager.prepareToOpen(
            title: "¿Llamar al propietario?",
            message: "Esto iniciará una llamada al número del establecimiento.",
            url: url
        )
    }


    @MainActor
    func prepareMaps(for establishment: EstablishmentResponse) {
        let coordinate = establishment.coordinate
        let name = establishment.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Ubicación"
        let url = URL(string: "maps://?q=\(name)&ll=\(coordinate.latitude),\(coordinate.longitude)")
        
        mapsManager.prepareToOpen(
            title: "¿Abrir en Apple Maps?",
            message: "Esto te llevará a la app Maps para ver la ubicación.",
            url: url
        )
    }
    
    @MainActor
    func deleteEstablishmentById(establishmentId: String) async throws {
        let _ = try await useCase.deleteEstablishmentById(with: establishmentId)
    }
}
