//
//  ClaimService.swift
//  FieldFinder-App
//
//  Reclamar un establecimiento sin dueño y ver las solicitudes propias.
//

import Foundation

protocol ClaimServiceProtocol {
    func claimEstablishment(id: String, body: ClaimRequestBody) async throws
    func fetchMyClaims() async throws -> [ClaimResponse]
}

final class ClaimService: ClaimServiceProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// POST /establecimiento/:id/reclamar
    func claimEstablishment(id: String, body: ClaimRequestBody) async throws {
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.getEstablishmentById.rawValue)/\(id)\(Endpoints.claimSuffix.rawValue)"
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }

        let token = FFSessionTokens.accessToken
        guard !token.isEmpty else {
            throw ClaimError.notLoggedIn
        }

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.post
        request.setValue(HttpHeader.content, forHTTPHeaderField: HttpHeader.contentTypeID)
        request.setValue("\(HttpHeader.bearer) \(token)", forHTTPHeaderField: HttpHeader.authorization)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.ffData(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw ClaimError.invalidResponse
        }

        switch http.statusCode {
        case 200..<300:
            return
        case HttpResponseCodes.NOT_AUTHORIZED:
            throw ClaimError.notLoggedIn
        case 409:
            // "Este establecimiento ya tiene dueño." o "Ya tienes una solicitud pendiente..."
            throw ClaimError.conflict(Self.serverReason(from: data) ?? "Este establecimiento ya fue reclamado.")
        default:
            throw ClaimError.server(http.statusCode)
        }
    }

    /// GET /claims/mis-solicitudes
    func fetchMyClaims() async throws -> [ClaimResponse] {
        let urlString = "\(ConstantsApp.CONS_API_URL)\(Endpoints.myClaims.rawValue)"
        guard let url = URL(string: urlString) else {
            throw FFError.badUrl
        }

        let token = FFSessionTokens.accessToken
        guard !token.isEmpty else {
            throw ClaimError.notLoggedIn
        }

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.get
        request.setValue("\(HttpHeader.bearer) \(token)", forHTTPHeaderField: HttpHeader.authorization)

        let (data, response) = try await session.ffData(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw ClaimError.invalidResponse
        }
        guard http.statusCode == HttpResponseCodes.SUCCESS else {
            if http.statusCode == HttpResponseCodes.NOT_AUTHORIZED {
                throw ClaimError.notLoggedIn
            }
            throw ClaimError.server(http.statusCode)
        }

        do {
            return try JSONDecoder().decode([ClaimResponse].self, from: data)
        } catch {
            throw FFError.decodingError
        }
    }

    /// Vapor responde los errores como `{ "error": true, "reason": "..." }`.
    private static func serverReason(from data: Data) -> String? {
        struct VaporError: Decodable { let reason: String }
        return try? JSONDecoder().decode(VaporError.self, from: data).reason
    }
}
