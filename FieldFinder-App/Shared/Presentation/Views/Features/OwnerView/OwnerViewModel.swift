import Foundation

@MainActor
@Observable
final class OwnerViewModel {
    
    var establishments = UserProfileResponse(email: "", id: "", rol: "", name: "", establecimiento: [])
    
    @ObservationIgnored
    private var useCase: UserProfileServiceUseCaseProtocol
    @ObservationIgnored
    private let appState: AppState
    
    init(appState: AppState, useCase: UserProfileServiceUseCaseProtocol = UserProfileServiceUseCase()) {
        self.useCase = useCase
        self.appState = appState
        
        Task {
            await getEstablishments()
        }
    }
    
    func getEstablishments() async {
        do {
            let data = try await useCase.fetchUser()
            establishments = data
        } catch {
            print("Error en el viewModel decodificando datos")
        }
        
    }
    
    func canAddFieldandEstablishment() -> Bool {
        
        for est in establishments.establecimiento {
            print("establecimiento: \(est.name)")
        }
        
        let establishmentCount = establishments.establecimiento.count
        let canchaCount = establishments.establecimiento.flatMap { $0.canchas }.count
        
        if appState.fullVersionUnlocked {
            // Plan premium: hasta 2 establecimientos y 4 canchas por cada uno
            return establishmentCount <= 2 && canchaCount < (establishmentCount * 4)
        } else {
            // Plan free: solo 1 establecimiento y 1 cancha
            return establishmentCount == 0 && canchaCount == 0
        }
    }
}
