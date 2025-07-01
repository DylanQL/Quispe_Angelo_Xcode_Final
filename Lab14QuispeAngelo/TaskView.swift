//
//  TaskView.swift
//  Lab14QuispeAngelo
//
//  Created by Mac10 on 24/06/25.
//

import SwiftUI
import FirebaseAuth

struct TaskView: View {
    @ObservedObject var taskService: TaskService
    @State private var showingAddTask = false
    @State private var editingTask: Task?
    
    var body: some View {
        VStack {
            if taskService.isLoading {
                TaskLoadingView()
            } else {
                TaskListView(
                    tasks: taskService.tasks,
                    onToggle: { task in
                        taskService.toggleTaskCompletion(task)
                    },
                    onEdit: { task in
                        editingTask = task
                    },
                    onDelete: { task in
                        taskService.deleteTask(task)
                    }
                )
            }
        }
        .navigationTitle("Mis Tareas")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddTask = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(taskService: taskService)
        }
        .sheet(item: $editingTask) { task in
            EditTaskView(task: task, taskService: taskService)
        }
        .onAppear {
            loadTasks()
        }
        .alert("Error", isPresented: .constant(!taskService.errorMessage.isEmpty)) {
            Button("OK") {
                taskService.errorMessage = ""
            }
        } message: {
            Text(taskService.errorMessage)
        }
    }
    
    private func loadTasks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        taskService.fetchTasks(for: userId)
    }
}

struct TaskLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Cargando tareas...")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TaskListView: View {
    let tasks: [Task]
    let onToggle: (Task) -> Void
    let onEdit: (Task) -> Void
    let onDelete: (Task) -> Void
    
    var body: some View {
        if tasks.isEmpty {
            EmptyTasksView()
        } else {
            List {
                ForEach(tasks) { task in
                    TaskRowView(
                        task: task,
                        onToggle: { onToggle(task) },
                        onEdit: { onEdit(task) },
                        onDelete: { onDelete(task) }
                    )
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No tienes tareas")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Toca el botón + para agregar tu primera tarea")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Checkbox
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Text(formatDate(task.createdAt.dateValue()))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 10) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                Label("Eliminar", systemImage: "trash")
            }
            
            Button(action: onEdit) {
                Label("Editar", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

struct AddTaskView: View {
    @ObservedObject var taskService: TaskService
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            TaskFormView(
                title: $title,
                description: $description,
                navigationTitle: "Nueva Tarea",
                primaryButtonTitle: "Agregar",
                primaryAction: addTask
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addTask() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let newTask = Task(
            title: title,
            description: description,
            userId: userId
        )
        
        taskService.addTask(newTask)
        dismiss()
    }
}

struct EditTaskView: View {
    let task: Task
    @ObservedObject var taskService: TaskService
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            TaskFormView(
                title: $title,
                description: $description,
                navigationTitle: "Editar Tarea",
                primaryButtonTitle: "Guardar",
                primaryAction: updateTask
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            title = task.title
            description = task.description
        }
    }
    
    private func updateTask() {
        var updatedTask = task
        updatedTask.title = title
        updatedTask.description = description
        
        taskService.updateTask(updatedTask)
        dismiss()
    }
}

struct TaskFormView: View {
    @Binding var title: String
    @Binding var description: String
    let navigationTitle: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void
    
    var body: some View {
        Form {
            Section(header: Text("Información de la Tarea")) {
                TextField("Título", text: $title)
                
                TextField("Descripción (opcional)", text: $description, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            Section {
                Button(action: primaryAction) {
                    Text(primaryButtonTitle)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .disabled(title.isEmpty)
                .listRowBackground(title.isEmpty ? Color.gray : Color.blue)
            }
        }
        .navigationTitle(navigationTitle)
    }
}

#Preview {
    NavigationView {
        TaskView(taskService: TaskService())
    }
}
