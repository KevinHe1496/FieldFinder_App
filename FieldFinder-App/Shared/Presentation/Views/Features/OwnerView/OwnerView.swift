//
//  OwnerView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 9/5/25.
//

import SwiftUI

enum OwnerNavigationFieldDestination: Hashable {
    case registerField
}

struct OwnerView: View {
    
    @Environment(AppState.self) var appState
    @State private var shownItems: Set<String> = []
    
    @State private var showingStore = false
    @State private var selectedNavigation: OwnerNavigationFieldDestination?
    
    let columns = [
        GridItem(.flexible())
    ]
    
    @State private var viewModel: OwnerViewModel
    
    init(appState: AppState = AppState()) {
        _viewModel = State(initialValue: OwnerViewModel(appState: appState))
    }
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color(.thirdColorWhite).ignoresSafeArea()
                ScrollView {
                    if viewModel.establishments.establecimiento.first?.canchas.isEmpty ?? true {
                        VStack {
                            
                            ContentUnavailableView("No hay canchas registradas", systemImage: "soccerball.inverse", description: Text("Agrega algunas canchas."))
                            
                        }
                        .padding(.top, 250)
                        
                    } else {
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.establishments.establecimiento) { establecimiento in
                                
                                ForEach(establecimiento.canchas) { cancha in
                                    NavigationLink {
                                        FieldDetailView(fieldId: cancha.id, userRole: viewModel.establishments.userRole, establecimientoID: establecimiento.id)
                                    } label: {
                                        FieldGridItemView(field: cancha)
                                    }
                                }
                            }
                        }
                        .padding(.top)
                        .padding(.bottom)
                    }
                }
                .navigationTitle("Mis Canchas")
                
                .task {
                    await viewModel.getEstablishments()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        for establecimiento in viewModel.establishments.establecimiento {
                            for cancha in establecimiento.canchas {
                                _ = shownItems.insert(cancha.id)
                            }
                        }
                    }
                }
                
            }
        }
    }
    private func handleAddFieldTapped() {
        if viewModel.canAddFieldandEstablishment() {
            selectedNavigation = .registerField
        } else {
            showingStore = true
        }
    }
}



#Preview {
    OwnerView(appState: AppState())
        .environment(AppState())
}
