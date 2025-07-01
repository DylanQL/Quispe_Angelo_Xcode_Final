//
//  TaskModel.swift
//  Lab14QuispeAngelo
//
//  Created by Mac10 on 24/06/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Task Model
struct Task: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var isCompleted: Bool
    var createdAt: Timestamp
    var userId: String
    
    init(title: String, description: String, isCompleted: Bool = false, userId: String) {
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = Timestamp()
        self.userId = userId
    }
}

// MARK: - Task Service
class TaskService: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    private let collection = "tasks"
    
    // MARK: - Fetch Tasks
    func fetchTasks(for userId: String) {
        isLoading = true
        errorMessage = ""
        
        db.collection(collection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = "Error al cargar tareas: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "No se encontraron documentos"
                        return
                    }
                    
                    do {
                        self?.tasks = try documents.compactMap { document in
                            try document.data(as: Task.self)
                        }
                    } catch {
                        self?.errorMessage = "Error al decodificar tareas: \(error.localizedDescription)"
                    }
                }
            }
    }
    
    // MARK: - Add Task
    func addTask(_ task: Task) {
        do {
            try db.collection(collection).addDocument(from: task) { [weak self] error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Error al agregar tarea: \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            errorMessage = "Error al codificar tarea: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Update Task
    func updateTask(_ task: Task) {
        guard let taskId = task.id else { return }
        
        do {
            try db.collection(collection).document(taskId).setData(from: task) { [weak self] error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Error al actualizar tarea: \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            errorMessage = "Error al codificar tarea: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Delete Task
    func deleteTask(_ task: Task) {
        guard let taskId = task.id else { return }
        
        db.collection(collection).document(taskId).delete { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error al eliminar tarea: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Toggle Task Completion
    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updateTask(updatedTask)
    }
}
