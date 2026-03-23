import Foundation

final class FieldServiceRepository: FieldServiceRepositoryProtocol {
   
    
    var network: FieldServiceProtocol
    
    init(network: FieldServiceProtocol = FieldService()) {
        self.network = network
    }
    // GET ID
    func createField(_ fieldModel: FieldRequest, establishmentID: String) async throws -> String {
        try await network.createField(fieldModel, establishmentID: establishmentID)
    }
    
    // UPLOAD IMAGES
    
    func uploadFieldImages(fieldID: String, images: [Data]) async throws {
        try await network.uploadFieldImages(fieldID: fieldID, images: images)
    }
    
    func updateField(fieldID: String, fieldModel: FieldRequest) async throws -> FieldRequest {
        try await network.updateField(fieldID: fieldID, fieldModel: fieldModel)
    }
    
    func deleteField(fieldID: String) async throws {
        try await network.deleteField(fieldID: fieldID)
    }
    
    func fetchField(with fieldId: String) async throws -> FieldResponse {
        try await network.fetchField(with: fieldId)
    }
    
}
