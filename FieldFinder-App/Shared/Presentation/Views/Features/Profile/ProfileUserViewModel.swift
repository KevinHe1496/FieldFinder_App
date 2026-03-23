//
//  ProfileUserViewModel.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 14/5/25.
//

import Foundation

@Observable
final class ProfileUserViewModel {
    
    var status: ViewState<UserProfileResponse> = .idle
    
    var messageError = ""

    @ObservationIgnored
    private var useCase: UserProfileServiceUseCaseProtocol
    
    init(useCase: UserProfileServiceUseCaseProtocol = UserProfileServiceUseCase()) {
        self.useCase = useCase
    }
    
    @MainActor
    func getMe() async throws {
        status = .loading
        do {
            let result = try await useCase.fetchUser()
            status = .success(result)
        } catch {
            status = .error("No se pudo cargar el perfil.")
        }
    }
    
    @MainActor
    func updateUser(name: String) async throws {
        _ = try await useCase.updateUser(name: name)
    }
    
    @MainActor
    func delete() async throws {
        _ = try await useCase.deleteUser()
    }
}
