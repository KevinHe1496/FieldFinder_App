import SwiftUI

enum OwnerNavigationEstablishmentDestination: Hashable {
    case registerEstablishment
}

struct MyEstablishmentsView: View {
    @Environment(AppState.self) var appState
    let establishment: [EstablishmentResponse]
    @State private var shownItems: Set<String> = []
    @State private var showingStore = false
    @State private var viewModel: OwnerViewModel
    @State private var selectedNavigation: OwnerNavigationEstablishmentDestination?
    let columns = [GridItem(.flexible())]
    
    
    init(establishment: [EstablishmentResponse], appState: AppState = AppState()) {
        self.establishment = establishment
        _viewModel = State(initialValue: OwnerViewModel(appState: appState))
    }
 
    var body: some View {
        NavigationStack {
            if establishment.isEmpty {
                VStack(spacing: 16) {
                    ContentUnavailableView(
                        "No tienes establecimientos registrados",
                        systemImage: "building.2.crop.circle",
                        description: Text("Empieza a crear un nuevo establecimiento para que tus jugadores lo encuentren fácilmente.")
                    )
                    if viewModel.canAddFieldandEstablishment() {
                        Button {
                            selectedNavigation = .registerEstablishment
                        } label: {
                            Label("Agregar Establecimiento", systemImage: "plus")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.primaryColorGreen)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(establishment) { establishment in
                            NavigationLink {
                                EstablishmentDetailOwnerView(establishmentID: establishment.id)
                            } label: {
                                PlayerEstablishmentGridItemView(establishment: establishment, viewModel: PlayerGetNearbyEstablishmentsViewModel())
                            }
                        }
                    }
                }
            }
            
            NavigationLink(
                destination: RegisterEstablishmentView(appState: appState),
                tag: .registerEstablishment,
                selection: $selectedNavigation
            ) {
                EmptyView()
            }
            .hidden()
            .sheet(isPresented: $showingStore) {
                StoreView()
            }
            .navigationTitle("Mis Establecimientos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: handleAddEstablishmentTapped) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.primaryColorGreen)
                            .accessibilityLabel("Agregar Establecimiento")
                    }
                }
            }
        }
    }
    
    private func handleAddEstablishmentTapped() {
        if viewModel.canAddFieldandEstablishment() {
            selectedNavigation = .registerEstablishment
        } else {
            showingStore = true
        }
    }
}

#Preview {
    MyEstablishmentsView(establishment: [.sample])
        .environment(AppState())
}
