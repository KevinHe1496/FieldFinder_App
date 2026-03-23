//
//  FieldInfoSection.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 16/5/25.
//


import SwiftUI

struct FieldInfoSection: View {
    let fieldData: FieldResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Información")
                    .font(.title3.bold())
                    .foregroundStyle(.primaryColorGreen)

                Divider()
                
                Text(
                    String(                                   // 1️⃣ formamos el String final
                        format: NSLocalizedString(
                                    "Cancha de: %@",          // 2️⃣ clave de la etiqueta
                                    comment: "Label + type"),
                        NSLocalizedString(                    // 3️⃣ clave del valor dinámico
                            fieldData.tipo.capitalized,
                            comment: "Field surface type")
                    )
                )


                Text(String.localizedStringWithFormat(
                        NSLocalizedString("game_of_fmt", comment: "Label + play mode"),
                        fieldData.modalidad)
                )

                Text(String.localizedStringWithFormat(
                        NSLocalizedString("price_per_hour_fmt", comment: "Price per hour"),
                        fieldData.precio)
                )
            }
        }
        .padding(20)
        .background(.thirdColorWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
