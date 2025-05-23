/**
 * UserProfile
 * 
 * ユーザープロフィール情報を表すRealmモデル
 * ローカルデータベースにユーザー情報を永続化するために使用
 * パラメータの先頭はRealmを表すrmをつける
 */

import Foundation
import RealmSwift

/// ユーザープロフィール情報を表すRealmモデル
class UserProfile: Object {
    /// プライマリーキー
    @Persisted(primaryKey: true) var id: ObjectId
    
    /// ユーザー名
    @Persisted var rmUserName: String = ""
    
    /// プロフィール画像のURL
    @Persisted var rmIconUrl: String = ""
    
    /// 最終更新日時
    @Persisted var rmUpdatedAt: Date = Date()
    
    /// プロフィール画像のURL
    @Persisted var rmRoundCount: String = "1"
    
    @Persisted var rmJokerCount: String = "2"
    
    @Persisted var rmGameRate: String = "10"
    
    @Persisted var rmMaxScore: String = "1000"
    
    @Persisted var rmUpRate: String = "3"
    
    @Persisted var rmDeckCycle: String = "5"
    
    // TODO: SEなどの設定
    
    /// イニシャライザ
    /// - Parameter rmUserName: ユーザー名
    convenience init(rmUserName: String) {
        self.init()
        self.rmUserName = rmUserName
        self.rmUpdatedAt = Date()
    }
} 
