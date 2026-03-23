//
//  FieldAttributesView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 13/5/25.
//


import SwiftUI

struct FieldAttributesView: View {
    let iluminada: Bool
    let cubierta: Bool

    var body: some View {
        let items = [
            ("lightbulb.fill", "Iluminada", iluminada),
            ("house.fill", "Cubierta", cubierta)
        ]

        HStack(spacing: 20) {
            ForEach(items.indices, id: \.self) { index in
                attributeBox(
                    name: items[index].0,
                    label: items[index].1,
                    isAvailable: items[index].2
                )
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(.thirdColorWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func attributeBox(name: String, label: String, isAvailable: Bool) -> some View {
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
        .frame(width: 72)
    }
}

