/**
 * UserProfileRepository
 * 
 * ユーザープロフィール情報の永続化と管理を行うリポジトリクラス
 * Realmデータベースを使用してユーザー情報を保存・取得する
 */

import Foundation
import RealmSwift

/// リポジトリのエラー型
enum RepositoryError: Error {
    case realmNotInitialized
    case profileNotFound
    case updateFailed(Error)
    case creationFailed(Error)
}

/// ユーザープロフィール情報を管理するリポジトリクラス
class UserProfileRepository {
    /// Realmインスタンス
    private let realm: Realm?
    
    /// イニシャライザ
    /// RealmManagerからRealmインスタンスを取得して初期化
    init() {
        self.realm = RealmManager.shared.getRealm()
    }
    
    /// 一般的な更新処理を行うプライベートメソッド
    /// - Parameters:
    ///   - updateBlock: 更新処理を行うクロージャ
    /// - Returns: 更新結果
    private func performUpdate(_ updateBlock: @escaping (UserProfile) -> Void) -> Result<Void, RepositoryError> {
        guard let realm = realm else {
            return .failure(.realmNotInitialized)
        }
        
        guard let profile = realm.objects(UserProfile.self).first else {
            return .failure(.profileNotFound)
        }
        
        do {
            try realm.write {
                updateBlock(profile)
                profile.rmUpdatedAt = Date()
            }
            return .success(())
        } catch {
            return .failure(.updateFailed(error))
        }
    }
    
    /// ユーザープロフィールの取得（存在しない場合は新規作成）
    /// - Returns: 既存のプロフィール、または新規作成したプロフィール
    func getOrCreateProfile() -> Result<UserProfile, RepositoryError> {
        guard let realm = realm else {
            return .failure(.realmNotInitialized)
        }
        
        if let existingProfile = realm.objects(UserProfile.self).first {
            return .success(existingProfile)
        }
        
        let newProfile = UserProfile(rmUserName: "ゲスト")
        do {
            try realm.write {
                realm.add(newProfile)
            }
            return .success(newProfile)
        } catch {
            return .failure(.creationFailed(error))
        }
    }
    
    /// ユーザー名を更新する
    /// - Parameter newUsername: 新しいユーザー名
    func updateUsername(_ newUsername: String) -> Result<Void, RepositoryError> {
        return performUpdate { $0.rmUserName = newUsername }
    }
    
    /// プロフィール画像のURLを更新する
    /// - Parameter iconUrl: 新しいプロフィール画像のURL
    func updateIconUrl(_ iconUrl: String) -> Result<Void, RepositoryError> {
        return performUpdate { $0.rmIconUrl = iconUrl }
    }
    
    /// ラウンド数を更新する
    func updateRoundCount(_ roundCount: String) -> Result<Void, RepositoryError> {
        return performUpdate { $0.rmRoundCount = roundCount }
    }
    
    /// ジョーカー枚数を更新する
    func updateJokerCount(_ jokerCount: String) -> Result<Void, RepositoryError> {
        return performUpdate { $0.rmJokerCount = jokerCount }
    }
    
    /// ゲームレートを更新する
    func updateGameRate(_ gameRate: String) -> Result<Void, RepositoryError> {
        return performUpdate { $0.rmGameRate = gameRate }
    }
    
    /// 最高スコアを更新する
    func updateMaxScore(_ maxScore: String) -> Result<Void, RepositoryError> {
        return performUpdate { $0.rmMaxScore = maxScore }
    }
    
    /// アップレートを更新する
    func updateUpRate(_ upRate: String) -> Result<Void, RepositoryError> {
        return performUpdate { $0.rmUpRate = upRate }
    }
    
    /// デッキサイクルを更新する
    func updateDeckCycle(_ deckCycle: String) -> Result<Void, RepositoryError> {
        return performUpdate { $0.rmDeckCycle = deckCycle }
    }
}
