//
//  EstablishmentSelectedMapDestailView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 14/5/25.
//

import SwiftUI
import MapKit

struct EstablishmentSelectedMapDetailView: View {
    @Environment(\.dismiss) var dismiss
    let establishment: EstablishmentResponse
    @State private var viewModel = EstablishmentDetailViewModel()
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    // Managers reutilizables
    @Bindable var callManager: ExternalLinkManager
    @Bindable var mapsManager: ExternalLinkManager

    let onCallTap: () -> Void
    let onMapTap: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Imagen destacada
                    AsyncImage(url: establishment.photoEstablishment.first) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    } placeholder: {
                        ProgressView()
                            .frame(height: 220)
                    }
                    
                    // Nombre
                    Text(establishment.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primaryColorGreen)
                        .padding(.horizontal)
                    
                    // Información
                    if !establishment.info.isEmpty {
                        Text(establishment.info)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Teléfono

                        HStack {
                            Image(systemName: "phone.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.primaryColorGreen))
                                .shadow(radius: 4)
                            Text(establishment.phone)
                                .underline()

                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 1)
                        .padding(.horizontal)
                        .foregroundStyle(.colorBlack)
                        .onTapGesture {
                            onCallTap()
                        }
 

                    // Botón de ubicación
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.primaryColorGreen))
                            .shadow(radius: 4)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ir a la dirección")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(establishment.address)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 1)
                    .padding(.horizontal)
                    .onTapGesture {
                        Task {
                            onMapTap()
                        }
                    }
                    
                    NavigationLink {
                        EstablishmentDetailView(establishmentID: establishment.id)
                    } label: {
                        Text("Ver establecimiento")
                            .foregroundStyle(.white)
                            .font(.appButton)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.primaryColorGreen)
                            .clipShape(.buttonBorder)
                    }
                    .padding(.horizontal)
                    
                    
                    
                    // Botón Cancelar
                    CustomButtonView(title: "Cancelar", color: .primaryColorGreen, textColor: .white) {
                        dismiss()
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            
        }

        // Alerta Teléfono
        .alert(callManager.alertTitle, isPresented: $callManager.showAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Llamar") { callManager.openURL() }
        } message: {
            Text(callManager.alertMessage)
        }
        
        // Alerta Maps
        .alert(mapsManager.alertTitle, isPresented: $mapsManager.showAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Abrir") { mapsManager.openURL() }
        } message: {
            Text(mapsManager.alertMessage)
        }
    }
}


//#Preview {
//    EstablishmentSelectedMapDestailView(establishment: .sample)
//}

