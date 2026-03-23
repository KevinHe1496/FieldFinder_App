//
//  LoadingView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 8/5/25.
//


import SwiftUI

struct LoadingView: View {
    var body: some View {
        
        ZStack {
            Color.secondaryColorBlack
                .ignoresSafeArea()
            
            Image(.splashLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
        }
    }
}

#Preview {
    LoadingView()
}
