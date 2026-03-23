import Foundation

@Observable
final class UserAuthViewModel {
    // MARK: -- Properties
    private var appState: AppState
    var isLoading: Bool = false
    var isRegistered: Bool = false
    var showAlert: Bool = false
    var message: String?
    
    @ObservationIgnored
    private let useCase: UserAuthServiceUseCaseProtocol
    
    // MARK: - Initialization
    init(appState: AppState, useCase: UserAuthServiceUseCaseProtocol = UserAuthServiceUseCase()) {
        self.appState = appState
        self.useCase = useCase
    }
    
    @MainActor
    func registerUser(name: String, email: String, password: String, rol: String) async -> String? {
        if let validationError = validateFields(name: name, email: email, password: password) {
            isLoading = false
            showAlert = true
            return validationError
        }
        
        isLoading = true
        message = nil
        appState.status = .loading
      
        do {
            let result = try await useCase.registerUser(name: name, email: email, password: password, rol: rol)
            let user = try await UserProfileServiceUseCase().fetchUser()
            appState.userID = user.id
            appState.userRole = user.userRole
            
            if result {
                if rol == "dueno" {
                    appState.status = .register
                    isLoading = false
                    return nil
                } else {
                    appState.status = .login
                    isLoading = false
                    return nil
                }
                
            } else {
                appState.status = .error(error: "Nombre de usuario o contraseña incorrectos")
           
                isLoading = false
                return "Nombre de usuario o contraseña incorrectos"
            }
        } catch {
            appState.status = .error(error: "Algo salió mal")
            isLoading = false
            return "Algo salió mal"
        }
    }
    
    
    // MARK: - Validation

    /// Checks that all fields are filled and email/password are valid.
    func validateFields(name: String, email: String, password: String) -> String? {
        if name.isEmpty || email.isEmpty || password.isEmpty {
            message = "Todos los campos son requeridos."
            return message
        }
        if !email.contains("@") || !email.contains(".") {
            message = "Ingresa un correo electrónico válido, por ejemplo: usuario@ejemplo.com"
            return message
        }
        if password.count < 6 {
            message = "La contraseña debe tener al menos 6 caracteres."
            return message
        }
        return nil
    }
    
}
