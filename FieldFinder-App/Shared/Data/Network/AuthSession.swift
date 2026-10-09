//
//  AuthSession.swift
//  FieldFinder-App
//
//  Manejo de la sesión: guardar tokens, renovar el access token cuando expira
//  y avisar a la app cuando ya no se puede renovar.
//

import Foundation

extension Notification.Name {
    /// Se publica cuando el access token expiró y no se pudo renovar con el refresh token.
    /// `AppState` la escucha para cerrar la sesión y volver al modo invitado.
    static let ffSessionExpired = Notification.Name("FFSessionExpired")
}

// MARK: - Tokens en Keychain

enum FFSessionTokens {

    static var accessToken: String {
        KeyChainFF().loadPK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
    }

    static var refreshToken: String {
        KeyChainFF().loadPK(key: ConstantsApp.CONS_REFRESH_TOKEN_ID_KEYCHAIN)
    }

    static func save(_ tokens: LoginResponse) {
        let keychain = KeyChainFF()
        keychain.savePK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN, value: tokens.accessToken)
        keychain.savePK(key: ConstantsApp.CONS_REFRESH_TOKEN_ID_KEYCHAIN, value: tokens.refreshToken)
    }

    static func saveRefreshToken(_ token: String) {
        KeyChainFF().savePK(key: ConstantsApp.CONS_REFRESH_TOKEN_ID_KEYCHAIN, value: token)
    }

    static func clear() {
        let keychain = KeyChainFF()
        keychain.deletePK(key: ConstantsApp.CONS_TOKEN_ID_KEYCHAIN)
        keychain.deletePK(key: ConstantsApp.CONS_REFRESH_TOKEN_ID_KEYCHAIN)
    }

    /// Lee la fecha `exp` del JWT sin validar la firma (eso lo hace el servidor).
    /// Devuelve `true` si el token ya expiró, expira en menos de `leeway` segundos o no se puede leer.
    static func isExpired(_ jwt: String, leeway: TimeInterval = 60) -> Bool {
        let parts = jwt.split(separator: ".")
        guard parts.count == 3 else { return true }

        var base64 = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 += "="
        }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = (json["exp"] as? NSNumber)?.doubleValue else {
            return true
        }

        return Date(timeIntervalSince1970: exp) <= Date().addingTimeInterval(leeway)
    }
}

// MARK: - Renovación del token

enum FFRefreshResult {
    /// Se obtuvieron tokens nuevos.
    case refreshed
    /// El servidor rechazó el refresh token (expiró o no hay): la sesión terminó.
    case rejected
    /// No se pudo contactar al servidor (sin internet, timeout). La sesión sigue guardada.
    case unreachable
}

/// Renueva el access token con el refresh token guardado.
/// Si varias peticiones reciben 401 al mismo tiempo, todas esperan una sola renovación.
actor FFTokenRefresher {

    static let shared = FFTokenRefresher()

    private var inFlight: Task<FFRefreshResult, Never>?

    func refresh(session: URLSession = .shared) async -> FFRefreshResult {
        if let inFlight {
            return await inFlight.value
        }

        let task = Task<FFRefreshResult, Never> {
            await FFTokenRefresher.performRefresh(session: session)
        }
        inFlight = task
        let result = await task.value
        inFlight = nil
        return result
    }

    private static func performRefresh(session: URLSession) async -> FFRefreshResult {
        let refreshToken = FFSessionTokens.refreshToken
        guard !refreshToken.isEmpty,
              let url = URL(string: "\(ConstantsApp.CONS_API_URL)\(Endpoints.refreshToken.rawValue)") else {
            return .rejected
        }

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.post
        request.setValue("\(HttpHeader.bearer) \(refreshToken)", forHTTPHeaderField: HttpHeader.authorization)

        let result: (Data, URLResponse)
        do {
            result = try await session.data(for: request)
        } catch {
            return .unreachable
        }
        let (data, response) = result

        guard let http = response as? HTTPURLResponse else {
            return .unreachable
        }
        // 401: refresh token vencido o inválido. 405: se mandó un access token en vez del refresh.
        guard http.statusCode == HttpResponseCodes.SUCCESS else {
            return (400..<500).contains(http.statusCode) ? .rejected : .unreachable
        }

        guard let tokens = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
            return .unreachable
        }
        FFSessionTokens.save(tokens)
        return .refreshed
    }
}

// MARK: - Peticiones autenticadas

extension URLSession {

    /// Igual que `data(for:)`, pero para peticiones con `Authorization: Bearer`:
    /// si el servidor responde 401, renueva el token una vez y reintenta.
    /// Si el servidor rechaza la renovación, borra los tokens y publica `.ffSessionExpired`.
    func ffData(for request: URLRequest) async throws -> (Data, URLResponse) {
        let (data, response) = try await self.data(for: request)

        guard let http = response as? HTTPURLResponse,
              http.statusCode == HttpResponseCodes.NOT_AUTHORIZED,
              let authorization = request.value(forHTTPHeaderField: HttpHeader.authorization),
              authorization.hasPrefix(HttpHeader.bearer) else {
            return (data, response)
        }

        // Usuario invitado (sin sesión): no hay nada que renovar ni cerrar.
        let currentToken = FFSessionTokens.accessToken
        guard !currentToken.isEmpty else {
            return (data, response)
        }

        let sentToken = authorization
            .dropFirst(HttpHeader.bearer.count)
            .trimmingCharacters(in: .whitespaces)

        // Otra petición ya renovó el token mientras esta iba en camino: reintentar con el nuevo.
        if sentToken != currentToken && !FFSessionTokens.isExpired(currentToken) {
            var retry = request
            retry.setValue("\(HttpHeader.bearer) \(currentToken)", forHTTPHeaderField: HttpHeader.authorization)
            return try await self.data(for: retry)
        }

        // 401 con un token vigente = falta de permisos (p. ej. no es el dueño), no sesión vencida.
        guard FFSessionTokens.isExpired(sentToken) else {
            return (data, response)
        }

        switch await FFTokenRefresher.shared.refresh(session: self) {
        case .refreshed:
            var retry = request
            retry.setValue("\(HttpHeader.bearer) \(FFSessionTokens.accessToken)",
                           forHTTPHeaderField: HttpHeader.authorization)
            return try await self.data(for: retry)

        case .rejected:
            FFSessionTokens.clear()
            await MainActor.run {
                NotificationCenter.default.post(name: .ffSessionExpired, object: nil)
            }
            return (data, response)

        case .unreachable:
            // Sin conexión: no cerramos la sesión, se intentará de nuevo en la próxima petición.
            return (data, response)
        }
    }
}
