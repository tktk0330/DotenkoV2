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
        let newProfile = UserProfile(rmUserName: "ゲスト")
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
                profile.rmUserName = newUsername
                profile.rmUpdatedAt = Date()
            }
            return true
        } catch {
            print("ユーザー名更新エラー: \(error)")
            return false
        }
    }
    
    /// プロフィール画像のURLを更新する
    /// - Parameter iconUrl: 新しいプロフィール画像のURL
    /// - Returns: 更新が成功した場合はtrue、失敗した場合はfalse
    func updateIconUrl(_ iconUrl: String) -> Bool {
        guard let realm = realm,
              let profile = realm.objects(UserProfile.self).first else {
            return false
        }
        
        do {
            try realm.write {
                profile.rmIconUrl = iconUrl
                profile.rmUpdatedAt = Date()
            }
            return true
        } catch {
            print("アイコンURL更新エラー: \(error)")
            return false
        }
    }
    
    func updateRoundCount(_ roundCount: String) -> Bool {
        guard let realm = realm,
              let profile = realm.objects(UserProfile.self).first else {
            return false
        }
        
        do {
            try realm.write {
                profile.rmRoundCount = roundCount
            }
            return true
        } catch {
            print("roundCount更新エラー: \(error)")
            return false
        }
    }
    
    func updateJokerCount(_ jokerCount: String) -> Bool {
        guard let realm = realm,
              let profile = realm.objects(UserProfile.self).first else {
            return false
        }
        
        do {
            try realm.write {
                profile.rmJokerCount = jokerCount
            }
            return true
        } catch {
            print("jokerCount更新エラー: \(error)")
            return false
        }
    }
    
    func updateGameRate(_ gameRate: String) -> Bool {
        guard let realm = realm,
              let profile = realm.objects(UserProfile.self).first else {
            return false
        }
        
        do {
            try realm.write {
                profile.rmGameRate = gameRate
            }
            return true
        } catch {
            print("gameRate更新エラー: \(error)")
            return false
        }
    }
    
    func updateMaxScore(_ maxScore: String) -> Bool {
        guard let realm = realm,
              let profile = realm.objects(UserProfile.self).first else {
            return false
        }
        
        do {
            try realm.write {
                profile.rmMaxScore = maxScore
            }
            return true
        } catch {
            print("maxScore更新エラー: \(error)")
            return false
        }
    }
    
    func updateUpRate(_ upRate: String) -> Bool {
        guard let realm = realm,
              let profile = realm.objects(UserProfile.self).first else {
            return false
        }
        
        do {
            try realm.write {
                profile.rmUpRate = upRate
            }
            return true
        } catch {
            print("upRate更新エラー: \(error)")
            return false
        }
    }
    
    func updateDeckCycle(_ deckCycle: String) -> Bool {
        guard let realm = realm,
              let profile = realm.objects(UserProfile.self).first else {
            return false
        }
        
        do {
            try realm.write {
                profile.rmDeckCycle = deckCycle
            }
            return true
        } catch {
            print("deckCycle 更新エラー: \(error)")
            return false
        }
    }
}
