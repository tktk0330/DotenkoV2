/**
 * UserProfile
 * 
 * ユーザープロフィール情報を表すRealmモデル
 * ローカルデータベースにユーザー情報を永続化するために使用
 */

import Foundation
import RealmSwift

/// ユーザープロフィール情報を表すRealmモデル
class UserProfile: Object {
    /// プライマリーキー
    @Persisted(primaryKey: true) var id: ObjectId
    
    /// ユーザー名
    @Persisted var username: String = ""
    
    /// 作成日時
    @Persisted var createdAt: Date = Date()
    
    /// 最終更新日時
    @Persisted var updatedAt: Date = Date()
    
    /// イニシャライザ
    /// - Parameter username: ユーザー名
    convenience init(username: String) {
        self.init()
        self.username = username
        self.createdAt = Date()
        self.updatedAt = Date()
    }
} 