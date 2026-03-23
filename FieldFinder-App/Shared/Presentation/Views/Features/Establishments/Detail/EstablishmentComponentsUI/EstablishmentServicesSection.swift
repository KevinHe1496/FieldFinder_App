//
//  EstablishmentServicesSection.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 16/5/25.
//


import SwiftUI

struct EstablishmentServicesSection: View {
    let establishment: EstablishmentResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Servicios disponibles")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .foregroundStyle(.primaryColorGreen)
                
                FacilitiesIconsView(
                    parquedero: establishment.parquedero,
                    vestidores: establishment.vestidores,
                    banos: establishment.banos,
                    duchas: establishment.duchas,
                    bar: establishment.bar
                )
            }
        }
        .padding(20)
        .background(.thirdColorWhite)
        .cornerRadius(16)
    }
}

#Preview {
    EstablishmentServicesSection(establishment: .sample)
}
