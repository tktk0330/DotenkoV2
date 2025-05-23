/**
 * UserProfileRepository+Extension
 * 
 * UserProfileRepositoryクラスの拡張
 * シングルトンパターンと便利なアクセサを提供
 */

import Foundation
import RealmSwift

// MARK: - Singleton
extension UserProfileRepository {
    /// シングルトンインスタンス
    static let shared = UserProfileRepository()
    
    /// 現在のプロフィール
    private var currentProfile: UserProfile? {
        switch getOrCreateProfile() {
        case .success(let profile):
            return profile
        case .failure:
            return nil
        }
    }
}

// MARK: - Convenient Accessors
extension UserProfileRepository {
    /// ユーザー名
    var userName: String {
        get { currentProfile?.userName ?? "" }
        set {
            _ = updateUsername(newValue)
        }
    }
    
    /// プロフィール画像のURL
    var iconUrl: String {
        get { currentProfile?.iconUrl ?? "" }
        set {
            _ = updateIconUrl(newValue)
        }
    }
    
    /// ラウンド数
    var roundCount: String {
        get { currentProfile?.roundCount ?? "10" }
        set {
            _ = updateRoundCount(newValue)
        }
    }
    
    /// ジョーカー枚数
    var jokerCount: String {
        get { currentProfile?.jokerCount ?? "2" }
        set {
            _ = updateJokerCount(newValue)
        }
    }
    
    /// ゲームレート
    var gameRate: String {
        get { currentProfile?.gameRate ?? "10" }
        set {
            _ = updateGameRate(newValue)
        }
    }
    
    /// 最高スコア
    var maxScore: String {
        get { currentProfile?.maxScore ?? "1000" }
        set {
            _ = updateMaxScore(newValue)
        }
    }
    
    /// アップレート
    var upRate: String {
        get { currentProfile?.upRate ?? "3" }
        set {
            _ = updateUpRate(newValue)
        }
    }
    
    /// デッキサイクル
    var deckCycle: String {
        get { currentProfile?.deckCycle ?? "5" }
        set {
            _ = updateDeckCycle(newValue)
        }
    }
    
    /// ゲームルール
    var gameRule: GameRuleModel? {
        get { currentProfile?.gameRule }
        set {
            if let newRule = newValue {
                currentProfile?.update(gameRule: newRule)
            }
        }
    }
}

// MARK: - Convenience Methods
extension UserProfileRepository {
    /// プロフィール情報を更新
    func updateProfile(userName: String? = nil, iconUrl: String? = nil) {
        if let userName = userName {
            _ = updateUsername(userName)
        }
        if let iconUrl = iconUrl {
            _ = updateIconUrl(iconUrl)
        }
    }
} 
