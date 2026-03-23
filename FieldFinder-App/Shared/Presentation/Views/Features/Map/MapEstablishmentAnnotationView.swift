//
//  EstablishmentAnnotationView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 14/5/25.
//

import SwiftUI

struct MapEstablishmentAnnotationView: View {
    var establishment: EstablishmentResponse
    
    var body: some View {
        VStack {
            Image(.logoFieldfinderTransparent)
            Text(establishment.name)
                .foregroundStyle(Color.colorBlack)
                .font(.caption)
                .fixedSize()
                .padding(4)
                .background(.thirdColorWhite)
                .cornerRadius(5)
        }
    }
}

#Preview {
    MapEstablishmentAnnotationView(establishment: .sample)
}
