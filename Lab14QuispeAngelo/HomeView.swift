//
//  HomeView.swift
//  Lab14QuispeAngelo
//
//  Created by Mac10 on 24/06/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @Binding var isLoggedIn: Bool
    @State private var message = ""
    @StateObject private var apiService = APIService()
    @StateObject private var taskService = TaskService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("Bienvenido")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(Auth.auth().currentUser?.email ?? "Usuario")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Navigation Buttons
                VStack(spacing: 20) {
                    NavigationLink(destination: RestAPIView(apiService: apiService)) {
                        MenuButton(
                            icon: "globe",
                            title: "REST API",
                            subtitle: "Ver usuarios de la API",
                            color: .blue
                        )
                    }
                    
                    NavigationLink(destination: ProfileView(isLoggedIn: $isLoggedIn)) {
                        MenuButton(
                            icon: "person.circle",
                            title: "Perfil",
                            subtitle: "Ver información personal",
                            color: .green
                        )
                    }
                    
                    NavigationLink(destination: TaskView(taskService: taskService)) {
                        MenuButton(
                            icon: "checklist",
                            title: "Tareas",
                            subtitle: "Gestionar mis tareas",
                            color: .orange
                        )
                    }
                    
                    Button(action: {
                        cerrarSesion()
                    }) {
                        MenuButton(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Cerrar Sesión",
                            subtitle: "Salir de la aplicación",
                            color: .red
                        )
                    }
                }
                
                Text(message)
                    .foregroundColor(message.contains("✅") ? .green : .red)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Inicio")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Cargar datos al aparecer
            apiService.fetchUsers()
            if let userId = Auth.auth().currentUser?.uid {
                taskService.fetchTasks(for: userId)
            }
        }
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

struct MenuButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(color)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    HomeView(isLoggedIn: .constant(true))
}
