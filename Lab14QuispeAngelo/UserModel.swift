//
//  UserModel.swift
//  Lab14QuispeAngelo
//
//  Created by Mac10 on 24/06/25.
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
    let phone: String
    let website: String
    let company: Company
}

// MARK: - Address
struct Address: Codable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: Geo
}

// MARK: - Geo
struct Geo: Codable {
    let lat: String
    let lng: String
}

// MARK: - Company
struct Company: Codable {
    let name: String
    let catchPhrase: String
    let bs: String
}

// MARK: - API Service
class APIService: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let baseURL = "https://jsonplaceholder.typicode.com/users"
    
    func fetchUsers() {
        guard let url = URL(string: baseURL) else {
            errorMessage = "URL inválida"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Error de red: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No se recibieron datos"
                    return
                }
                
                do {
                    let users = try JSONDecoder().decode([User].self, from: data)
                    self?.users = users
                } catch {
                    self?.errorMessage = "Error al decodificar datos: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
