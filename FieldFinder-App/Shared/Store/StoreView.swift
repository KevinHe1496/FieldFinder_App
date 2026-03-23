//
//  StoreView.swift
//  TiltFinder
//
//  Created by Kevin Heredia on [fecha]
//

import StoreKit
import SwiftUI

struct StoreView: View {
    
    enum LoadState {
        case loading, loaded, error
    }
    
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var loadState = LoadState.loading
    @State private var showingPurchaseError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack {
                    Image(decorative: "unlock")
                        .resizable()
                        .scaledToFit()
                    
                    Text("¡Actualiza hoy!")
                        .font(.title.bold())
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                    
                    Text("Aprovecha al máximo nuestra app")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(.blue.gradient)
                
                ScrollView {
                    VStack(spacing: 20) {
                        switch loadState {
                        case .loading:
                            Text("Obteniendo ofertas...")
                                .font(.title2.bold())
                                .padding(.top, 50)

                            ProgressView()
                                .controlSize(.large)

                        case .loaded:
                            ForEach(appState.products) { product in
                                VStack(alignment: .center, spacing: 12) {
                                    Text(product.displayName)
                                        .font(.title2.bold())

                                    Text("Agrega y gestiona sin límites todas tus canchas y establecimientos.")
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        
                                    Divider()
                                    
                                    Text("Empieza con un mes de prueba gratis.")
                                        .font(.subheadline.bold())
                                    
                                    Text("Suscripción mensual con renovación automática.")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)


                                    Button {
                                        purchase(product)
                                    } label: {
                                        HStack {
                                            Spacer()
                                            Text(String(format: NSLocalizedString("store_subscribe_button", comment: "Botón de suscripción con precio"), product.displayPrice))
                                                .font(.headline)
                                                .padding()
                                            Spacer()
                                        }
                                        .background(.blue)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(.plain)

                                    Divider()

                                    HStack(spacing: 4) {
                                        Link("Términos de uso", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                        Text("y")
                                            .font(.footnote)
                                            .foregroundStyle(Color.gray)
                                        Link("Política de privacidad", destination: URL(string: "https://kevinhe1496.github.io/fieldfinder-legal/privacy.html")!)
                                    }
                                    .font(.footnote)
                                    .foregroundStyle(.blue)

                                }
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            }

                        case .error:
                            Text("Lo sentimos, hubo un error cargando nuestra tienda.")
                                .padding(.top, 50)

                            Button("Intentar de nuevo") {
                                Task {
                                    await load()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }

                Button("Restaurar compras", action: restore)
                
                Button("Cancelar", role: .cancel) {
                    dismiss()
                }
                .padding(.top, 20)
            }
        }
        .alert("Las compras dentro de la app están deshabilitadas" , isPresented: $showingPurchaseError) {
        } message: {
            Text("""
                No puedes comprar el desbloqueo Premium porque las compras dentro de la app están deshabilitadas en este dispositivo. 
                Por favor, consulta con quien administre tu dispositivo para obtener asistencia.
                """)
        }
        .onChange(of: appState.fullVersionUnlocked) { _, _ in
            checkForPurchase()
        }
        .task {
            await load()
        }
    }
    
    func checkForPurchase() {
        if appState.fullVersionUnlocked {
            dismiss()
        }
    }
    
    func purchase(_ product: Product) {
        guard AppStore.canMakePayments else {
            showingPurchaseError.toggle()
            return
        }
        
        Task { @MainActor in
            try await appState.purchase(product)
            checkForPurchase()
        }
    }
    
    func load() async {
        loadState = .loading
        do {
            try await appState.loadProducts()
            
            if appState.products.isEmpty {
                loadState = .error
            } else {
                loadState = .loaded
            }
        } catch {
            loadState = .error
            print("Failed to load products: \(error.localizedDescription)")
        }
    }
    
    func restore() {
        Task {
            try await AppStore.sync()
        }
    }
}

#Preview {
    StoreView()
        .environment(AppState())
}
