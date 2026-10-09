//
//  ClaimModels.swift
//  FieldFinder-App
//
//  Modelos para reclamar establecimientos sin dueño
//  (POST /establecimiento/:id/reclamar y GET /claims/mis-solicitudes).
//

import Foundation
import SwiftUI

/// Relación del usuario con el establecimiento que reclama. Debe coincidir con el backend.
enum ClaimRelationship: String, Codable, CaseIterable, Identifiable {
    case propietario
    case administrador
    case representante

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .propietario: return "Soy el dueño"
        case .administrador: return "Lo administro"
        case .representante: return "Represento al dueño"
        }
    }
}

/// Estado de una solicitud. Debe coincidir con el backend.
enum ClaimStatus: String, Codable {
    case pendiente
    case aprobada
    case rechazada

    var displayName: String {
        switch self {
        case .pendiente: return "En revisión"
        case .aprobada: return "Aprobada"
        case .rechazada: return "Rechazada"
        }
    }

    var color: Color {
        switch self {
        case .pendiente: return .orange
        case .aprobada: return .green
        case .rechazada: return .red
        }
    }

    var iconName: String {
        switch self {
        case .pendiente: return "clock.fill"
        case .aprobada: return "checkmark.seal.fill"
        case .rechazada: return "xmark.octagon.fill"
        }
    }
}

/// Cuerpo que se envía al reclamar un establecimiento.
struct ClaimRequestBody: Codable {
    let telefonoContacto: String
    let mensaje: String
    let documentoIdentidad: String
    let relacionConEstablecimiento: ClaimRelationship
    let redesSociales: String?
}

/// Solicitud tal como la devuelve el backend. Solo se decodifican los campos que usa la app.
struct ClaimResponse: Codable, Identifiable {
    let id: String
    let establecimientoID: String
    let establecimientoNombre: String
    let relacionConEstablecimiento: ClaimRelationship
    let status: ClaimStatus
}

/// Errores al reclamar, con mensajes listos para mostrar.
enum ClaimError: LocalizedError, Equatable {
    case notLoggedIn
    case conflict(String)
    case server(Int)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return "Inicia sesión para reclamar este establecimiento."
        case .conflict(let reason):
            return reason
        case .server(let code):
            return "No pudimos enviar tu solicitud (error \(code)). Intenta de nuevo más tarde."
        case .invalidResponse:
            return "No pudimos conectar con el servidor. Revisa tu conexión e intenta de nuevo."
        }
    }
}
