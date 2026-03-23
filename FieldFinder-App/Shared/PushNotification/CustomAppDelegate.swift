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

           // Pedir permisos (async) y registrar APNs si procede
           Task { await requestAuthorizationForPushNotificacion(application: application) }
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

       private func requestAuthorizationForPushNotificacion(application: UIApplication) async {
           do {
               let granted = try await UNUserNotificationCenter.current()
                   .requestAuthorization(options: [.alert, .badge, .sound])

               print(granted ? "✅ Permiso concedido" : "❌ Permiso denegado")

               if granted {
                   // Importante: en el main thread
                   await MainActor.run {
                       application.registerForRemoteNotifications()
                   }
               }
           } catch {
               print("❌ Error solicitando notificaciones: \(error)")
           }
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

//extension CustomAppDelegate: UNUserNotificationCenterDelegate {
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
//        print("Notification title", response.notification.request.content.title)
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
//        return [.badge, .banner, .list, .sound]
//    }
//}
