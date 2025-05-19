/**
 * UserProfileRepository
 * 
 * ユーザープロフィール情報の永続化と管理を行うリポジトリクラス
 * Realmデータベースを使用してユーザー情報を保存・取得する
 */

import Foundation
import RealmSwift

/// ユーザープロフィール情報を管理するリポジトリクラス
class UserProfileRepository {
    /// Realmインスタンス
    private let realm: Realm?
    
    /// イニシャライザ
    /// RealmManagerからRealmインスタンスを取得して初期化
    init() {
        self.realm = RealmManager.shared.getRealm()
    }
    
    /// ユーザープロフィールの取得（存在しない場合は新規作成）
    /// - Returns: 既存のプロフィール、または新規作成したプロフィール。エラー時はnil
    func getOrCreateProfile() -> UserProfile? {
        guard let realm = realm else { return nil }
        
        // 既存のプロフィールを取得
        if let existingProfile = realm.objects(UserProfile.self).first {
            return existingProfile
        }
        
        // 新規プロフィールを作成
        let newProfile = UserProfile(username: "名無しさん")
        do {
            try realm.write {
                realm.add(newProfile)
            }
            return newProfile
        } catch {
            print("プロフィール作成エラー: \(error)")
            return nil
        }
    }
    
    /// ユーザー名を更新する
    /// - Parameter newUsername: 新しいユーザー名
    /// - Returns: 更新が成功した場合はtrue、失敗した場合はfalse
    func updateUsername(_ newUsername: String) -> Bool {
        guard let realm = realm,
              let profile = realm.objects(UserProfile.self).first else {
            return false
        }
        
        do {
            try realm.write {
                profile.username = newUsername
                profile.updatedAt = Date()
            }
            return true
        } catch {
            print("ユーザー名更新エラー: \(error)")
            return false
        }
    }
} 