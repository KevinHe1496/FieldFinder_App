import Foundation
import Combine
import StoreKit

@Observable
final class AppState {
    // Published
    var status = StatusModel.login
    var tokenJWT: String = ""
    
    var userRole: UserRole? {
        didSet {
            // 🔒 Guarda el valor en UserDefaults cuando cambia
            if let role = userRole {
                defaults.set(role.rawValue, forKey: "userRole")
            } else {
                defaults.removeObject(forKey: "userRole")
            }
        }
    }
    
    var userID: String? {
        didSet {
            // 🔒 Guarda el valor en UserDefaults cuando cambia
            if let id = userID {
                defaults.set(id, forKey: "userID")
            } else {
                defaults.removeObject(forKey: "userID")
            }
        }
    }
    
    var messageAlert: String = ""
    var showAlert: Bool = false
    /// Se muestra cuando el token expiró y no se pudo renovar.
    var showSessionExpiredAlert: Bool = false
    var isLoading: Bool = false
    var selectedEstablishmentID: String?
    
    // No Published
    @ObservationIgnored
    var isLogged: Bool = false
    
    private var storeTask: Task<Void, Never>?
    
    @ObservationIgnored
    private var sessionExpiredObserver: NSObjectProtocol?
    
    /// The StoreKit products we've loaded for the store.
    var products = [Product]()
    let defaults: UserDefaults
    
    @ObservationIgnored
    private var loginUseCase: UserAuthServiceUseCaseProtocol
    
    init(loginUseCase: UserAuthServiceUseCaseProtocol = UserAuthServiceUseCase(), defaults: UserDefaults = .standard) {
        self.loginUseCase = loginUseCase
        self.defaults = defaults
        
        // ✅ Recupera userRole y userID al iniciar la app
        if let savedRole = defaults.string(forKey: "userRole"),
           let role = UserRole(rawValue: savedRole) {
            self.userRole = role
        }
        self.userID = defaults.string(forKey: "userID")
        
        sessionExpiredObserver = NotificationCenter.default.addObserver(
            forName: .ffSessionExpired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleSessionExpired()
            }
        }
        
        Task {
            await validateToken()
        }
        
        storeTask = Task {
            await monitorTransactions()
        }
    }
    
    @MainActor
    func login(email: String, password: String) async throws {
        guard !email.isEmpty && !password.isEmpty else {
            messageAlert = String(localized: "Los campos son requeridos.")
            showAlert = true
            return
        }

        isLoading = true
        do {
            let loginApp = try await loginUseCase.login(email: email, password: password)
            
            if loginApp == true {
                self.status = .loading
                
                let user = try await UserProfileServiceUseCase().fetchUser()
                self.userID = user.id
                self.userRole = user.userRole
                
                self.status = .loaded
            } else {
                messageAlert = String(localized: "El email o la contraseña son inválidos.")
                showAlert = true
                status = .error(error: String(localized:"¡Ups! Algo salió mal"))
            }
        } catch {
            isLoading = false
            messageAlert =  String(localized: "Hubo un problema con tu usuario o contraseña. Intenta nuevamente.")
            showAlert = true
            print("Error al iniciar sesión: \(error.localizedDescription)")
            return
        }

        isLoading = false
        showAlert = false
    }

    
    @MainActor
    func closeSessionUser() {
        Task {
            try await loginUseCase.logout()
            self.status = .loading
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 segundos
            self.status = .login
            
            // 💥 Limpia los datos guardados al cerrar sesión
            self.userRole = nil
            self.userID = nil
        }
    }
    
    deinit {
        if let sessionExpiredObserver {
            NotificationCenter.default.removeObserver(sessionExpiredObserver)
        }
    }
    
    /// Al abrir la app: si el token expiró se intenta renovar; si no se puede,
    /// se borra la sesión guardada y la app queda en modo invitado.
    @MainActor
    func validateToken() async {
        guard await loginUseCase.validateToken() else {
            clearLocalSession()
            self.status = .login
            return
        }
        
        do {
            let user = try await UserProfileServiceUseCase().fetchUser()
            self.userRole = user.userRole
            self.userID = user.id
            self.status = .loaded
        } catch {
            NSLog("validateToken: no se pudo cargar el usuario: \(error)")
            self.status = .login
        }
    }
    
    /// Llamado cuando una petición recibe 401 y el refresh token tampoco sirve.
    @MainActor
    func handleSessionExpired() {
        // Si ya no hay datos de sesión, ya se manejó (varias peticiones pueden fallar a la vez).
        guard userID != nil || userRole != nil else { return }
        clearLocalSession()
        status = .login
        showSessionExpiredAlert = true
    }
    
    @MainActor
    private func clearLocalSession() {
        FFSessionTokens.clear()
        userRole = nil
        userID = nil
    }
    
    @MainActor
    func requestReviewIfAppropriate() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        
        AppStore.requestReview(in: scene)
    }
}
