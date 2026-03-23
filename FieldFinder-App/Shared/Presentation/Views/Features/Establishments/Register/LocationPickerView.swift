import SwiftUI
import MapKit
import CoreLocation

struct LocationPickerView: View {
    @StateObject private var locationManager = LocationService()
    @Binding private var coordinates: CLLocationCoordinate2D
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -0.3326, longitude: -78.4408), // Sangolquí por defecto
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    @State private var selectedCoordinate: CLLocationCoordinate2D?

    init(coordinates: Binding<CLLocationCoordinate2D>) {
        self._coordinates = coordinates
    }

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                if let selected = selectedCoordinate {
                    Annotation("Ubicación", coordinate: selected) {
                        Image(.logoFieldfinderTransparent)

                    }
                }
            }
            .onMapCameraChange { context in
                selectedCoordinate = context.camera.centerCoordinate
                // Actualizamos automáticamente el valor del binding
                coordinates = selectedCoordinate ?? CLLocationCoordinate2D()
            }

            // Pin centrado visual en el medio de la pantalla
            Image(.logoFieldfinderTransparent)
        }
        .onAppear {
            Task {
                do {
                    let userLocation = try await locationManager.requestLocation()
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: userLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )
                    selectedCoordinate = userLocation
                    coordinates = userLocation // Inicializa la coordenada con la posición actual
                } catch {
                    print("Error al obtener ubicación: \(error.localizedDescription)")
                    selectedCoordinate = cameraPosition.region?.center
                    coordinates = selectedCoordinate ?? CLLocationCoordinate2D()
                }
            }
        }
    }
}

#Preview {
    LocationPickerView(coordinates: .constant(CLLocationCoordinate2D()))
        .environment(\.locale, .init(identifier: "en"))
}
