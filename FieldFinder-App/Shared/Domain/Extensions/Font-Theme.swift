
import Foundation
import SwiftUI

extension Font {
    // Título principal (ej. pantallas, secciones)
    static let appTitle = Font.system(size: 22, weight: .bold, design: .default)
    
    // Descripciones o subtítulos (más pequeños que el título)
    static let appDescription = Font.system(size: 16, weight: .regular, design: .default)
    
    // Subtitulos
    static let appSubtitle = Font.system(size: 16, weight: .bold, design: .default)
    
    // Texto de placeholder (ligero y más pequeño)
    static let appPlaceholder = Font.system(size: 14, weight: .light, design: .default)
    
    // Texto para botones
    static let appButton = Font.system(size: 16, weight: .semibold, design: .default)
}
