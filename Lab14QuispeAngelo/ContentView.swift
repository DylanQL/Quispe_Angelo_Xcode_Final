//
//  ContentView.swift
//  Lab14QuispeAngelo
//
//  Created by Mac10 on 24/06/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLogin = true
    @State private var message = ""
    @State private var isLoggedIn = false
    @State private var showForgotPassword = false

    var body: some View {
        Group {
            if isLoggedIn {
                HomeView(isLoggedIn: $isLoggedIn)
            } else {
                loginView
            }
        }
        .onAppear {
            // Verificar si el usuario ya está autenticado
            if Auth.auth().currentUser != nil {
                isLoggedIn = true
            }
        }
    }
    
    var loginView: some View {
        VStack(spacing: 20) {
            Text(isLogin ? "Iniciar Sesión" : "Registrarse")
                .font(.title)

            TextField("Correo electrónico", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            if !showForgotPassword {
                SecureField("Contraseña", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            if showForgotPassword {
                Button(action: {
                    resetPassword()
                }) {
                    Text("Enviar enlace de recuperación")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    showForgotPassword = false
                    message = ""
                }) {
                    Text("Cancelar")
                        .font(.footnote)
                }
            } else {
                Button(action: {
                    if isLogin {
                        login()
                    } else {
                        register()
                    }
                }) {
                    Text(isLogin ? "Ingresar" : "Registrar")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                if isLogin {
                    Button(action: {
                        showForgotPassword = true
                        message = ""
                    }) {
                        Text("¿Olvidaste tu contraseña?")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }

                Button(action: {
                    isLogin.toggle()
                    showForgotPassword = false
                    message = ""
                }) {
                    Text(isLogin ? "¿No tienes cuenta? Regístrate" : "¿Ya tienes cuenta? Inicia sesión")
                        .font(.footnote)
                }
            }

            Text(message)
                .foregroundColor(message.contains("✅") ? .green : .red)
                .padding()
        }
        .padding()
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                message = "❌ Error: \(error.localizedDescription)"
            } else {
                message = "✅ ¡Bienvenido!"
                isLoggedIn = true
            }
        }
    }

    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                message = "❌ Error: \(error.localizedDescription)"
            } else {
                message = "✅ Registro exitoso. ¡Ahora inicia sesión!"
                isLogin = true
            }
        }
    }
    
    func resetPassword() {
        guard !email.isEmpty else {
            message = "❌ Por favor ingresa tu correo electrónico"
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                message = "❌ Error: \(error.localizedDescription)"
            } else {
                message = "✅ Se ha enviado un enlace de recuperación a tu correo"
                showForgotPassword = false
            }
        }
    }
}

#Preview {
    ContentView()
}
