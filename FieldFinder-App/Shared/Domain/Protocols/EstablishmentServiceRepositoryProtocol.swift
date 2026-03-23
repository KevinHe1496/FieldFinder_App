import Foundation
import CoreLocation

protocol EstablishmentServiceRepositoryProtocol {
    func createEstablishment(_ establishmentModel: EstablishmentRequest) async throws -> String
    func uploadEstablishmentImages(establishmentID: String, images: [Data]) async throws
    func updateEstablishment(establishmentID: String, establishmentModel: EstablishmentRequest) async throws
    func fetchEstablishment(with establishmentId: String) async throws -> EstablishmentResponse
    func fetchAllEstablishments(coordinate: CLLocationCoordinate2D) async throws -> [EstablishmentResponse]
    func deleteEstablishmentById(with establishmentId: String) async throws
}
