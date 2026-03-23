//
//  EstablishmentMapSection.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 16/5/25.
//


import SwiftUI
import MapKit

struct EstablishmentMapSection: View {
    let coordinate: CLLocationCoordinate2D
    @Binding var showAlert: Bool
    let mapsURL: URL?
    let prepareMaps: () -> Void
    @Binding var cameraPosition: MapCameraPosition

    var body: some View {
        VStack(alignment: .leading, spacing: 12)  {
            VStack(alignment: .leading, spacing: 8) {
                Text("Ubicación")
                    .font(.headline)
                    .foregroundStyle(.primaryColorGreen)

                Map(position: $cameraPosition) {
                    Annotation("Ubicación", coordinate: coordinate) {
                        Image(.logoFieldfinderTransparent)
                            .resizable()
                    }
                }
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    prepareMaps()
                }
            }
            .padding(.horizontal, 20)
        }
        .padding()
        .background(.thirdColorWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        
        .alert("¿Abrir en Apple Maps?", isPresented: $showAlert) {
            Button("Abrir") {
                if let url = mapsURL {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Esto te llevará a la app Maps para ver la ubicación.")
        }
    }
}
