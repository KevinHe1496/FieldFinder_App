//
//  CustomAppDelegate.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 15/8/25.
//


import SwiftUI
import Firebase
import FirebaseMessaging

class CustomAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
           FirebaseApp.configure()

           // Delegados
           UNUserNotificationCenter.current().delegate = self
           Messaging.messaging().delegate = self

           // No pedimos permiso al abrir la app: se pide en un momento con sentido
           // (p. ej. al enviar un reclamo, ver PushPermission). Si ya lo dio antes,
           // solo volvemos a registrar el dispositivo en APNs.
           Task { await PushPermission.registerIfAlreadyAuthorized() }
           return true
       }

       // Mostrar notificación en foreground
       func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   willPresent notification: UNNotification,
                                   withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
           completionHandler([.banner, .sound, .badge])
       }

       // Tocar la notificación / acciones
       func userNotificationCenter(_ center: UNUserNotificationCenter,
                                   didReceive response: UNNotificationResponse) async {
           // Navegación según payload si quieres (response.notification.request.content.userInfo)
       }

       // APNs OK → enlazar con FCM
       func application(_ application: UIApplication,
                        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           Messaging.messaging().apnsToken = deviceToken
       }

       // APNs error
       func application(_ application: UIApplication,
                        didFailToRegisterForRemoteNotificationsWithError error: Error) {
           print("❌ No se pudo registrar en APNs: \(error)")
       }

       // FCM token (envíalo a tu backend si lo necesitas)
       func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
           print("📬 FCM token: \(fcmToken ?? "nil")")
       }
}

/// Pide permiso de notificaciones solo cuando el usuario entiende para qué sirve.
enum PushPermission {
    /// Muestra el diálogo del sistema si el usuario aún no decidió; si acepta, registra APNs.
    static func requestIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                await MainActor.run { UIApplication.shared.registerForRemoteNotifications() }
            }
        } catch {
            print("❌ Error solicitando notificaciones: \(error)")
        }
    }

    /// Al abrir la app: si ya había dado permiso, registra el dispositivo sin preguntar.
    static func registerIfAlreadyAuthorized() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            await MainActor.run { UIApplication.shared.registerForRemoteNotifications() }
        default:
            break
        }
    }
}

//extension CustomAppDelegate: UNUserNotificationCenterDelegate {
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
//        print("Notification title", response.notification.request.content.title)
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
//        return [.badge, .banner, .list, .sound]
//    }
//}
