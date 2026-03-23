import Foundation

protocol FieldServiceUseCaseProtocol {
    var repo: FieldServiceRepositoryProtocol { get set }
    func createField(_ fieldModel: FieldRequest) async throws -> String
    func uploadFieldImages(fieldID: String, images: [Data]) async throws
    func updateField(fieldID: String, fieldModel: FieldRequest) async throws -> FieldRequest
    func deleteField(fieldID: String) async throws
}


final class FieldServiceUseCase: FieldServiceUseCaseProtocol {
   
    
    var repo: FieldServiceRepositoryProtocol
    
    init(repo: FieldServiceRepositoryProtocol = FieldServiceRepository()) {
        self.repo = repo
    }
    
    func createField(_ fieldModel: FieldRequest) async throws -> String {
        try await repo.createField(fieldModel)
    }
    
    
    func uploadFieldImages(fieldID: String, images: [Data]) async throws {
        try await repo.uploadFieldImages(fieldID: fieldID, images: images)
    }
    
    func updateField(fieldID: String, fieldModel: FieldRequest) async throws -> FieldRequest {
        try await repo.updateField(fieldID: fieldID, fieldModel: fieldModel)
    }
    
    func deleteField(fieldID: String) async throws {
        try await repo.deleteField(fieldID: fieldID)
    }
    
}
