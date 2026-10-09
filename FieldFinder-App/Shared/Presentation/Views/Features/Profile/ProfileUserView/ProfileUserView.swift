import SwiftUI

struct ProfileUserView: View {
    @Environment(AppState.self) var appState

    @State var viewModel = ProfileUserViewModel()
    @State private var favoritesViewModel = PlayerGetNearbyEstablishmentsViewModel()
    @State private var showDeleteUserAlert = false
    @State private var showDeleteErrorAlert = false

    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.status {
                case .idle, .loading:
                    LoadingProgressView()

                case .success(let user):
                    List {
                        Section {
                            HStack(spacing: 16) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundStyle(.primaryColorGreen)

                                VStack(alignment: .leading) {
                                    Text(user.name)
                                        .font(.title3)
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }

                        Section {
                            NavigationLink("Editar perfil") {
                                EditProfileView(currentName: user.name)
                            }
                            NavigationLink("Condiciones de uso") {
                                TermsAndConditionsView()
                            }

                            HStack {
                                Text("Versión de la app")
                                Spacer()
                                Text(appVersion)
                                    .foregroundStyle(.gray)
                            }
                        }

                        Section {
                            NavigationLink {
                                FavoritesView(viewModel: favoritesViewModel)
                            } label: {
                                Text("Mis favoritos")
                                    .foregroundStyle(.primaryColorGreen)
                            }
                            NavigationLink {
                                MyClaimsView()
                            } label: {
                                Text("Mis solicitudes")
                                    .foregroundStyle(.primaryColorGreen)
                            }
                        }

                        Section {
                            Button(role: .destructive) {
                                appState.closeSessionUser()
                            } label: {
                                Text("Cerrar sesión")
                            }
                        }

                        Section {
                            Button {
                                showDeleteUserAlert = true
                            } label: {
                                Text("Borrar cuenta")
                            }
                        }
                    }
                    .padding(.top, 4)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGroupedBackground))
                    .navigationTitle("Perfil")

                case .error(let message):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.primaryColorGreen)
                        Text("Error al cargar el perfil.")
                            .font(.headline)
                        Text(message)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
            }
            .onAppear {
                Task {
                    try await viewModel.getMe()
                }
            }
        }
        .alert("No pudimos eliminar tu cuenta", isPresented: $showDeleteErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Revisa tu conexión e inténtalo de nuevo.")
        }
        .alert("Borrar mi cuenta", isPresented: $showDeleteUserAlert) {
            Button("Eliminar", role: .destructive) {
                Task {
                    // Volver al inicio solo cuando el borrado terminó.
                    do {
                        try await viewModel.delete()
                        appState.closeSessionUser()
                    } catch {
                        showDeleteErrorAlert = true
                    }
                }
            }

            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("¿Seguro que quieres eliminar tu cuenta? Esta acción no se puede deshacer.")
        }
    }
}

#Preview {
    ProfileUserView()
        .environment(AppState())
}
