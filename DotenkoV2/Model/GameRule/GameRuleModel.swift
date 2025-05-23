import Foundation

/// ゲームルールの設定値を保持するモデル
struct GameRuleModel {
    // MARK: - Properties
    
    /// ゲーム数の設定値
    /// - Note: デフォルト値は5ゲーム
    var roundCount: String = UserProfileRepository.shared.roundCount
    
    /// ジョーカーの枚数
    /// - Note: デフォルト値は2枚
    var jokerCount: String = UserProfileRepository.shared.jokerCount
    
    /// 1ゲームあたりのレート
    /// - Note: デフォルト値は1ポイント
    var gameRate: String = UserProfileRepository.shared.gameRate
    
    /// 最大掛け金
    /// - Note: デフォルト値は1000ポイント
    /// - Note: nilの場合は制限なし
    var maxScore: String? = UserProfileRepository.shared.maxScore
    
    /// アップレート（スコア上限）
    /// - Note: デフォルト値は3倍
    /// - Note: nilの場合は制限なし
    var upRate: String? = UserProfileRepository.shared.upRate
    
    /// デッキサイクル
    /// - Note: デフォルト値は3回
    /// - Note: nilの場合は制限なし
    var deckCycle: String? = UserProfileRepository.shared.deckCycle
    
    // MARK: - Initialization
    
    /// デフォルト値で初期化
    init() {}
    
    /// 指定された値で初期化
    init(
        roundCount: String = UserProfileRepository.shared.roundCount,
        jokerCount: String = UserProfileRepository.shared.jokerCount,
        gameRate: String = UserProfileRepository.shared.gameRate,
        maxScore: String? = UserProfileRepository.shared.maxScore,
        upRate: String? = UserProfileRepository.shared.upRate,
        deckCycle: String? = UserProfileRepository.shared.deckCycle
    ) {
        self.roundCount = roundCount
        self.jokerCount = jokerCount
        self.gameRate = gameRate
        self.maxScore = maxScore
        self.upRate = upRate
        self.deckCycle = deckCycle
    }
}
