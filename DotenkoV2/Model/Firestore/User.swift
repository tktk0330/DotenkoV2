/**
 * User
 * 
 * Firestoreに保存されるユーザー情報を表すモデル
 * クラウドデータベースにユーザー情報を永続化するために使用
 */

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Firestoreに保存されるユーザー情報を表すモデル
struct User: Identifiable, Codable {
    /// FirestoreのドキュメントID
    @DocumentID var id: String?
    
    /// ユーザー名
    let name: String
    
    /// プロフィール画像のURL
    var iconUrl: String?
    
    /// 最終ログイン日時
    var lastLoginAt: Date
    
    /// Firestoreのフィールド名とSwiftのプロパティ名のマッピング
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconUrl = "icon_url"
        case lastLoginAt = "last_login_at"
    }
    
    /// イニシャライザ
    /// - Parameters:
    ///   - name: ユーザー名
    ///   - iconUrl: プロフィール画像のURL（オプション）
    ///   - lastLoginAt: 最終ログイン日時
    init(name: String, iconUrl: String? = nil, lastLoginAt: Date = Date()) {
        self.name = name
        self.iconUrl = iconUrl
        self.lastLoginAt = lastLoginAt
    }
} 
