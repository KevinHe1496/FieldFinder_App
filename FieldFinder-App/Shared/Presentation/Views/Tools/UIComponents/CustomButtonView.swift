//
//  CustomButtonLoginRegister.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 8/5/25.
//


import SwiftUI

struct CustomButtonView: View {
    
    var title: LocalizedStringKey
    var color: Color
    var textColor: Color
    var action: () -> Void
    
    
    var body: some View {
        Button(action: action){
            Text(title)
                .font(.appButton)
                .padding()
                // El blanco sobre el verde de marca no tiene contraste suficiente: sobre verde va texto negro.
                .foregroundStyle(color == .primaryColorGreen ? Color.secondaryColorBlack : textColor)
                .frame(maxWidth: .infinity)
                .background(color)
                .clipShape(.buttonBorder)
        }
    }
}

#Preview {
    CustomButtonView(title: "Login", color: .primaryColorGreen, textColor: .white, action: {})
}
