//
//  ProfileView.swift
//  Lab14QuispeAngelo
//
//  Created by Mac10 on 24/06/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @State private var message = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)
                    
                    Text("Mi Perfil")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                // User Information Card
                VStack(spacing: 20) {
                    ProfileInfoCard()
                    
                    // Action Buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            // Aquí podrías agregar funcionalidad para editar perfil
                            message = "Función de edición próximamente..."
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Editar Perfil")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            cerrarSesion()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Cerrar Sesión")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(message.contains("✅") ? .green : .red)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func cerrarSesion() {
        do {
            try Auth.auth().signOut()
            message = "✅ Sesión cerrada exitosamente"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isLoggedIn = false
            }
        } catch let signOutError as NSError {
            message = "❌ Error al cerrar sesión: \(signOutError.localizedDescription)"
        }
    }
}

struct ProfileInfoCard: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Información del Usuario")
                .font(.headline)
                .foregroundColor(.blue)
            
            VStack(spacing: 12) {
                ProfileField(
                    icon: "envelope.fill",
                    title: "Correo Electrónico",
                    value: Auth.auth().currentUser?.email ?? "No disponible",
                    color: .blue
                )
                
                ProfileField(
                    icon: "person.fill",
                    title: "ID de Usuario",
                    value: Auth.auth().currentUser?.uid ?? "No disponible",
                    color: .green
                )
                
                ProfileField(
                    icon: "calendar",
                    title: "Cuenta Creada",
                    value: formatDate(Auth.auth().currentUser?.metadata.creationDate),
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "No disponible" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

struct ProfileField: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 25, height: 25)
                .background(color.opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(10)
    }
}

#Preview {
    NavigationView {
        ProfileView(isLoggedIn: .constant(true))
    }
}
