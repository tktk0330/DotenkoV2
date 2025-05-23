/**
 * UserProfile+Extension
 * 
 * UserProfileクラスの拡張
 * より使いやすいアクセサとヘルパーメソッドを提供
 */

import Foundation
import RealmSwift

// MARK: - Convenient Accessors
extension UserProfile {
    /// ユーザー名
    var userName: String {
        get { rmUserName }
        set {
            try? realm?.write {
                rmUserName = newValue
                rmUpdatedAt = Date()
            }
        }
    }
    
    /// プロフィール画像のURL
    var iconUrl: String {
        get { rmIconUrl }
        set {
            try? realm?.write {
                rmIconUrl = newValue
                rmUpdatedAt = Date()
            }
        }
    }
    
    /// ラウンド数
    var roundCount: String {
        get { rmRoundCount }
        set {
            try? realm?.write {
                rmRoundCount = String(newValue)
            }
        }
    }
    
    /// ジョーカー枚数
    var jokerCount: String {
        get { rmJokerCount }
        set {
            try? realm?.write {
                rmJokerCount = String(newValue)
            }
        }
    }
    
    /// ゲームレート
    var gameRate: String {
        get { rmGameRate }
        set {
            try? realm?.write {
                rmGameRate = String(newValue)
            }
        }
    }
    
    /// 最高スコア
    var maxScore: String {
        get { rmMaxScore }
        set {
            try? realm?.write {
                rmMaxScore = String(newValue)
            }
        }
    }
    
    /// アップレート
    var upRate: String {
        get { rmUpRate }
        set {
            try? realm?.write {
                rmUpRate = String(newValue)
            }
        }
    }
    
    /// デッキサイクル
    var deckCycle: String {
        get { rmDeckCycle }
        set {
            try? realm?.write {
                rmDeckCycle = String(newValue)
            }
        }
    }
}

// MARK: - Helper Methods
extension UserProfile {
    /// ゲームルールモデルを生成
    var gameRule: GameRuleModel {
        GameRuleModel(
            roundCount: rmRoundCount,
            jokerCount: rmJokerCount,
            gameRate: rmGameRate,
            maxScore: rmMaxScore,
            upRate: rmUpRate,
            deckCycle: rmDeckCycle
        )
    }
    
    /// プロフィール情報を更新
    /// - Parameters:
    ///   - userName: 新しいユーザー名（オプション）
    ///   - iconUrl: 新しいアイコンURL（オプション）
    func update(userName: String? = nil, iconUrl: String? = nil) {
        try? realm?.write {
            if let userName = userName {
                rmUserName = userName
            }
            if let iconUrl = iconUrl {
                rmIconUrl = iconUrl
            }
            rmUpdatedAt = Date()
        }
    }
    
    /// ゲーム設定を更新
    /// - Parameter gameRule: 新しいゲームルール設定
    func update(gameRule: GameRuleModel) {
        try? realm?.write {
            rmRoundCount = gameRule.roundCount
            rmJokerCount = gameRule.jokerCount
            rmGameRate = gameRule.gameRate
            rmMaxScore = gameRule.maxScore ?? rmMaxScore
            rmUpRate = gameRule.upRate ?? rmUpRate
            rmDeckCycle = gameRule.deckCycle ?? rmDeckCycle
        }
    }
} 
