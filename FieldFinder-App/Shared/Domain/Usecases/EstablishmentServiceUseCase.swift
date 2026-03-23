import Foundation
import CoreLocation

protocol EstablishmentServiceUseCaseProtocol {
    var repo: EstablishmentServiceRepositoryProtocol { get set }
    func createEstablishment(_ establishmentModel: EstablishmentRequest) async throws -> String
    func uploadEstablishmentImages(establishmentID: String, images: [Data]) async throws
    func updateEstablishment(establishmentID: String, establishmentModel: EstablishmentRequest) async throws
    func fetchEstablishment(with establishmentId: String) async throws -> EstablishmentResponse
    func fetchAllEstablishments(coordinate: CLLocationCoordinate2D) async throws -> [EstablishmentResponse]
    func deleteEstablishmentById(with establishmentId: String) async throws
}

final class EstablishmentServiceUseCase: EstablishmentServiceUseCaseProtocol {
  
    var repo: EstablishmentServiceRepositoryProtocol
    
    init(repo: EstablishmentServiceRepositoryProtocol = EstablishmentServiceRepository()) {
        self.repo = repo
    }
    
    func createEstablishment(_ establishmentModel: EstablishmentRequest) async throws -> String {
        try await repo.createEstablishment(establishmentModel)
    }
    
    func uploadEstablishmentImages(establishmentID: String, images: [Data]) async throws {
        try await repo.uploadEstablishmentImages(establishmentID: establishmentID, images: images)
    }
    
    func updateEstablishment(establishmentID: String, establishmentModel: EstablishmentRequest) async throws {
        try await repo.updateEstablishment(establishmentID: establishmentID, establishmentModel: establishmentModel)
    }
    
    func fetchEstablishment(with establishmentId: String) async throws -> EstablishmentResponse {
        try await repo.fetchEstablishment(with: establishmentId)
    }
    
    func fetchAllEstablishments(coordinate: CLLocationCoordinate2D) async throws -> [EstablishmentResponse] {
        try await repo.fetchAllEstablishments(coordinate: coordinate)
    }
    
    func deleteEstablishmentById(with establishmentId: String) async throws {
        try await repo.deleteEstablishmentById(with: establishmentId)
    }
}
