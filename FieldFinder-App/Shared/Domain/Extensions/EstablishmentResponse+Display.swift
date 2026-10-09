//
//  EstablishmentResponse+Display.swift
//  FieldFinder-App
//
//  Datos derivados para mostrar en la UI: precio desde, tipos, distancia y WhatsApp.
//

import Foundation
import CoreLocation

/// Filtros rápidos de la lista de canchas.
enum FieldFilter: String, CaseIterable, Identifiable {
    case sintetica
    case cubierta
    case futbol5
    case futbol7

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sintetica: return String(localized: "Sintética")
        case .cubierta: return String(localized: "Cubierta")
        case .futbol5: return String(localized: "Fútbol 5")
        case .futbol7: return String(localized: "Fútbol 7")
        }
    }

    func matches(_ field: FieldResponse) -> Bool {
        switch self {
        case .sintetica:
            return field.tipo.lowercased().contains("sint")
        case .cubierta:
            return field.cubierta
        case .futbol5:
            return field.modalidad.contains("5")
        case .futbol7:
            return field.modalidad.contains("7")
        }
    }
}

extension EstablishmentResponse {

    /// Precio más bajo por hora entre sus canchas (ignora precios en 0).
    var minPrice: Double? {
        canchas.map(\.precio).filter { $0 > 0 }.min()
    }

    /// "$45" o "$12.50"; `nil` si no hay precio publicado.
    var minPriceText: String? {
        guard let price = minPrice else { return nil }
        return Self.formatPrice(price)
    }

    static func formatPrice(_ price: Double) -> String {
        if price.rounded() == price {
            return "$\(Int(price))"
        }
        return String(format: "$%.2f", price)
    }

    /// Etiquetas cortas para la tarjeta: tipo de superficie, cubierta y modalidades, sin repetir.
    var fieldTags: [String] {
        var tags: [String] = []
        for field in canchas {
            let tipo = field.tipo.capitalized
            if !tipo.isEmpty && !tags.contains(tipo) { tags.append(tipo) }
            if field.cubierta {
                let cubierta = String(localized: "Cubierta")
                if !tags.contains(cubierta) { tags.append(cubierta) }
            }
            let modalidad = field.modalidad.trimmingCharacters(in: .whitespaces)
            if !modalidad.isEmpty && !tags.contains(modalidad) { tags.append(modalidad) }
        }
        return Array(tags.prefix(3))
    }

    /// Distancia en km desde una ubicación.
    func distanceKm(from location: CLLocationCoordinate2D?) -> Double? {
        guard let location else { return nil }
        let from = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let to = CLLocation(latitude: latitude, longitude: longitude)
        return from.distance(from: to) / 1000
    }

    /// "850 m" o "3,4 km", con el separador decimal del idioma del teléfono.
    func distanceText(from location: CLLocationCoordinate2D?) -> String? {
        guard let km = distanceKm(from: location) else { return nil }
        if km < 1 {
            return "\(Int((km * 1000 / 10).rounded()) * 10) m"
        }
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = km < 10 ? 1 : 0
        formatter.minimumFractionDigits = 0
        let number = formatter.string(from: NSNumber(value: km)) ?? String(format: "%.1f", km)
        return "\(number) km"
    }

    /// Calle corta para la tarjeta: lo que va antes de la primera coma.
    var shortAddress: String {
        address.split(separator: ",").first.map { String($0).trimmingCharacters(in: .whitespaces) } ?? address
    }

    /// Teléfono en formato internacional sin "+", para wa.me.
    /// Ecuador: 0999240790 → 593999240790. Si ya trae código de país, se respeta.
    var whatsAppNumber: String? {
        var digits = phone.filter(\.isNumber)
        guard digits.count >= 9 else { return nil }
        if digits.hasPrefix("00") {
            digits.removeFirst(2)
        } else if digits.hasPrefix("0") {
            digits = "593" + digits.dropFirst()
        } else if digits.count == 9 {
            // Celular ecuatoriano escrito sin el 0 inicial (99 924 0790).
            digits = "593" + digits
        }
        // En Ecuador solo los celulares (09…) tienen WhatsApp; un fijo (02…, 04…) daría un link roto.
        if digits.hasPrefix("593") {
            return digits.hasPrefix("5939") && digits.count == 12 ? digits : nil
        }
        return digits.count >= 10 ? digits : nil
    }

    /// Abre WhatsApp con un mensaje listo para reservar.
    var whatsAppURL: URL? {
        guard let number = whatsAppNumber else { return nil }
        let message = String(localized: "Hola, vi \(name) en Field Finder y quiero reservar una cancha. ¿Qué horarios tienen disponibles?")
        let text = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://wa.me/\(number)?text=\(text)")
    }

    /// Link universal de Apple Maps para compartir o abrir la ubicación.
    var mapsShareURL: URL? {
        let query = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://maps.apple.com/?q=\(query)&ll=\(latitude),\(longitude)")
    }
}
