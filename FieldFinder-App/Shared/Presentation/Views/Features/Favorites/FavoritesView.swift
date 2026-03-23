import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: PlayerGetNearbyEstablishmentsViewModel
    @State private var shownItems: Set<String> = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                switch viewModel.statusFavorites {
                case .idle, .loading:
                    LoadingProgressView()
                    
                case .success(let favoritos):
                    if favoritos.isEmpty {
                        ContentUnavailableView {
                            Label("No tienes favoritos", systemImage: "star.slash.fill")
                                .foregroundStyle(.primaryColorGreen)
                        } description: {
                            Text("Aún no has agregado establecimientos a tu lista de favoritos. Empieza a descubrir lugares y guárdalos aquí.")
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                Text("Mis Favoritos")
                                    .font(.title2.bold())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.top)
                                
                                ForEach(favoritos) { establishment in
                                    NavigationLink {
                                        EstablishmentDetailView(establishmentID: establishment.id)
                                    } label: {
                                        FavoriteGridItemView(
                                            establishment: establishment,
                                            viewModel: viewModel
                                        )
                                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                                    }
                                }
                            }
                            .padding(.bottom)
                            .animation(.easeInOut, value: viewModel.favoritesData)
                        }
                        .refreshable {
                            do{
                                try await viewModel.getFavoritesUser()
                            } catch {
                                print("error: \(error)")
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                case .error(let message):
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.primaryColorGreen)
                        Text("Error al cargar los establecimientos")
                            .font(.headline)
                        Text(message)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        CustomButtonView(title: "Intentar denuevo.", color: .primaryColorGreen, textColor: .white) {
                            Task {
                                do {
                                    try await viewModel.getFavoritesUser()
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    try await viewModel.getFavoritesUser()
                }
            }
        }
    }
}

#Preview {
    FavoritesView(viewModel: PlayerGetNearbyEstablishmentsViewModel())
}
