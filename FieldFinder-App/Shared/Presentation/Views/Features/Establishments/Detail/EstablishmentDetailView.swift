import SwiftUI
import MapKit
import StoreKit

struct EstablishmentDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppState.self) var appState
    var establishmentID: String
    
    let rows = [GridItem(.fixed(200))]
    
    @State private var viewModel = EstablishmentDetailViewModel()
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var contentVisible = false
    @State private var showRegisterField = false
    @State private var showingStore = false
    @State private var showDeleteConfirmation = false
    
    init(establishmentID: String) {
        self.establishmentID = establishmentID
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            switch viewModel.status {
            case .idle, .loading:
                LoadingProgressView()
                
            case .success(let establecimiento):
                ScrollView {
                    VStack(spacing: 20) {
                        PhotoGalleryView(photoURLs: establecimiento.photoEstablishment, height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 4)
                        
                        EstablishmentInfoSection(
                            establishment: establecimiento,
                            callManager: viewModel.callManager,
                            mapsManager: viewModel.mapsManager,
                            onCallTap: {
                                viewModel.prepareCall(phone: establecimiento.phone)
                            },
                            onMapTap: {
                                viewModel.prepareMaps(for: establecimiento)
                            }
                        )
                        
                        EstablishmentServicesSection(establishment: establecimiento)
                        
                        if !establecimiento.canchas.isEmpty {
                            EstablishmentFieldsSection(
                                canchas: establecimiento.canchas,
                                establecimientoID: establecimiento.id
                            )
                        } else {
                            VStack(alignment: .center, spacing: 16) {
                                Image(systemName: "sportscourt")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.gray)
                                
                                Text("No hay canchas registradas")
                                    .font(.headline)
                                    .foregroundStyle(.primaryColorGreen)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .frame(height: 210)
                            .background(.thirdColorWhite)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        EstablishmentMapSection(
                            coordinate: establecimiento.coordinate,
                            showAlert: $viewModel.showOpenInMapsAlert,
                            mapsURL: viewModel.mapsURL,
                            prepareMaps: {
                                viewModel.prepareMapsURL(for: establecimiento)
                            },
                            cameraPosition: $cameraPosition
                        )
                    }
                    .padding(.top)
                    .animation(.easeInOut(duration: 0.4), value: contentVisible)
                }
                .alert("¿Estás seguro de que quieres eliminar este establecimiento?", isPresented: $showDeleteConfirmation) {
                    Button("Eliminar", role: .destructive) {
                        Task {
                            try await viewModel.deleteEstablishmentById(establishmentId: establecimiento.id)
                            dismiss()
                        }
                    }
                    Button("Cancelar", role: .cancel) { }
                }
            case .error(let message):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.primaryColorGreen)
                    Text("Error al cargar el establecimiento")
                        .font(.headline)
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Establecimiento")
        .sheet(isPresented: $showRegisterField) {
            RegisterFieldView(establecimientoID: establishmentID)
        }
        .task {
            try? await viewModel.getEstablishmentDetail(establishmentId: establishmentID)
            if case .success(let establecimiento) = viewModel.status {
                let coordinate = establecimiento.coordinate
                let region = MKCoordinateRegion(center: coordinate, span: .init(latitudeDelta: 0.005, longitudeDelta: 0.005))
                cameraPosition = .region(region)
                
                var viewedCount = UserDefaults.standard.integer(forKey: "establishmentViewCount")
                let reviewed = UserDefaults.standard.bool(forKey: "hasRequestedReviewEstablishment")
                
                if !reviewed {
                    viewedCount += 1
                    UserDefaults.standard.set(viewedCount, forKey: "establishmentViewCount")
                    
                    if viewedCount >= 5 {
                        requestReviewIfAppropriate()
                        UserDefaults.standard.set(true, forKey: "hasRequestedReviewEstablishment")
                    }
                }
            }
        }
    }
    
    @MainActor
    func requestReviewIfAppropriate() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        AppStore.requestReview(in: scene)
    }
}

#Preview {
    EstablishmentDetailView(establishmentID: "A4537A2F-8810-4AEF-8D0A-1FFAFEEB7747")
        .environment(AppState())
}
