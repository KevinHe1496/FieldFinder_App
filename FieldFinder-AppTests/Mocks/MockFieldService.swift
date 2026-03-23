import Foundation

@testable import FieldFinder_App
final class MockFieldService: FieldServiceProtocol {
    
    
    var didCallUploadImages = false
    var didCallDeleteField = false
    var didCallUpdateField = false
    var lastUploadedImages: [Data] = []
    var lastUpdatedField: FieldRequest?
    
    func createField(_ fieldModel: FieldRequest, establishmentID: String) async throws -> String {
        "mock_field_id"
    }
    
    func uploadFieldImages(fieldID: String, images: [Data]) async throws {
        didCallUploadImages = true
        lastUploadedImages = images
    }
    
    func updateField(fieldID: String, fieldModel: FieldRequest) async throws -> FieldRequest {
        didCallUpdateField = true
        lastUpdatedField = fieldModel
        return getMockFieldRequest()
    }
    
    func deleteField(fieldID: String) async throws {
        didCallDeleteField = true
    }
    
    func fetchField(with fieldId: String) async throws -> FieldResponse {
        getMockFieldResponse()
    }
    
    func getMockFieldRequest() -> FieldRequest {
        return FieldRequest(
            tipo: "Sintético",
            modalidad: "7-7",
            precio: 40.0,
            iluminada: true,
            cubierta: true,
            establecimientoID: "1"
        )
    }
    
    func getMockFieldResponse() -> FieldResponse {
        return FieldResponse(
            id: "cancha001",
            tipo: "Fútbol 7",
            modalidad: "Partido completo",
            precio: 30,
            cubierta: true,
            iluminada: true,
            fotos: [
                "https://ejemplo.com/fotos/cancha001-1.jpg",
                "https://ejemplo.com/fotos/cancha001-2.jpg"
            ]
        )
    }
    
    
}
