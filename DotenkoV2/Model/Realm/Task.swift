/**
 * Task
 * 
 * タスク情報を表すRealmモデル
 * ローカルデータベースにタスク情報を永続化するために使用
 */

import Foundation
import RealmSwift

/// タスク情報を表すRealmモデル
class Task: Object {
    /// プライマリーキー
    @Persisted(primaryKey: true) var id: ObjectId
    
    /// タスクのタイトル
    @Persisted var title: String = ""
    
    /// タスクの詳細
    @Persisted var detail: String = ""
    
    /// タスクの完了状態
    @Persisted var isCompleted: Bool = false
    
    /// 作成日時
    @Persisted var createdAt: Date = Date()
    
    /// イニシャライザ
    /// - Parameters:
    ///   - title: タスクのタイトル
    ///   - detail: タスクの詳細（オプション）
    convenience init(title: String, detail: String = "") {
        self.init()
        self.title = title
        self.detail = detail
        self.createdAt = Date()
    }
} 