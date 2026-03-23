import Foundation
import StoreKit

extension AppState {
    
    /// ID del producto de suscripción en App Store.
    static let unlockPremiumProductID = "com.ravecodesolutions.fieldfinder.suscripcionmensual"
    
    /// Indica si el usuario tiene la versión premium desbloqueada (guardado en UserDefaults).
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }
        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }
    
    /// Indica si el usuario está actualmente en periodo de prueba gratis.
    @MainActor
    var isOnFreeTrial: Bool {
        get {
            defaults.bool(forKey: "isOnFreeTrial")
        }
        set {
            defaults.set(newValue, forKey: "isOnFreeTrial")
        }
    }

    /// Observa las transacciones activas y futuras; actualiza el estado de suscripción y free trial.
    @MainActor
    func monitorTransactions() async {
        do {
            // Cargar productos si no están ya cargados
            try await loadProducts()
        } catch {
            print("❌ Error cargando productos: \(error)")
        }

        // Revisión de suscripciones activas al abrir
        for await entitlement in Transaction.currentEntitlements {
            if case let .verified(transaction) = entitlement,
               transaction.productID == Self.unlockPremiumProductID {

                fullVersionUnlocked = transaction.revocationDate == nil
                isOnFreeTrial = transaction.offer?.type == .introductory
                await transaction.finish()
            }
        }

        // Escuchar nuevas transacciones en vivo
        for await update in Transaction.updates {
            if let transaction = try? update.payloadValue {
                await finalize(transaction)
            }
        }
    }


    /// Inicia el proceso de compra y finaliza si fue exitosa.
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        if case let .success(validation) = result {
            try await finalize(validation.payloadValue)
        }
    }

    /// Marca como desbloqueado si la compra fue válida y finaliza la transacción.
    @MainActor
    func finalize(_ transaction: Transaction) async {
        if transaction.productID == Self.unlockPremiumProductID {
            fullVersionUnlocked = transaction.revocationDate == nil
            await transaction.finish()
        }
    }
    
    /// Indicamos los productos que tenemos.
    @MainActor
    func loadProducts() async throws {
        guard products.isEmpty else { return }
        try await Task.sleep(for: .seconds(0.2))
        products = try await Product.products(for: [Self.unlockPremiumProductID])
    }
}
