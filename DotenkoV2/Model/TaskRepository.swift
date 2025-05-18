import Foundation
import RealmSwift

class TaskRepository {
    private let realm: Realm?
    
    init() {
        self.realm = RealmManager.shared.getRealm()
    }
    
    // タスクの作成
    func createTask(title: String, detail: String = "") -> Task? {
        guard let realm = realm else { return nil }
        
        let task = Task(title: title, detail: detail)
        
        do {
            try realm.write {
                realm.add(task)
            }
            return task
        } catch {
            print("タスク作成エラー: \(error)")
            return nil
        }
    }
    
    // 全タスクの取得
    func getAllTasks() -> Results<Task>? {
        return realm?.objects(Task.self).sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    // タスクの更新
    func updateTask(task: Task, title: String? = nil, detail: String? = nil, isCompleted: Bool? = nil) -> Bool {
        guard let realm = realm else { return false }
        
        do {
            try realm.write {
                if let title = title {
                    task.title = title
                }
                if let detail = detail {
                    task.detail = detail
                }
                if let isCompleted = isCompleted {
                    task.isCompleted = isCompleted
                }
            }
            return true
        } catch {
            print("タスク更新エラー: \(error)")
            return false
        }
    }
    
    // タスクの削除
    func deleteTask(task: Task) -> Bool {
        guard let realm = realm else { return false }
        
        do {
            try realm.write {
                realm.delete(task)
            }
            return true
        } catch {
            print("タスク削除エラー: \(error)")
            return false
        }
    }
    
    // 完了済みタスクの取得
    func getCompletedTasks() -> Results<Task>? {
        return realm?.objects(Task.self)
            .filter("isCompleted == true")
            .sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    // 未完了タスクの取得
    func getIncompleteTasks() -> Results<Task>? {
        return realm?.objects(Task.self)
            .filter("isCompleted == false")
            .sorted(byKeyPath: "createdAt", ascending: false)
    }
} 