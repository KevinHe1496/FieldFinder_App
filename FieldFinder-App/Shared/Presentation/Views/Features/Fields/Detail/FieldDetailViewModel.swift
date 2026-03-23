//
//  FieldDetailViewModel.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 13/5/25.
//

import Foundation

@Observable
final class FieldDetailViewModel {
    var state: ViewState<FieldResponse> = .idle
    
    @ObservationIgnored
    private var useCase: FieldServiceUseCaseProtocol
    
    init(useCase: FieldServiceUseCaseProtocol = FieldServiceUseCase()) {
        self.useCase = useCase
    }
    
    @MainActor
    func getFieldDetail(with fieldId: String) async throws {
        state = .loading
        do {
            let cancha = try await useCase.fetchField(with: fieldId)
            state = .success(cancha)
        } catch {
            state = .error("No se pudo cargar la cancha.")
        }
    }
}
