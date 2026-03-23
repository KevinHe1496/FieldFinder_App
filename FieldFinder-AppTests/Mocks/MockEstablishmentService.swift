import Foundation
import CoreLocation

@testable import FieldFinder_App
final class MockEstablishmentService: EstablishmentServiceProtocol {
    
    
    
    var didCallUploadImages = false
    var didCallUpdateEstablishment = false
    var lastUploadedImages: [Data] = []
    var lastUpdatedEstablishment: EstablishmentRequest?
    var didCallDeleteEstablishment = false
    
    func createEstablishment(_ establishmentModel: EstablishmentRequest) async throws -> String {
        return "mock_establishment_id"
    }
    
    func uploadEstablishmentImages(establishmentID: String, images: [Data]) async throws {
        didCallUploadImages = true
        lastUploadedImages = images
    }
    
    func updateEstablishment(establishmentID: String, establishmentModel: EstablishmentRequest) async throws {
        didCallUpdateEstablishment = true
        lastUpdatedEstablishment = establishmentModel
    }
    
    func fetchEstablishment(with establishmentId: String) async throws -> EstablishmentResponse {
        getMockEstablishment()
    }
    
    func fetchAllEstablishments(coordinate: CLLocationCoordinate2D) async throws -> [EstablishmentResponse] {
        [getMockEstablishment()]
    }
    
    func deleteEstablishmentById(with establishmentId: String) async throws {
        didCallDeleteEstablishment = true
    }
    
    private func getMockEstablishment() -> EstablishmentResponse {
        
        return EstablishmentResponse(
            id: "mock123",
            name: "Mock Cancha",
            ownerID: "2",
            info: "Cancha de prueba para tests unitarios.",
            address: "Calle Falsa 123",
            isFavorite: false,
            address2: "Carlota Jaramillo",
            phone: "+0000000000",
            userName: "test_user",
            userRol: "tester",
            parquedero: true,
            vestidores: false,
            banos: true,
            duchas: false,
            bar: false,
            fotos: [
                "https://mock.url/image1.jpg",
                "https://mock.url/image2.jpg"
            ],
            latitude: 0.123456,
            longitude: -0.123456,
            canchas:  [
                FieldResponse(
                    id: "field001",
                    tipo: "Fútbol",
                    modalidad: "Libre",
                    precio: 0,
                    cubierta: false,
                    iluminada: true,
                    fotos: [
                        "/mock/path/cancha1.jpg",
                        "/mock/path/cancha2.jpg"
                    ]
                )
            ]
        )
        
       
    }
    
    
}
