import Foundation

protocol FieldServiceRepositoryProtocol {
    func createField(_ fieldModel: FieldRequest, establishmentID: String) async throws -> String
    func uploadFieldImages(fieldID: String, images: [Data]) async throws
    func updateField(fieldID: String, fieldModel: FieldRequest) async throws -> FieldRequest
    func deleteField(fieldID: String) async throws
    func fetchField(with fieldId: String) async throws -> FieldResponse
}


