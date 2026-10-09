//
//  BrandComponents.swift
//  FieldFinder-App
//
//  Piezas visuales del rediseño (verde + negro): botones, etiquetas, chips y la tarjeta de cancha.
//

import SwiftUI
import CoreLocation

// MARK: - Botones

/// Botón principal: fondo verde de marca con texto negro (el blanco sobre #67AE6E no tiene contraste suficiente).
struct BrandPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(Color.secondaryColorBlack)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Color.primaryColorGreen, in: RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

/// Botón secundario: borde oscuro, fondo de tarjeta.
struct BrandSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Color.brandInk)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Color.brandCard, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.brandInk, lineWidth: 1.5))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// Botón cuadrado de solo ícono (llamar, compartir).
struct BrandIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(Color.brandInk)
            .frame(width: 52, height: 52)
            .background(Color.brandCard, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.brandInk, lineWidth: 1.5))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

// MARK: - Etiquetas

struct BrandTag: View {
    enum Style { case neutral, verified, warning }

    let text: String
    var style: Style = .neutral
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 10, weight: .bold))
            }
            Text(text)
        }
        .font(.system(size: 12, weight: style == .neutral ? .regular : .semibold))
        .foregroundStyle(foreground)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(background, in: RoundedRectangle(cornerRadius: 6))
    }

    private var foreground: Color {
        switch style {
        case .neutral: return .brandInk
        case .verified: return .brandDeepGreen
        case .warning: return .brandWarningText
        }
    }

    private var background: Color {
        switch style {
        case .neutral: return .brandBackground
        case .verified: return .brandGreenTint
        case .warning: return .brandWarningTint
        }
    }
}

// MARK: - Chips de filtro

struct BrandFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.brandDeepGreen : Color.brandInk)
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background(isSelected ? Color.brandGreenTint : Color.brandCard, in: Capsule())
                .overlay(Capsule().stroke(isSelected ? Color.primaryColorGreen : Color.brandBorder,
                                          lineWidth: isSelected ? 1.5 : 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Tarjeta compacta de cancha

struct EstablishmentCardRow: View {
    let establishment: EstablishmentResponse
    let userLocation: CLLocationCoordinate2D?
    var showFavorite: Bool = false
    var isFavorite: Bool = false
    var onFavoriteTap: () -> Void = {}

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 8) {
                    Text(establishment.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.brandInk)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    if showFavorite {
                        Button(action: onFavoriteTap) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 18))
                                .foregroundStyle(isFavorite ? Color.red : Color.brandTextSecondary)
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isFavorite ? Text("Quitar de favoritos") : Text("Guardar en favoritos"))
                    }
                }

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.brandTextSecondary)
                    .lineLimit(1)

                if establishment.hasOwner {
                    if !establishment.fieldTags.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(establishment.fieldTags, id: \.self) { tag in
                                BrandTag(text: tag)
                            }
                        }
                        .padding(.top, 2)
                    }
                } else {
                    BrandTag(text: String(localized: "Sin verificar"), style: .warning)
                        .padding(.top, 2)
                }

                Spacer(minLength: 0)

                if let price = establishment.minPriceText {
                    (Text("Desde \(price)").font(.system(size: 15, weight: .bold))
                     + Text("/hora").font(.system(size: 15)).foregroundColor(Color.brandTextSecondary))
                        .foregroundStyle(Color.brandInk)
                } else {
                    Text("Precio no publicado")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.brandTextSecondary)
                }
            }
            .frame(minHeight: 96, alignment: .top)
        }
        .padding(10)
        .background(Color.brandCard, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.brandBorder, lineWidth: 1))
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }

    private var subtitle: String {
        if let distance = establishment.distanceText(from: userLocation) {
            return "\(distance) · \(establishment.shortAddress)"
        }
        return establishment.shortAddress
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let url = establishment.photoEstablishment.first {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            Color.brandBackground
            Image(systemName: "sportscourt")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(Color.brandTextSecondary)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        EstablishmentCardRow(establishment: .sample, userLocation: nil, showFavorite: true)
        HStack {
            BrandFilterChip(title: "Sintética", isSelected: true) {}
            BrandFilterChip(title: "Cubierta", isSelected: false) {}
        }
        Button("Reservar por WhatsApp") {}.buttonStyle(BrandPrimaryButtonStyle())
    }
    .padding()
    .background(Color.brandBackground)
}

// MARK: - Formularios
//
// Patrón único para todos los formularios de la app:
// etiqueta arriba, caja blanca con borde gris (verde al escribir), secciones en tarjetas.

/// Etiqueta que va encima de cada campo.
struct BrandFieldLabel: View {
    let title: LocalizedStringKey
    var onDark: Bool = false

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(onDark ? Color.white.opacity(0.85) : Color.brandInk)
    }
}

