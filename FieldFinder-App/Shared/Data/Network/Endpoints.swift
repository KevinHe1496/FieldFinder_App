import Foundation

/// Endpoints of Server Side
enum Endpoints: String {
    // POSTS
    case login = "/auth/login"
    case registerUsers = "/auth/register"
    case registerEstablishment = "/establecimiento/register"
    case uploadImagesEstablishment = "/establecimiento/fotos"
    case registerCancha = "/cancha/register"
    case uploadImagesCancha = "/cancha/fotos"
    //GETS
    case getNearbyEstablishments = "/establecimiento/nearby"
    case getEstablishmentById = "/establecimiento"
    case getFieldById = "/cancha"
    case getMe = "/users/me"
    case getEstablishments = "/establecimiento/getEstablecimientos"
    
    case favoriteUser = "/users/favoritos"

}
