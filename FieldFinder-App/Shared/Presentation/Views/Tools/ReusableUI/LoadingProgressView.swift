//
//  LoadingProgressView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 22/5/25.
//

import SwiftUI

struct LoadingProgressView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(1.3)
    }
}

#Preview {
    LoadingProgressView()
}
