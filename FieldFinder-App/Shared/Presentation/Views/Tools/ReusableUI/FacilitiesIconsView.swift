//
//  FacilitiesIconsView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 12/5/25.
//

import SwiftUI

struct FacilitiesIconsView: View {
    let parquedero: Bool
    let vestidores: Bool
    let banos: Bool
    let duchas: Bool
    let bar: Bool

    var body: some View {
        let items = [
            ("car.fill", "Parqueo", parquedero),
            ("tshirt.fill", "Vestidores", vestidores),
            ("toilet.fill", "Baños", banos),
            ("drop.fill", "Duchas", duchas),
            ("cup.and.saucer.fill", "Bar", bar)
        ]

        HStack(spacing: 12) {
            ForEach(items.indices, id: \.self) { index in
                facilityBox(
                    name: items[index].0,
                    label: items[index].1,
                    isAvailable: items[index].2
                )
            }
        }

        .background(.thirdColorWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private func facilityBox(name: String, label: String, isAvailable: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 34, height: 34)

                Image(systemName: isAvailable ? name : "xmark")
                    .font(.body)
                    .foregroundStyle(isAvailable ? .primaryColorGreen : .red)
            }

            Text(LocalizedStringKey(label))
                .font(.caption2)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .truncationMode(.tail)
                .foregroundStyle(.primary)
        }
        .frame(width: 64)
    }
}

