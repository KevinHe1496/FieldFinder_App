//
//  PhotoGalleryView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 12/5/25.
//
import SwiftUI

struct PhotoGalleryView: View {
    let photoURLs: [URL]
    let height: CGFloat
    
    @State private var selectedPhoto: PhotoURL? = nil
    
    var body: some View {
        if !photoURLs.isEmpty {
            TabView {
                ForEach(photoURLs, id: \.self) { photoURL in
                    AsyncImage(url: photoURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: height)
                                .background(Color.gray.opacity(0.3))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: height)
                                .clipped()
                                .contentShape(Rectangle()) // Permite que todo el área responda al toque
                                .onTapGesture {
                                    if let index = photoURLs.firstIndex(of: photoURL) {
                                        selectedPhoto = PhotoURL(url: photoURL, index: index)
                                    }
                                }

                        case .failure:
                            VStack(spacing: 10) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 40))
                                Text("Sin fotos disponibles")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(.secondary)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: height)
            .sheet(item: $selectedPhoto) { photo in
                FullscreenImageView(photoURLs: photoURLs, selectedIndex: photo.index)
            }

        } else {
            VStack(spacing: 10) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 40))
                Text("Sin fotos disponibles")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(Color.gray.opacity(0.3))
        }
    }
}

struct PhotoURL: Identifiable {
    let id = UUID()
    let url: URL
    let index: Int
}

