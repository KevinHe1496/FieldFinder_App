//
//  CustomUIImage.swift
//  FieldFinder-App
//
//  Created by Andy Heredia on 13/5/25.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct CustomUIImage: View {
    
 
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @Binding var selectedImagesData: [Data]
    @State private var selectedImageToPreview: Data? = nil
    
    var body: some View {
        VStack {
            Text("Añadir fotografías:")
                .font(.appSubtitle)
            
            if selectedImagesData.count < 12 {
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 12 - selectedImagesData.count,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 24))
                            .foregroundStyle(.primaryColorGreen)
                        Text("Seleccionar fotos")
                            .foregroundStyle(.primaryColorGreen)
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .onChange(of: selectedItems) { newItems, _ in
                    Task {
                        for item in newItems {
                            if let originalData = try? await item.loadTransferable(type: Data.self),
                               let resizedData = ResizeImagesData.resizeImageData(from: originalData) {
                                
                                selectedImagesData.append(resizedData)
                                
                            }
                        }
                        selectedItems = []
                    }
                }
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(Array(selectedImagesData.enumerated()), id: \.offset) { index, imageData in
                        if let uiImage = UIImage(data: imageData) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .onTapGesture {
                                        selectedImageToPreview = imageData
                                    }
                                
                                Button {
                                    selectedImagesData.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                        .background(Color.white.clipShape(Circle()))
                                }
                                .offset(x: -5, y: 5)
                            }
                        }
                    }
                    
                }
            }
        }
        .fullScreenCover(isPresented: Binding<Bool>(
            get: { selectedImageToPreview != nil },
            set: { newValue in
                if !newValue { selectedImageToPreview = nil }
            })
        ) {
            if let imageData = selectedImageToPreview,
               let uiImage = UIImage(data: imageData) {
                ZStack(alignment: .topTrailing) {
                    Color.black.ignoresSafeArea()
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .background(Color.black)
                    
                    Button {
                        selectedImageToPreview = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
            }
        }
    }
}

#Preview {
    CustomUIImage(selectedImagesData: .constant([]))
}
