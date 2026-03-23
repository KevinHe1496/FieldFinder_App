//
//  FavoriteEstablishment.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 13/5/25.
//

import Foundation

struct FavoriteEstablishmentModel: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let address: String
    let fotos: [String]
    
    var photoEstablishment: [URL] {
        fotos.compactMap { url in
            URL(string: "\(url)")
        }
    }
}
