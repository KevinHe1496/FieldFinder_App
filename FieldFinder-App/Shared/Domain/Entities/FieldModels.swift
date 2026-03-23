import Foundation
// Register and Update
struct FieldRequest: Codable {
    let tipo: String
    let modalidad: String
    let precio: Double
    let iluminada: Bool
    let cubierta: Bool
    let establecimientoID: String
}

// Response ID
struct IDResponse: Codable {
    let id: String
}

// Get by ID
struct FieldResponse: Codable, Identifiable {
    let id: String
    let tipo: String
    let modalidad: String
    let precio: Double
    let cubierta: Bool
    let iluminada: Bool
    let fotos: [String]
    
    var photoCanchas: [URL] {
        fotos.compactMap { url in
            URL(string: "\(url)")
        }
    }
    
    static let sample = FieldResponse(
        id: "cancha001",
        tipo: "Césped",
        modalidad: "Partido completo",
        precio: 30,
        cubierta: true,
        iluminada: true,
        fotos: [
            "https://ejemplo.com/fotos/cancha001-1.jpg",
            "https://ejemplo.com/fotos/cancha001-2.jpg"
        ]
    )
}
