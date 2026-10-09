//
//  AuthSessionTests.swift
//  FieldFinder-AppTests
//

import XCTest

@testable import FieldFinder_App
final class AuthSessionTests: XCTestCase {

    /// Arma un JWT sin firma válida, solo con el payload `exp`.
    private func makeJWT(exp: Date) -> String {
        let header = Data(#"{"alg":"HS512","typ":"JWT"}"#.utf8).base64URLEncoded()
        let payload = Data(#"{"exp":\#(Int(exp.timeIntervalSince1970)),"sub":"x"}"#.utf8).base64URLEncoded()
        return "\(header).\(payload).firma"
    }

    func test_isExpired_WithFutureExp_ShouldBeFalse() {
        let token = makeJWT(exp: Date().addingTimeInterval(3600))
        XCTAssertFalse(FFSessionTokens.isExpired(token))
    }

    func test_isExpired_WithPastExp_ShouldBeTrue() {
        let token = makeJWT(exp: Date().addingTimeInterval(-3600))
        XCTAssertTrue(FFSessionTokens.isExpired(token))
    }

    func test_isExpired_WithinLeeway_ShouldBeTrue() {
        let token = makeJWT(exp: Date().addingTimeInterval(30))
        XCTAssertTrue(FFSessionTokens.isExpired(token, leeway: 60))
    }

    func test_isExpired_WithGarbage_ShouldBeTrue() {
        XCTAssertTrue(FFSessionTokens.isExpired("no-es-un-jwt"))
        XCTAssertTrue(FFSessionTokens.isExpired(""))
    }

    func test_NewEndpoints_ShouldBeCorrect() {
        XCTAssertEqual(Endpoints.refreshToken.rawValue, "/auth/refresh")
        XCTAssertEqual(Endpoints.claimSuffix.rawValue, "/reclamar")
        XCTAssertEqual(Endpoints.myClaims.rawValue, "/claims/mis-solicitudes")
    }
}

final class ClaimEstablishmentViewModelTests: XCTestCase {

    private final class MockClaimService: ClaimServiceProtocol {
        var receivedBody: ClaimRequestBody?
        var receivedID: String?
        var errorToThrow: Error?

        func claimEstablishment(id: String, body: ClaimRequestBody) async throws {
            receivedID = id
            receivedBody = body
            if let errorToThrow { throw errorToThrow }
        }

        func fetchMyClaims() async throws -> [ClaimResponse] { [] }
    }

    private func makeValidViewModel(service: MockClaimService) -> ClaimEstablishmentViewModel {
        let viewModel = ClaimEstablishmentViewModel(service: service)
        viewModel.phone = "099 924 0790"
        viewModel.documentID = "1712345678"
        viewModel.message = "Soy el dueño desde 2019"
        return viewModel
    }

    @MainActor
    func test_Submit_WithValidData_SendsCleanBody() async {
        let service = MockClaimService()
        let viewModel = makeValidViewModel(service: service)
        viewModel.socialMedia = "   "

        await viewModel.submit(establishmentID: "ABC")

        XCTAssertTrue(viewModel.didSubmit)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(service.receivedID, "ABC")
        XCTAssertEqual(service.receivedBody?.telefonoContacto, "0999240790")
        XCTAssertEqual(service.receivedBody?.documentoIdentidad, "1712345678")
        XCTAssertNil(service.receivedBody?.redesSociales)
    }

    @MainActor
    func test_Submit_WithShortDocument_DoesNotCallService() async {
        let service = MockClaimService()
        let viewModel = makeValidViewModel(service: service)
        viewModel.documentID = "123"

        await viewModel.submit(establishmentID: "ABC")

        XCTAssertFalse(viewModel.didSubmit)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(service.receivedBody)
    }

    @MainActor
    func test_Submit_WhenAlreadyClaimed_ShowsServerReason() async {
        let service = MockClaimService()
        service.errorToThrow = ClaimError.conflict("Este establecimiento ya tiene dueño.")
        let viewModel = makeValidViewModel(service: service)

        await viewModel.submit(establishmentID: "ABC")

        XCTAssertFalse(viewModel.didSubmit)
        XCTAssertEqual(viewModel.errorMessage, "Este establecimiento ya tiene dueño.")
    }
}

private extension Data {
    func base64URLEncoded() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

final class EstablishmentDisplayTests: XCTestCase {

    private func establishment(phone: String, canchas: [FieldResponse] = []) -> EstablishmentResponse {
        EstablishmentResponse(
            id: "1", name: "Cancha Test", ownerID: "", info: "", address: "Calle 1, Quito",
            isFavorite: false, address2: nil, phone: phone, userName: "", userRol: "",
            parquedero: false, vestidores: false, banos: false, duchas: false, bar: false,
            fotos: [], latitude: -0.18, longitude: -78.46, canchas: canchas
        )
    }

    private func field(tipo: String, modalidad: String, precio: Double, cubierta: Bool = false) -> FieldResponse {
        FieldResponse(id: UUID().uuidString, tipo: tipo, modalidad: modalidad, precio: precio,
                      cubierta: cubierta, iluminada: true, fotos: [])
    }

    func test_WhatsAppNumber_EcuadorMobile() {
        XCTAssertEqual(establishment(phone: "099 924 0790").whatsAppNumber, "593999240790")
        XCTAssertEqual(establishment(phone: "+593 99 924 0790").whatsAppNumber, "593999240790")
        XCTAssertNil(establishment(phone: "").whatsAppNumber)
    }

    func test_WhatsAppNumber_LandlineHasNoWhatsApp() {
        XCTAssertNil(establishment(phone: "02 234 5678").whatsAppNumber)
        XCTAssertNil(establishment(phone: "+593 2 234 5678").whatsAppNumber)
        XCTAssertNil(establishment(phone: "(04) 256-7890").whatsAppNumber)
    }

    func test_CapacidadDisplayName() {
        XCTAssertEqual(Capacidad.cinco.displayName, "Fútbol 5")
        XCTAssertEqual(Capacidad.once.displayName, "Fútbol 11")
    }

    func test_MinPrice_IgnoresZero() {
        let est = establishment(phone: "", canchas: [
            field(tipo: "Sintético", modalidad: "7v7", precio: 0),
            field(tipo: "Sintético", modalidad: "5v5", precio: 35),
            field(tipo: "Césped", modalidad: "11v11", precio: 60)
        ])
        XCTAssertEqual(est.minPriceText, "$35")
    }

    func test_Filters() {
        let indoor5 = field(tipo: "Sintético", modalidad: "5v5", precio: 30, cubierta: true)
        XCTAssertTrue(FieldFilter.sintetica.matches(indoor5))
        XCTAssertTrue(FieldFilter.cubierta.matches(indoor5))
        XCTAssertTrue(FieldFilter.futbol5.matches(indoor5))
        XCTAssertFalse(FieldFilter.futbol7.matches(indoor5))
    }

    func test_HasOwner_FallsBackToOwnerID() {
        XCTAssertFalse(establishment(phone: "").hasOwner)
    }
}
