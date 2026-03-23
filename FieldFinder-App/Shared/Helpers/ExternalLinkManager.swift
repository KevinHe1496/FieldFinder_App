//
//  ExternalLinkManager.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 21/5/25.
//

import Foundation
import UIKit

@Observable
final class ExternalLinkManager {
    var showAlert = false
    var urlToOpen: URL?
    var alertTitle: String = ""
    var alertMessage: String = ""
    
    @MainActor
    func prepareToOpen(title: String, message: String, url: URL?) {
        guard let url = url, UIApplication.shared.canOpenURL(url) else { return }
        self.urlToOpen = url
        self.alertTitle = NSLocalizedString(title, comment: "")
        self.alertMessage = NSLocalizedString(message, comment: "")
        self.showAlert = true
    }
    
    @MainActor
    func openURL() {
        guard let url = urlToOpen else { return }
        UIApplication.shared.open(url)
    }
}
