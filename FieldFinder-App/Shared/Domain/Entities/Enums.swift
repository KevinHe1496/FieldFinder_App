import Foundation
import SwiftUI

// MARK: -- Tab Bar Item
enum TabBarItem: Hashable {
    case home, map, profile, favorites
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .map: return "map.fill"
        case .profile: return "person.fill"
        case .favorites: return "heart.fill"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .map: return "Mapa"
        case .profile: return "Perfil"
        case .favorites: return "Favoritos"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return Color.white
        case .map: return Color.white
        case .profile: return Color.white
        case .favorites: return Color.white
        }
    }
}

// MARK: -- StatusModel

enum StatusModel: Equatable {
    case login, loading, loaded, register, error(error: String), ownerView, registerCancha, home, registerUser
}


// MARK: -- ViewState

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case error(String)
}


extension ViewState {
    var data: T? {
        if case let .success(value) = self {
            return value
        }
        return nil
    }
}


// 1. Enum con los roles
enum UserRole: String, CaseIterable, Identifiable {
    case jugador = "Jugador"
    case dueno = "Dueno"
    
    
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .jugador:
            return NSLocalizedString("rol_usuario_jugador", comment: "Rol de jugador")
        case .dueno:
            return NSLocalizedString("rol_usuario_dueno", comment: "Rol de dueno")
        }
    }
}

enum Field: String, CaseIterable, Identifiable {
    case cesped = "cesped"
    case sintetico = "sintetico"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .sintetico:
            return NSLocalizedString("surface_synthetic", comment: "Synthetic field surface")
        case .cesped:
            return NSLocalizedString("surface_grass", comment: "Grass field surface")
        }
    }
}

enum Capacidad: String, CaseIterable, Identifiable {
    case cinco = "5-5"
    case siete = "7-7"
    case nueve = "9-9"
    case once = "11-11"
    
    var id: String { self.rawValue }
}
