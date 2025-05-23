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
        getOrCreateProfile()
    }
}

// MARK: - Convenient Accessors
extension UserProfileRepository {
    /// ユーザー名
    var userName: String {
        get { currentProfile?.userName ?? "" }
        set {
            currentProfile?.userName = newValue
        }
    }
    
    /// プロフィール画像のURL
    var iconUrl: String {
        get { currentProfile?.iconUrl ?? "" }
        set {
            currentProfile?.iconUrl = newValue
        }
    }
    
    /// ラウンド数
    var roundCount: String {
        get { currentProfile?.roundCount ?? "10" }
        set {
            currentProfile?.roundCount = newValue
        }
    }
    
    /// ジョーカー枚数
    var jokerCount: String {
        get { currentProfile?.jokerCount ?? "2" }
        set {
            currentProfile?.jokerCount = newValue
        }
    }
    
    /// ゲームレート
    var gameRate: String {
        get { currentProfile?.gameRate ?? "10" }
        set {
            currentProfile?.gameRate = newValue
        }
    }
    
    /// 最高スコア
    var maxScore: String {
        get { currentProfile?.maxScore ?? "1000" }
        set {
            currentProfile?.maxScore = newValue
        }
    }
    
    /// アップレート
    var upRate: String {
        get { currentProfile?.upRate ?? "3" }
        set {
            currentProfile?.upRate = newValue
        }
    }
    
    /// デッキサイクル
    var deckCycle: String {
        get { currentProfile?.deckCycle ?? "5" }
        set {
            currentProfile?.deckCycle = newValue
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
        currentProfile?.update(userName: userName, iconUrl: iconUrl)
    }
} 
