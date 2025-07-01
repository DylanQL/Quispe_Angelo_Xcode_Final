//
//  PerfilView.swift
//  Lab14QuispeAngelo
//
//  Created by Mac10 on 24/06/25.
//

import SwiftUI
import FirebaseAuth

struct PerfilView: View {
    @State private var message = ""
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Mi Perfil")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Correo electrónico:")
                    .font(.headline)
                
                Text(Auth.auth().currentUser?.email ?? "No disponible")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            
            Button(action: {
                cerrarSesion()
            }) {
                Text("Cerrar Sesión")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text(message)
                .foregroundColor(.red)
                .padding()
            
            Spacer()
        }
        .padding()
    }
    
    func cerrarSesion() {
        do {
            try Auth.auth().signOut()
            message = "✅ Sesión cerrada exitosamente"
            isLoggedIn = false
        } catch let signOutError as NSError {
            message = "❌ Error al cerrar sesión: \(signOutError.localizedDescription)"
        }
    }
}

#Preview {
    PerfilView(isLoggedIn: .constant(true))
}
