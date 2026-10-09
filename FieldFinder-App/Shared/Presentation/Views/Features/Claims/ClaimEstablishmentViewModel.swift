//
//  ClaimEstablishmentViewModel.swift
//  FieldFinder-App
//

import Foundation

@Observable
final class ClaimEstablishmentViewModel {

    // Formulario
    var relationship: ClaimRelationship = .propietario
    var phone: String = ""
    var documentID: String = ""
    var socialMedia: String = ""
    var message: String = ""

    // Estado
    var isSubmitting = false
    var errorMessage: String?
    var didSubmit = false

    @ObservationIgnored
    private let service: ClaimServiceProtocol

    init(service: ClaimServiceProtocol = ClaimService()) {
        self.service = service
    }

    private var phoneDigits: String { phone.filter(\.isNumber) }
    private var documentDigits: String { documentID.filter(\.isNumber) }

    /// Cédula (10 dígitos) o RUC (13 dígitos).
    var isDocumentValid: Bool {
        documentDigits.count == 10 || documentDigits.count == 13
    }

    var isPhoneValid: Bool {
        phoneDigits.count >= 7
    }

    var isMessageValid: Bool {
        message.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }

    var canSubmit: Bool {
        isPhoneValid && isDocumentValid && isMessageValid && !isSubmitting
    }

    @MainActor
    func submit(establishmentID: String) async {
        guard canSubmit else {
            errorMessage = validationMessage()
            return
        }

        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let social = socialMedia.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = ClaimRequestBody(
            telefonoContacto: phoneDigits,
            mensaje: message.trimmingCharacters(in: .whitespacesAndNewlines),
            documentoIdentidad: documentDigits,
            relacionConEstablecimiento: relationship,
            redesSociales: social.isEmpty ? nil : social
        )

        do {
            try await service.claimEstablishment(id: establishmentID, body: body)
            didSubmit = true
        } catch let error as ClaimError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = ClaimError.invalidResponse.errorDescription
        }
    }

    private func validationMessage() -> String {
        if !isPhoneValid { return "Ingresa un teléfono de contacto válido." }
        if !isDocumentValid { return "Ingresa tu cédula (10 dígitos) o RUC (13 dígitos)." }
        if !isMessageValid { return "Cuéntanos en al menos 10 caracteres cómo podemos verificar que eres el dueño." }
        return "Revisa los datos del formulario."
    }
}

@Observable
final class MyClaimsViewModel {

    var status: ViewState<[ClaimResponse]> = .idle

    @ObservationIgnored
    private let service: ClaimServiceProtocol

    init(service: ClaimServiceProtocol = ClaimService()) {
        self.service = service
    }

    @MainActor
    func load() async {
        if case .success = status {
            // Recarga sin mostrar el spinner a pantalla completa.
        } else {
            status = .loading
        }

        do {
            let claims = try await service.fetchMyClaims()
            status = .success(claims)
        } catch let error as ClaimError {
            status = .error(error.errorDescription ?? "No se pudieron cargar tus solicitudes.")
        } catch {
            status = .error("No se pudieron cargar tus solicitudes.")
        }
    }
}
