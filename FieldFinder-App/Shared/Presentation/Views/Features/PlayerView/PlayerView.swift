import SwiftUI
import CoreLocation


struct PlayerView: View {
    @State private var searchText = ""
    @State private var didLoad = false
    
    @State var viewModel: PlayerGetNearbyEstablishmentsViewModel
    @State private var shownItems: Set<String> = []
    
    let columns = [GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.status {
                case .idle, .loading:
                    LoadingProgressView()
                    
                case .success:
                    if viewModel.filterEstablishments.isEmpty {
                        ContentUnavailableView {
                            Label("No hay establecimientos cerca de ti", systemImage: "mappin.slash.circle.fill")
                                .foregroundStyle(.primaryColorGreen)
                        } description: {
                            Text("Intenta buscar en otra ubicación o actualiza la búsqueda.")
                        } actions: {
                            CustomButtonView(title: "Intentar de nuevo", color: .primaryColorGreen, textColor: .white) {
                                Task {
                                    await reloadEstablishments()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                
                                Text("Todos")
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                                    .padding(.top)
                                
                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(viewModel.filterEstablishments) { establishment in
                                        NavigationLink {
                                            EstablishmentDetailView(establishmentID: establishment.id)
                                        } label: {
                                            PlayerEstablishmentGridItemView(establishment: establishment, viewModel: viewModel)
                                        }
                                    }
                                }
                                .padding(.bottom)
                            }
                        }
                        .refreshable {
                            do {
                                await viewModel.loadData()
                                try await viewModel.getFavoritesUser()
                                shownItems = []
                                for establishment in viewModel.filterEstablishments {
                                    shownItems.insert(establishment.id)
                                }
                            } catch {
                                print("Error al refrescar: \(error)")
                            }
                        }
                        .scrollIndicators(.hidden)
                        .background(Color(UIColor.systemGroupedBackground))
                    }
                    
                case .error(let message):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.primaryColorGreen)
                        Text(viewModel.showOpenSettings ? "Permiso de ubicación denegado." : "Ha ocurrido un error inesperado.")
                            .font(.headline)
                        Text(message)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        CustomButtonView(title: "Intentar de nuevo", color: .primaryColorGreen, textColor: .white) {
                            Task {
                                await reloadEstablishments()
                            }
                        }
                        if viewModel.showOpenSettings {
                            CustomButtonView(title: "Ir a Ajustes", color: .primaryColorGreen, textColor: .white) {
                                viewModel.openAppSettings()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Establecimientos")
            .searchable(text: $viewModel.establishmentSearch)
//            .task {
//                await reloadEstablishments()
//            }
        }
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
}
