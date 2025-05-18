import Foundation
import RealmSwift

class UserProfileRepository {
    private let realm: Realm?
    
    init() {
        self.realm = RealmManager.shared.getRealm()
    }
    
    // ユーザープロフィールの取得（存在しない場合は作成）
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
    
    // ユーザー名の更新
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