/// Caja común de los campos: fondo de tarjeta, borde gris y borde verde cuando está activo.
private struct BrandFieldBox: ViewModifier {
    let isFocused: Bool

    func body(content: Content) -> some View {
        content
            .font(.system(size: 16))
            .foregroundStyle(Color.brandInk)
            .tint(Color.brandDeepGreen)
            .padding(.horizontal, 14)
            .frame(minHeight: 52)
            .background(Color.brandCard, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isFocused ? Color.primaryColorGreen : Color.brandBorder,
                            lineWidth: isFocused ? 2 : 1)
            )
    }
}

/// Campo de texto con etiqueta. `axis: .vertical` lo vuelve de varias líneas.
struct BrandTextField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    var placeholder: LocalizedStringKey = ""
    var keyboard: UIKeyboardType = .default
    var axis: Axis = .horizontal
    var hint: LocalizedStringKey? = nil
    var onDark: Bool = false
    /// Para pasar al siguiente campo con el botón del teclado; si no se da, usa uno interno.
    var focus: FocusState<Bool>.Binding? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            BrandFieldLabel(title: title, onDark: onDark)
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.brandTextSecondary), axis: axis)
                .keyboardType(keyboard)
                .lineLimit(axis == .vertical ? 3...6 : 1...1)
                .padding(.vertical, axis == .vertical ? 14 : 0)
                .focused(focus ?? $isFocused)
                .modifier(BrandFieldBox(isFocused: focus?.wrappedValue ?? isFocused))
                .accessibilityLabel(Text(title))
            if let hint {
                Text(hint)
                    .font(.system(size: 13))
                    .foregroundStyle(onDark ? Color.white.opacity(0.6) : Color.brandTextSecondary)
            }
        }
    }
}

/// Contraseña con etiqueta y botón para mostrarla.
struct BrandSecureField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    var placeholder: LocalizedStringKey = ""
    var onDark: Bool = false
    var focus: FocusState<Bool>.Binding? = nil

    @State private var isVisible = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            BrandFieldLabel(title: title, onDark: onDark)
            HStack(spacing: 8) {
                Group {
                    if isVisible {
                        TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.brandTextSecondary))
                    } else {
                        SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.brandTextSecondary))
                    }
                }
                .focused(focus ?? $isFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .accessibilityLabel(Text(title))

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .foregroundStyle(Color.brandTextSecondary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isVisible ? Text("Ocultar contraseña") : Text("Mostrar contraseña"))
            }
            .modifier(BrandFieldBox(isFocused: focus?.wrappedValue ?? isFocused))
        }
    }
}

/// Precio por hora: "$" fijo y teclado numérico.
struct BrandPriceField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    var currencySymbol: String = "$"

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            BrandFieldLabel(title: title)
            HStack(spacing: 6) {
                Text(currencySymbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.brandTextSecondary)
                TextField("", text: $text, prompt: Text("35").foregroundStyle(Color.brandTextSecondary))
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .accessibilityLabel(Text(title))
                Text("por hora")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.brandTextSecondary)
            }
            .modifier(BrandFieldBox(isFocused: isFocused))
        }
    }
}

/// Elegir una opción entre pocas (tipo de césped, tamaño) con chips.
struct BrandChoiceField<Option: Hashable>: View {
    let title: LocalizedStringKey
    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            BrandFieldLabel(title: title)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        BrandFilterChip(title: label(option), isSelected: option == selection) {
                            selection = option
                        }
                    }
                }
            }
        }
    }
}

/// Interruptor con ícono, para servicios (parqueadero, duchas…) y atributos de la cancha.
struct BrandToggleRow: View {
    let title: LocalizedStringKey
    let systemImage: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.brandInk)
            } icon: {
                Image(systemName: systemImage)
                    .foregroundStyle(Color.brandDeepGreen)
            }
        }
        .tint(Color.primaryColorGreen)
        .frame(minHeight: 44)
    }
}

/// Tarjeta que agrupa campos relacionados, con título y nota opcional.
struct BrandFormSection<Content: View>: View {
    let title: LocalizedStringKey
    var footer: LocalizedStringKey? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.brandInk)
            content
            if let footer {
                Text(footer)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.brandTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brandCard, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.brandBorder, lineWidth: 1))
    }
}

/// Botón principal de un formulario: verde, con spinner mientras guarda.
struct BrandSubmitButton: View {
    let title: LocalizedStringKey
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView().tint(Color.secondaryColorBlack)
            } else {
                Text(title)
            }
        }
        .buttonStyle(BrandPrimaryButtonStyle())
        .disabled(isLoading || !isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

extension Capacidad {
    /// "Fútbol 5" en vez de "5-5".
    var displayName: String {
        switch self {
        case .cinco: return String(localized: "Fútbol 5")
        case .siete: return String(localized: "Fútbol 7")
        case .nueve: return String(localized: "Fútbol 9")
        case .once: return String(localized: "Fútbol 11")
        }
    }
}
