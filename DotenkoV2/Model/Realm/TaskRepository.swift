/**
 * TaskRepository
 * 
 * タスク情報の永続化と管理を行うリポジトリクラス
 * Realmデータベースを使用してタスクのCRUD操作を提供する
 */

import Foundation
import RealmSwift

/// タスク情報を管理するリポジトリクラス
class TaskRepository {
    /// Realmインスタンス
    private let realm: Realm?
    
    /// イニシャライザ
    /// RealmManagerからRealmインスタンスを取得して初期化
    init() {
        self.realm = RealmManager.shared.getRealm()
    }
    
    /// 新しいタスクを作成する
    /// - Parameters:
    ///   - title: タスクのタイトル
    ///   - detail: タスクの詳細（オプション）
    /// - Returns: 作成されたタスク。エラー時はnil
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
    
    /// 全てのタスクを取得する
    /// - Returns: 作成日時の降順でソートされたタスクのコレクション
    func getAllTasks() -> Results<Task>? {
        return realm?.objects(Task.self).sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    /// タスクの情報を更新する
    /// - Parameters:
    ///   - task: 更新対象のタスク
    ///   - title: 新しいタイトル（オプション）
    ///   - detail: 新しい詳細（オプション）
    ///   - isCompleted: 完了状態（オプション）
    /// - Returns: 更新が成功した場合はtrue、失敗した場合はfalse
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
    
    /// タスクを削除する
    /// - Parameter task: 削除対象のタスク
    /// - Returns: 削除が成功した場合はtrue、失敗した場合はfalse
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
    
    /// 完了済みのタスクを取得する
    /// - Returns: 作成日時の降順でソートされた完了済みタスクのコレクション
    func getCompletedTasks() -> Results<Task>? {
        return realm?.objects(Task.self)
            .filter("isCompleted == true")
            .sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    /// 未完了のタスクを取得する
    /// - Returns: 作成日時の降順でソートされた未完了タスクのコレクション
    func getIncompleteTasks() -> Results<Task>? {
        return realm?.objects(Task.self)
            .filter("isCompleted == false")
            .sorted(byKeyPath: "createdAt", ascending: false)
    }
} 