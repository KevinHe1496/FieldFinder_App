//
//  NetworkFavoriteUser.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 13/5/25.
//

import Foundation

protocol UserFavoritesServiceProtocol {
    func favoriteUser(with establishmentId: String) async throws
    func deleteFavoriteUser(with establishmentId: String) async throws
    func getFavoriteUser() async throws -> [FavoriteEstablishment]
}

final class UserFavoritesService: UserFavoritesServiceProtocol {
    func favoriteUser(with establishmentId: String) async throws {
        
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.favoriteUser.rawValue)/\(establishmentId)"
        
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.post
        request.addValue(HttpHeader.content, forHTTPHeaderField: HttpHeader.contentTypeID)
        let jwtToken = KeyChainFF().loadPK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
        request.setValue("\(HttpHeader.bearer) \(jwtToken)", forHTTPHeaderField: HttpHeader.authorization)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        // Verifica que la respuesta sea válida y del tipo HTTPURLResponse.
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FFError.errorFromApi(statusCode: -1)
        }
        
        // Valida que el código de respuesta HTTP sea exitoso.
        guard httpResponse.statusCode == HttpResponseCodes.SUCCESS else {
            throw FFError.errorFromApi(statusCode: httpResponse.statusCode)
        }
    }
    
    func deleteFavoriteUser(with establishmentId: String) async throws  {
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.favoriteUser.rawValue)/\(establishmentId)"
        
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.delete
        request.addValue(HttpHeader.content, forHTTPHeaderField: HttpHeader.contentTypeID)
        let jwtToken = KeyChainFF().loadPK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
        request.setValue("\(HttpHeader.bearer) \(jwtToken)", forHTTPHeaderField: HttpHeader.authorization)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        // Verifica que la respuesta sea válida y del tipo HTTPURLResponse.
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FFError.errorFromApi(statusCode: -1)
        }
        
        // Valida que el código de respuesta HTTP sea exitoso.
        guard httpResponse.statusCode == HttpResponseCodes.SUCCESS else {
            throw FFError.errorFromApi(statusCode: httpResponse.statusCode)
        }
    }
    
    func getFavoriteUser() async throws -> [FavoriteEstablishment] {
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.favoriteUser.rawValue)"
        
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.get
        let jwtToken = KeyChainFF().loadPK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
        request.setValue("\(HttpHeader.bearer) \(jwtToken)", forHTTPHeaderField: HttpHeader.authorization)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Verifica que la respuesta sea válida y del tipo HTTPURLResponse.
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FFError.errorFromApi(statusCode: -1)
        }
        
        // Valida que el código de respuesta HTTP sea exitoso.
        guard httpResponse.statusCode == HttpResponseCodes.SUCCESS else {
            throw FFError.errorFromApi(statusCode: httpResponse.statusCode)
        }
        
        do {
            let result = try JSONDecoder().decode([FavoriteEstablishment].self, from: data)
            return result
        } catch {
            print("Error: \(error.localizedDescription)")
            throw FFError.dataNoReveiced
        }
    }
}
