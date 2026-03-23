//
//  ProfileEstablishmentView.swift
//  FieldFinder-App
//
//  Created by Andy Heredia on 16/5/25.
//

import SwiftUI

struct ProfileOwnerView: View {
    
    
    @Environment(AppState.self) var appState
    
    @State var viewModel = ProfileUserViewModel()
    @State private var favoritesViewModel = PlayerGetNearbyEstablishmentsViewModel()
    @State private var showDeleteUserAlert = false
    
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
                                    if let firstEstablishment = user.establecimiento.first {
                                        Text(firstEstablishment.name)
                                            .font(.title3)
                                        Text(user.email)
                                            .font(.subheadline)
                                            .foregroundStyle(.gray)
                                    } else {
                                        Text("Aún no has registrado tu establecimiento.")
                                            .font(.headline)
                                            .foregroundStyle(.secondary)
                                    }

                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Section {
                            
                            
                                NavigationLink("Mis establecimientos") {
                                    MyEstablishmentsView(establishment: user.establecimiento)
                                }
                                
                            NavigationLink("Mis canchas") {
                                OwnerView()
                            }
                            
                            NavigationLink("Condiciones de uso") {
                                TermsAndConditionsView()
                            }
                            
                            HStack {
                                Text("Versión de al app")
                                Spacer()
                                Text(appVersion)
                                    .foregroundStyle(.gray)
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
            
            .alert("Borrar mi cuenta", isPresented: $showDeleteUserAlert) {
                Button("Eliminar", role: .destructive) {
                    Task {
                        try await viewModel.delete()
                    }
                    appState.status = .login
                }
                
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Estas seguro que quieres eliminar tu cuenta?")
            }
            .onAppear {
                Task {
                    try await viewModel.getMe()
                }
            }
        }
    }
}



#Preview {
    ProfileOwnerView()
        .environment(AppState())
}
