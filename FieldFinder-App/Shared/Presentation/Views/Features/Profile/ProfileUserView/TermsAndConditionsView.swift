//
//  TermsAndConditionsView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 14/5/25.
//

import SwiftUI

struct TermsAndConditionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Términos y Condiciones de Uso")
                    .font(.title2)
                    .bold()

                Text("""
                Al utilizar la aplicación FieldFinder, aceptas los siguientes términos y condiciones. Te recomendamos leerlos detenidamente.
                """)
                
                Group {
                    Text("1. Uso de la aplicación")
                        .font(.headline)
                    Text("""
                    FieldFinder es una plataforma para que los usuarios puedan encontrar establecimientos deportivos (canchas) cercanos, ver detalles como fotos, servicios disponibles, ubicación en el mapa y contactar directamente con los dueños mediante su número telefónico.
                    """)
                }

                Group {
                    Text("2. Cuentas de usuario")
                        .font(.headline)
                    Text("""
                    Los usuarios deben registrarse con información verídica. No está permitido compartir credenciales de acceso ni suplantar a otros usuarios.
                    """)
                }

                Group {
                    Text("3. Derechos de los dueños")
                        .font(.headline)
                    Text("""
                    Los dueños de canchas pueden registrar sus establecimientos, añadir información relevante y subir fotografías. Se comprometen a proporcionar información precisa y mantener actualizados los datos publicados.
                    """)
                }

                Group {
                    Text("4. Uso adecuado")
                        .font(.headline)
                    Text("""
                    No se permite el uso de FieldFinder para fines ilegales, fraudulentos o que infrinjan derechos de terceros.
                    """)
                }

                Group {
                    Text("5. Privacidad y seguridad")
                        .font(.headline)
                    Text("""
                    Respetamos tu privacidad. Los datos que proporciones se utilizarán únicamente para el correcto funcionamiento de la app. No compartiremos tu información personal sin consentimiento.
                    """)
                }

                Group {
                    Text("6. Disponibilidad del servicio")
                        .font(.headline)
                    Text("""
                    Hacemos nuestro mejor esfuerzo por mantener la app disponible, pero no garantizamos acceso ininterrumpido 24/7. Pueden presentarse mantenimientos o fallos técnicos ocasionales.
                    """)
                }

                Group {
                    Text("7. Cambios en los términos")
                        .font(.headline)
                    Text("""
                    Nos reservamos el derecho de actualizar estos términos en cualquier momento. Se notificará a los usuarios sobre cambios relevantes dentro de la aplicación.
                    """)
                }

                Text("Gracias por confiar en FieldFinder.")
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Condiciones de uso")
    }
}

#Preview {
    TermsAndConditionsView()
}
