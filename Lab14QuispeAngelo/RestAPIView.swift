//
//  RestAPIView.swift
//  Lab14QuispeAngelo
//
//  Created by Mac10 on 24/06/25.
//

import SwiftUI

struct RestAPIView: View {
    @ObservedObject var apiService: APIService
    
    var body: some View {
        VStack {
            if apiService.isLoading {
                LoadingView()
            } else if !apiService.errorMessage.isEmpty {
                ErrorView(message: apiService.errorMessage) {
                    apiService.fetchUsers()
                }
            } else {
                UserListView(users: apiService.users)
            }
        }
        .navigationTitle("Usuarios API")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if apiService.users.isEmpty {
                apiService.fetchUsers()
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Cargando usuarios...")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
            
            Button(action: retry) {
                Text("Reintentar")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct UserListView: View {
    let users: [User]
    
    var body: some View {
        List(users) { user in
            UserCardView(user: user)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(PlainListStyle())
        .refreshable {
            // This would need to be connected to the API service
        }
    }
}

struct UserCardView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with ID
            HStack {
                Text("Usuario #\(user.id)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
            }
            
            // Main info - Los 3 campos requeridos
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(icon: "person.fill", title: "Nombre", value: user.name, color: .blue)
                InfoRow(icon: "at", title: "Usuario", value: user.username, color: .green)
                InfoRow(icon: "envelope.fill", title: "Email", value: user.email, color: .orange)
            }
            
            // Additional info
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.gray)
                        .frame(width: 20)
                    Text(user.phone)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.gray)
                        .frame(width: 20)
                    Text(user.company.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)
                        .frame(width: 20)
                    Text("\(user.address.city), \(user.address.street)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        RestAPIView(apiService: APIService())
    }
}
