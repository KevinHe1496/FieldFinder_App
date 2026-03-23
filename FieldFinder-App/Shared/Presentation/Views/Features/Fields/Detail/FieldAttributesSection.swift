//
//  FieldAttributesSection.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 16/5/25.
//


import SwiftUI

struct FieldAttributesSection: View {
    let fieldData: FieldResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Características")
                    .font(.headline)
                    .foregroundStyle(.primaryColorGreen)

                FieldAttributesView(
                    iluminada: fieldData.iluminada,
                    cubierta: fieldData.cubierta
                )
            }
        }
        .padding(20)
        .background(.thirdColorWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
