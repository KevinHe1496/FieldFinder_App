import SwiftUI
import CoreLocation


struct PlayerView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText = ""
    @State private var didLoad = false
    
    @State var viewModel: PlayerGetNearbyEstablishmentsViewModel
    @State private var shownItems: Set<String> = []
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.status {
                case .idle, .loading:
                    LoadingProgressView()
                    
                case .success(let all):
                    if all.isEmpty {
                        noFieldsHereView
                    } else {
                        listView
                    }
                    
                case .error(let message):
                    VStack(spacing: 16) {
                        Image(systemName: viewModel.showOpenSettings ? "location.slash.fill" : "exclamationmark.triangle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.brandDeepGreen)
                        Text(viewModel.showOpenSettings ? "Permiso de ubicación denegado." : "Ha ocurrido un error inesperado.")
                            .font(.headline)
                        Text(message)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.brandTextSecondary)
                        
                        if viewModel.showOpenSettings {
                            Button("Ir a Ajustes") { viewModel.openAppSettings() }
                                .buttonStyle(BrandPrimaryButtonStyle())
                            // Sin ubicación también se puede usar la app eligiendo una ciudad.
                            Button("Ver canchas en Quito") {
                                Task { await viewModel.loadData(near: PlayerGetNearbyEstablishmentsViewModel.quitoCoordinate, cityName: "Quito") }
                            }
                            .buttonStyle(BrandSecondaryButtonStyle())
                        } else {
                            Button("Intentar de nuevo") {
                                Task { await reloadEstablishments() }
                            }
                            .buttonStyle(BrandPrimaryButtonStyle())
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.brandBackground)
                }
            }
            .navigationTitle(viewModel.browsingCityName.map { "Canchas en \($0)" } ?? String(localized: "Canchas cerca de ti"))
            .searchable(text: $viewModel.establishmentSearch, prompt: Text("Busca por nombre o barrio"))
        }
    }
    
    // MARK: - Lista
    
    private var listView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                filterChips
                
                HStack {
                    Text(resultsLabel)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.brandTextSecondary)
                    Spacer()
                    if viewModel.browsingCityName != nil {
                        Button("Usar mi ubicación") {
                            Task { await reloadEstablishments() }
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.brandDeepGreen)
                    }
                }
                .padding(.horizontal, 20)
                
                if viewModel.filterEstablishments.isEmpty {
                    VStack(spacing: 12) {
                        Text("Ninguna cancha coincide con tu búsqueda")
                            .font(.headline)
                        Button("Quitar filtros") {
                            viewModel.activeFilters.removeAll()
                            viewModel.establishmentSearch = ""
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.brandDeepGreen)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filterEstablishments) { establishment in
                            NavigationLink {
                                EstablishmentDetailView(establishmentID: establishment.id)
                            } label: {
                                EstablishmentCardRow(
                                    establishment: establishment,
                                    userLocation: viewModel.userLocation,
                                    showFavorite: appState.userRole == .jugador,
                                    isFavorite: viewModel.isFavorite(establishmentId: establishment.id),
                                    onFavoriteTap: {
                                        Task { try? await viewModel.setLikeHero(establishmentId: establishment.id) }
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .padding(.top, 4)
        }
        .refreshable {
            if viewModel.browsingCityName != nil {
                await viewModel.loadData(near: viewModel.userLocation, cityName: viewModel.browsingCityName)
            } else {
                await viewModel.loadData()
            }
            try? await viewModel.getFavoritesUser()
        }
        .scrollIndicators(.hidden)
        .background(Color.brandBackground)
    }
    
    private var filterChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(FieldFilter.allCases) { filter in
                    BrandFilterChip(
                        title: filter.title,
                        isSelected: viewModel.activeFilters.contains(filter)
                    ) {
                        viewModel.toggleFilter(filter)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }
    
    private var resultsLabel: String {
        let count = viewModel.filterEstablishments.count
        let noun = count == 1 ? String(localized: "cancha") : String(localized: "canchas")
        if viewModel.userLocation != nil {
            return "\(count) \(noun) · " + String(localized: "ordenadas por distancia")
        }
        return "\(count) \(noun)"
    }
    
    // MARK: - Sin canchas cerca (p. ej. usuarios fuera de Ecuador)
    
    private var noFieldsHereView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24).fill(Color.secondaryColorBlack)
                    Image(systemName: "sportscourt")
                        .font(.system(size: 40, weight: .light))
                        .foregroundStyle(Color.primaryColorGreen)
                }
                .frame(width: 88, height: 88)
                .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Aún no tenemos canchas en tu zona")
                        .font(.system(size: 28, weight: .heavy))
                    Text("Estamos empezando por Quito y sus valles. Mientras llegamos a tu ciudad, puedes ver las canchas de Quito.")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.brandTextSecondary)
                }
                
                VStack(spacing: 10) {
                    Button("Ver canchas en Quito") {
                        Task { await viewModel.loadData(near: PlayerGetNearbyEstablishmentsViewModel.quitoCoordinate, cityName: "Quito") }
                    }
                    .buttonStyle(BrandPrimaryButtonStyle())
                    
                    Button("Buscar de nuevo") {
                        Task { await reloadEstablishments() }
                    }
                    .buttonStyle(BrandSecondaryButtonStyle())
                }
            }
            .padding(24)
        }
        .background(Color.brandBackground)
    }
    
    @MainActor
    private func reloadEstablishments() async {
        do {
            await viewModel.loadData()
            
            // Reinicia la vista
            shownItems = []
            didLoad = true
            
            // Carga animada de ítems con pequeño delay para UX
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3 segundos
            for establishment in viewModel.filterEstablishments {
                shownItems.insert(establishment.id)
            }
            
        } catch {
            print("Error al recargar establecimientos: \(error.localizedDescription)")
        }
    }
}

#Preview {
    PlayerView(viewModel: PlayerGetNearbyEstablishmentsViewModel())
        .environment(AppState())
}
