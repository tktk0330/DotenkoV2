import Foundation

/// ゲームルールの設定値を保持するモデル
struct GameRuleModel {
    // MARK: - Properties
    
    /// ゲーム数の設定値
    /// - Note: デフォルト値は5ゲーム
    var roundCount: String = "5"
    
    /// ジョーカーの枚数
    /// - Note: デフォルト値は2枚
    var jokerCount: String = "2"
    
    /// 1ゲームあたりのレート
    /// - Note: デフォルト値は1ポイント
    var gameRate: String = "1"
    
    /// 最大掛け金
    /// - Note: デフォルト値は1000ポイント
    /// - Note: nilの場合は制限なし
    var maxScore: String? = "1000"
    
    /// アップレート（スコア上限）
    /// - Note: デフォルト値は3倍
    /// - Note: nilの場合は制限なし
    var upRate: String? = "3"
    
    /// デッキサイクル
    /// - Note: デフォルト値は3回
    /// - Note: nilの場合は制限なし
    var deckCycle: String? = "3"
    
    // MARK: - Initialization
    
    /// デフォルト値で初期化
    init() {}
    
    /// 指定された値で初期化
    init(
        roundCount: String = "5",
        jokerCount: String = "2",
        gameRate: String = "1",
        maxScore: String? = "1000",
        upRate: String? = "3",
        deckCycle: String? = "3"
    ) {
        self.roundCount = roundCount
        self.jokerCount = jokerCount
        self.gameRate = gameRate
        self.maxScore = maxScore
        self.upRate = upRate
        self.deckCycle = deckCycle
    }
}
