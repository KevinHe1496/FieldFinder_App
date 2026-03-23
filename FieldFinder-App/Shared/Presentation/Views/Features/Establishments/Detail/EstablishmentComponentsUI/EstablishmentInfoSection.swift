//
//  EstablishmentInfoSection.swift
//  FieldFinder-App
//
//  Created by Andy Heredia on 23/5/25.
//



import SwiftUI

struct EstablishmentInfoSection: View {

    let establishment: EstablishmentResponse
    
    // Managers reutilizables
    @Bindable var callManager: ExternalLinkManager
    @Bindable var mapsManager: ExternalLinkManager
    
    let onCallTap: () -> Void
    let onMapTap: () -> Void
    

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Text(establishment.name)
                    .font(.title2.bold())
                    .foregroundStyle(.primaryColorGreen)
                
                Divider()
                Button {
                    onMapTap()
                } label: {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(.primaryColorGreen)
                        if establishment.address2 == "" {
                            Text(establishment.address)
                                .underline()
                        } else {
                            Text("\(establishment.address), \(establishment.address2 ?? "")")
                                .underline()
                        }
                        
                    }
                    .foregroundStyle(.colorBlack)
                }
                .buttonStyle(.plain)
                
                Button {
                    onCallTap()
                } label: {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(.primaryColorGreen)
                        Text(establishment.phone)
                            .underline()
                    }
                    .foregroundStyle(.colorBlack)
                }
                .buttonStyle(.plain)
                
                
                Divider()
                
                Text(establishment.info)
                    .font(.body)
            }
            .padding(.horizontal, 20)
        }
        .padding(20)
        .background(.thirdColorWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        
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
    
    private func callEstablishment(phone: String) {
        let formatted = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        if let url = URL(string: "tel://\(formatted)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
