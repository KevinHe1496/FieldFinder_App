//
//  PlayerViewModel.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 12/5/25.
//

import Foundation
import CoreLocation
import _MapKit_SwiftUI


final class GetNearbyEstablishmentsViewModel: ObservableObject {
    
    var locationService = LocationService()
    @Published var nearbyEstablishments = [Establecimiento]()
    @Published var favoritesData = [FavoriteEstablishment]()
    @Published var selectedRestaurant: Establecimiento? // Restaurante seleccionado por el usuario.
    @Published var cameraPosition: MapCameraPosition = .automatic // Posición de la cámara en el mapa.
    
    @ObservationIgnored
    private var useCase: GetNearbyEstablishmentsUseCaseProtocol
    
    @ObservationIgnored
    private let favoriteUseCase: FavoriteUserUseCaseProtocol
    
    init(useCase: GetNearbyEstablishmentsUseCaseProtocol = GetNearbyEstablishmentsUseCase(), favoriteUseCase: FavoriteUserUseCaseProtocol = FavoriteUserUseCase()) {
        self.useCase = useCase
        self.favoriteUseCase = favoriteUseCase
    }
    
    @MainActor
    private func fetchEstablishments(near coordinate: CLLocationCoordinate2D) async throws {
        let result = try await useCase.getAllEstablishments(coordinate: coordinate)
        nearbyEstablishments = result
    }
    
    @MainActor
    func loadData() async throws {
        let coordinates = try await locationService.requestLocation()
        try await fetchEstablishments(near: coordinates)
    }
    
    @MainActor
    func toggleFavorite(establishmentId: String, isFavorite: Bool) async throws {
        if isFavorite {
            try await favoriteUseCase.favoriteUser(establishmentId: establishmentId)
        } else {
            try await favoriteUseCase.deleteFavoriteUser(establishmentId: establishmentId)
        }
        try await getFavoritesUser()
    }
    
    @MainActor
    func getFavoritesUser() async throws {
        let data = try await favoriteUseCase.getFavoriteUser()
        self.favoritesData = data
    }
    
    /// Actualiza la posición de la cámara en el mapa.
    @MainActor
    private func updateCamera(to coordinate: CLLocationCoordinate2D) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
    
    /// Guarda el restaurante seleccionado para mostrar más detalles.
    @MainActor
    func selectRestaurant(_ establishment: Establecimiento) {
        selectedRestaurant = establishment
    }
    
    @MainActor
    func centerOnUserLocation() async {
        do {
            let coordinate = try await locationService.requestLocation()
            updateCamera(to: coordinate)
        } catch {
            print("Error centering on user location: \(error)")
        }
    }
}
