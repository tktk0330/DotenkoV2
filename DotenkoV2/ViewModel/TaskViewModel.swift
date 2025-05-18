import Foundation
import RealmSwift

class TaskViewModel: ObservableObject {
    private let repository = TaskRepository()
    @Published var tasks: [Task] = []
    
    init() {
        loadTasks()
    }
    
    func loadTasks() {
        if let results = repository.getAllTasks() {
            tasks = Array(results)
        }
    }
    
    func addTask(title: String, detail: String = "") {
        if let _ = repository.createTask(title: title, detail: detail) {
            loadTasks()
        }
    }
    
    func toggleTaskCompletion(task: Task) {
        if repository.updateTask(task: task, isCompleted: !task.isCompleted) {
            loadTasks()
        }
    }
    
    func updateTask(task: Task, title: String, detail: String) {
        if repository.updateTask(task: task, title: title, detail: detail) {
            loadTasks()
        }
    }
    
    func deleteTask(task: Task) {
        if repository.deleteTask(task: task) {
            loadTasks()
        }
    }
    
    func getCompletedTasks() -> [Task] {
        if let results = repository.getCompletedTasks() {
            return Array(results)
        }
        return []
    }
    
    func getIncompleteTasks() -> [Task] {
        if let results = repository.getIncompleteTasks() {
            return Array(results)
        }
        return []
    }
} 