//
//  MapEstablishmentsView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 9/5/25.
//

import SwiftUI
import MapKit

/// Vista principal que muestra un mapa con los establecimientos cercanos.
/// Permite seleccionar un establecimiento, centrar en la ubicación del usuario
/// y ver información detallada en una hoja inferior.
import SwiftUI
import MapKit

struct MapEstablishmentsView: View {
    
    @State var viewModel = PlayerGetNearbyEstablishmentsViewModel()
    @State var callManager = ExternalLinkManager()
    @State var mapsManager = ExternalLinkManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Contenido dinámico por estado
                switch viewModel.status {
                case .idle, .loading:
                    LoadingProgressView()
                    
                case .success(let establecimientos):
                    ZStack(alignment: .bottomTrailing) {
                        // Mapa con anotaciones
                        Map(position: $viewModel.cameraPosition) {
                            UserAnnotation()
                            ForEach(establecimientos) { establishment in
                                Annotation("", coordinate: establishment.coordinate) {
                                    Button {
                                        viewModel.selectEstablishment(establishment)
                                    } label: {
                                        MapEstablishmentAnnotationView(establishment: establishment)
                                    }
                                }
                            }
                        }
                        .ignoresSafeArea()
                        .toolbarBackground(Color(UIColor.systemGroupedBackground), for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbarBackground(Color(UIColor.systemGroupedBackground), for: .tabBar)
                        .toolbarBackground(.visible, for: .tabBar)
                        
                        // Botón para centrar en la ubicación
                        Button {
                            Task {
                                await viewModel.centerOnUserLocation()
                            }
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(Circle().fill(Color.primaryColorGreen))
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 24)
                    }
                    
                case .error(let message):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.primaryColorGreen)
                        Text(viewModel.showOpenSettings ? "Permiso de ubicación denegado." : "Ha ocurrido un error inesperado.")
                            .font(.headline)
                        Text(message)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        CustomButtonView(title: "Intentar de nuevo", color: .primaryColorGreen, textColor: .white) {
                            Task {
                                await viewModel.loadData()
                            }
                        }
                        if viewModel.showOpenSettings {
                            CustomButtonView(title: "Ir a Ajustes", color: .primaryColorGreen, textColor: .white) {
                                viewModel.openAppSettings()
                            }
                        }
                    }
                    .padding()
                }
            }
            .task {
                await viewModel.loadData()
            }
            .sheet(item: $viewModel.selectedEstablishment) { establishment in
                EstablishmentSelectedMapDetailView(
                    establishment: establishment,
                    callManager: callManager,
                    mapsManager: mapsManager,
                    onCallTap: {
                        openCallFor(establishment)
                    },
                    onMapTap: {
                        openMapsFor(establishment)
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .navigationTitle("Establecimientos cercanos")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func openCallFor(_ establishment: EstablishmentResponse) {
        callManager.prepareToOpen(
            title: "¿Llamar al propietario?",
            message: "Esto iniciará una llamada al número del establecimiento.",
            url: URL(string: "tel://\(establishment.phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: ""))")
        )
    }

    func openMapsFor(_ establishment: EstablishmentResponse) {
        let placeName = establishment.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Ubicación"
        let coord = establishment.coordinate
        let url = URL(string: "maps://?q=\(placeName)&ll=\(coord.latitude),\(coord.longitude)")
        mapsManager.prepareToOpen(
            title: "¿Abrir en Apple Maps?",
            message: "Esto abrirá la app Mapas con la ubicación del establecimiento.",
            url: url
        )
    }

}

#Preview {
    MapEstablishmentsView()
}
