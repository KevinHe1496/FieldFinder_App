//
//  Establecimiento.swift
//  FieldFinder-App
//
//  Created by Andy Heredia on 10/5/25.
//

import Foundation
// Register and Update
struct EstablishmentRequest: Codable {
    let name: String
    let info: String
    let address: String
    let address2: String?
    let parqueadero: Bool
    let vestidores: Bool
    let bar: Bool
    let banos: Bool
    let duchas: Bool
    let latitude: Double
    let longitude: Double
    let phone: String
}

// GET by ID

struct EstablishmentResponse: Codable, Identifiable {
    let id: String
    let name: String
    let ownerID: String
    let info: String
    let address: String
    var isFavorite: Bool
    let address2: String?
    let phone: String
    let userName: String
    let userRol: String
    let parquedero: Bool
    let vestidores: Bool
    let banos: Bool
    let duchas: Bool
    let bar: Bool
    let fotos: [String]
    let latitude: Double
    let longitude: Double
    let canchas: [FieldResponse]
    
    var photoEstablishment: [URL] {
        fotos.compactMap { url in
            URL(string: "\(url)")
        }
    }
    
    static let sample = EstablishmentResponse(
        id: "12345",
        name: "Cancha Los Libertadores",
        ownerID: "1",
        info: "Complejo deportivo con canchas de fútbol 7 y servicios adicionales.",
        address: "Av. Amazonas",
        isFavorite: true,
        address2: "Naciones Unidas",
        phone: "+593987654321",
        userName: "kevin_heredia",
        userRol: "jugador",
        parquedero: true,
        vestidores: true,
        banos: true,
        duchas: false,
        bar: true,
        fotos: [
            "https://fieldfinder-uploads.s3.us-east-2.amazonaws.com/establecimiento/AB5C5912-B724-45D9-9652-82CC28F060F8-italia.png",
            "https://fieldfinder-uploads.s3.us-east-2.amazonaws.com/establecimiento/0C86D230-290A-4183-BBDD-D9E6133B02A3-calzone.png"
        ],
        latitude: 0.0,
        longitude: 0.0,
        canchas: [
            FieldResponse(
                id: "cancha001",
                tipo: "Fútbol 7",
                modalidad: "Partido completo",
                precio: 30,
                cubierta: true,
                iluminada: true,
                fotos: [
                    "/uploads/cancha1.jpg",
                    "/uploads/cancha1b.jpg"
                ]
            )
        ]
    )
    
}

struct GetNearbyEstablishmentsRequest: Codable {
    let latitude: Double
    let longitude: Double
}

