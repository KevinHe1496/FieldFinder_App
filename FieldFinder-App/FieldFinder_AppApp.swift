//
//  FieldFinder_AppApp.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 8/5/25.
//

import SwiftUI
import TipKit

@main
struct FieldFinder_AppApp: App {
    @UIApplicationDelegateAdaptor(CustomAppDelegate.self) var delegate
    @State var appState = AppState()
    
    init() {
        try? Tips.configure()
    }
    
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .task {
                    await appState.monitorTransactions()
                }
        }
    }
}
