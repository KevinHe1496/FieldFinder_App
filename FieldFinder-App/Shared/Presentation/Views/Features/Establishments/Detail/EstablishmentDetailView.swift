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
    @State private var showClaimSheet = false
    @State private var showLoginSheet = false
    
    init(establishmentID: String) {
        self.establishmentID = establishmentID
    }
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            
            switch viewModel.status {
            case .idle, .loading:
                LoadingProgressView()
                
            case .success(let establecimiento):
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        hero(for: establecimiento)
                        
                        header(for: establecimiento)
                            .padding(.horizontal, 20)
                        
                        if establecimiento.hasOwner {
                            fieldsSection(for: establecimiento)
                                .padding(.horizontal, 20)
                            
                            EstablishmentServicesSection(establishment: establecimiento)
                                .padding(.horizontal, 20)
                            
                            EstablishmentMapSection(
                                coordinate: establecimiento.coordinate,
                                showAlert: $viewModel.showOpenInMapsAlert,
                                mapsURL: viewModel.mapsURL,
                                prepareMaps: {
                                    viewModel.prepareMapsURL(for: establecimiento)
                                },
                                cameraPosition: $cameraPosition
                            )
                        } else {
                            unknownInfoCard(for: establecimiento)
                                .padding(.horizontal, 20)
                            
                            ClaimBannerView {
                                if appState.userID == nil {
                                    showLoginSheet = true
                                } else {
                                    showClaimSheet = true
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 24)
                    .animation(.easeInOut(duration: 0.4), value: contentVisible)
                }
                .safeAreaInset(edge: .bottom) {
                    bottomBar(for: establecimiento)
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
                        .foregroundStyle(Color.brandDeepGreen)
                    Text("Error al cargar el establecimiento")
                        .font(.headline)
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.brandTextSecondary)
                }
                .padding()
            }
        }
        // Alertas de llamar y abrir Mapas (antes vivían en EstablishmentInfoSection).
        .alert(viewModel.callManager.alertTitle, isPresented: Binding(
            get: { viewModel.callManager.showAlert },
            set: { viewModel.callManager.showAlert = $0 }
        )) {
            Button("Cancelar", role: .cancel) { }
            Button("Llamar") { viewModel.callManager.openURL() }
        } message: {
            Text(viewModel.callManager.alertMessage)
        }
        .alert(viewModel.mapsManager.alertTitle, isPresented: Binding(
            get: { viewModel.mapsManager.showAlert },
            set: { viewModel.mapsManager.showAlert = $0 }
        )) {
            Button("Cancelar", role: .cancel) { }
            Button("Abrir") { viewModel.mapsManager.openURL() }
        } message: {
            Text(viewModel.mapsManager.alertMessage)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .sheet(isPresented: $showRegisterField) {
            RegisterFieldView(establecimientoID: establishmentID)
        }
        .sheet(isPresented: $showClaimSheet) {
            if case .success(let establecimiento) = viewModel.status {
                ClaimEstablishmentView(
                    establishmentID: establecimiento.id,
                    establishmentName: establecimiento.name
                )
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
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
    
    // MARK: - Secciones
    
    @ViewBuilder
    private func hero(for establecimiento: EstablishmentResponse) -> some View {
        if establecimiento.hasOwner || !establecimiento.photoEstablishment.isEmpty {
            PhotoGalleryView(photoURLs: establecimiento.photoEstablishment, height: 280)
        } else {
            // Importada de Google Maps: sin fotos, mostramos dónde queda.
            Map(initialPosition: .region(MKCoordinateRegion(
                center: establecimiento.coordinate,
                span: .init(latitudeDelta: 0.006, longitudeDelta: 0.006)
            ))) {
                Marker(establecimiento.name, systemImage: "sportscourt.fill", coordinate: establecimiento.coordinate)
                    .tint(Color.secondaryColorBlack)
            }
            .frame(height: 220)
            .allowsHitTesting(false)
            .accessibilityLabel(Text("Mapa con la ubicación de \(establecimiento.name)"))
        }
    }
    
    private func header(for establecimiento: EstablishmentResponse) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                if establecimiento.hasOwner {
                    BrandTag(text: String(localized: "Verificada"), style: .verified, systemImage: "checkmark")
                    ForEach(establecimiento.fieldTags, id: \.self) { tag in
                        BrandTag(text: tag)
                    }
                } else {
                    BrandTag(text: String(localized: "Sin verificar · datos de Google Maps"), style: .warning)
                }
            }
            
            Text(establecimiento.name)
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.brandInk)
            
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(establecimiento.address2.map { $0.isEmpty ? establecimiento.address : "\(establecimiento.address), \($0)" } ?? establecimiento.address)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.brandTextSecondary)
                Spacer(minLength: 0)
                Button("Cómo llegar") {
                    viewModel.prepareMaps(for: establecimiento)
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.brandDeepGreen)
                .fixedSize()
            }
            
            if !establecimiento.info.isEmpty {
                Text(establecimiento.info)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.brandInk)
                    .padding(.top, 4)
            }
        }
    }
    
    private func fieldsSection(for establecimiento: EstablishmentResponse) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Canchas y precios")
                .font(.system(size: 17, weight: .bold))
            
            if establecimiento.canchas.isEmpty {
                Text("El dueño todavía no registró sus canchas.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.brandTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.brandCard, in: RoundedRectangle(cornerRadius: 14))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(establecimiento.canchas.enumerated()), id: \.element.id) { index, cancha in
                        NavigationLink {
                            FieldDetailView(fieldId: cancha.id, establecimientoID: establecimiento.id)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Cancha \(index + 1) · \(cancha.modalidad)")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Color.brandInk)
                                    Text(fieldDetails(cancha))
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.brandTextSecondary)
                                }
                                Spacer()
                                if cancha.precio > 0 {
                                    (Text(EstablishmentResponse.formatPrice(cancha.precio)).font(.system(size: 16, weight: .bold))
                                     + Text("/h").font(.system(size: 13)).foregroundColor(Color.brandTextSecondary))
                                        .foregroundStyle(Color.brandInk)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.brandTextSecondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        if index < establecimiento.canchas.count - 1 {
                            Divider().padding(.leading, 16)
                        }
                    }
                }
                .background(Color.brandCard, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.brandBorder, lineWidth: 1))
            }
        }
    }
    
    private func fieldDetails(_ cancha: FieldResponse) -> String {
        var parts = [cancha.tipo.capitalized]
        if cancha.cubierta { parts.append(String(localized: "Cubierta")) }
        if cancha.iluminada { parts.append(String(localized: "Iluminada")) }
        return parts.joined(separator: " · ")
    }
    
    private func unknownInfoCard(for establecimiento: EstablishmentResponse) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Todavía no sabemos")
                .font(.system(size: 15, weight: .bold))
            VStack(alignment: .leading, spacing: 8) {
                Label("Precio por hora", systemImage: "dollarsign.circle")
                Label("Tipo de cancha y tamaño", systemImage: "sportscourt")
                if establecimiento.phone.isEmpty {
                    Label("Teléfono y horarios", systemImage: "phone")
                } else {
                    Label("Horarios", systemImage: "clock")
                }
            }
            .font(.system(size: 14))
            .foregroundStyle(Color.brandTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.brandCard, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.brandBorder, lineWidth: 1))
    }
    
    // MARK: - Barra inferior fija
    
    private func bottomBar(for establecimiento: EstablishmentResponse) -> some View {
        let whatsAppURL = establecimiento.whatsAppURL
        
        return HStack(spacing: 10) {
            if establecimiento.hasOwner, let price = establecimiento.minPriceText {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desde")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.brandTextSecondary)
                    Text("\(price)/h")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.brandInk)
                }
                .fixedSize()
                .padding(.trailing, 4)
            }
            
            // Llamar: siempre que haya teléfono (con o sin dueño).
            if !establecimiento.phone.isEmpty {
                Button {
                    viewModel.prepareCall(phone: establecimiento.phone)
                } label: {
                    Image(systemName: "phone.fill")
                }
                .buttonStyle(BrandIconButtonStyle())
                .accessibilityLabel(Text("Llamar"))
            }
            
            if !establecimiento.hasOwner {
                // Sin dueño no hay sección de mapa: "Cómo llegar" queda como ícono si WhatsApp es el botón principal.
                if whatsAppURL != nil {
                    Button {
                        viewModel.prepareMaps(for: establecimiento)
                    } label: {
                        Image(systemName: "location.fill")
                    }
                    .buttonStyle(BrandIconButtonStyle())
                    .accessibilityLabel(Text("Cómo llegar"))
                } else if let shareURL = establecimiento.mapsShareURL {
                    ShareLink(item: shareURL, subject: Text(establecimiento.name)) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .buttonStyle(BrandIconButtonStyle())
                    .accessibilityLabel(Text("Compartir"))
                }
            }
            
            if let whatsAppURL {
                Button {
                    openURL(whatsAppURL)
                } label: {
                    Label(establecimiento.hasOwner ? LocalizedStringKey("Reservar por WhatsApp") : LocalizedStringKey("WhatsApp"),
                          systemImage: "bubble.left.fill")
                        .lineLimit(1)
                }
                .buttonStyle(BrandPrimaryButtonStyle())
            } else {
                Button {
                    viewModel.prepareMaps(for: establecimiento)
                } label: {
                    Label("Cómo llegar", systemImage: "location.fill")
                }
                .buttonStyle(BrandPrimaryButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color.brandCard)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.brandBorder).frame(height: 1)
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
