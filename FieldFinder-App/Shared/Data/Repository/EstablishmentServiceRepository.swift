import Foundation
import CoreLocation

final class EstablishmentServiceRepository: EstablishmentServiceRepositoryProtocol {
   
    var network: EstablishmentServiceProtocol
    
    init(network: EstablishmentServiceProtocol = EstablishmentService()) {
        self.network = network
    }
    
    func registerEstablishment(_ establishmentModel: EstablishmentRequest) async throws -> String {
        try await network.createEstablishment(establishmentModel)
    }
    
 
    // Upload Images
    func createEstablishment(_ establishmentModel: EstablishmentRequest) async throws -> String {
        try await network.createEstablishment(establishmentModel)
    }
    
    func uploadEstablishmentImages(establishmentID: String, images: [Data]) async throws {
        try await network.uploadEstablishmentImages(establishmentID: establishmentID, images: images)
    }
    
    func updateEstablishment(establishmentID: String, establishmentModel: EstablishmentRequest) async throws {
        try await network.updateEstablishment(establishmentID: establishmentID, establishmentModel: establishmentModel)
    }
    
    func fetchEstablishment(with establishmentId: String) async throws -> EstablishmentResponse {
        try await network.fetchEstablishment(with: establishmentId)
    }
    
    func fetchAllEstablishments(coordinate: CLLocationCoordinate2D) async throws -> [EstablishmentResponse] {
        try await network.fetchAllEstablishments(coordinate: coordinate)
    }
    
    func deleteEstablishmentById(with establishmentId: String) async throws {
        try await network.deleteEstablishmentById(with: establishmentId)
    }
    
}
