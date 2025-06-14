import Foundation

// MARK: - Score Result Data
/// スコア確定画面表示用のデータ構造
struct ScoreResultData {
    let winners: [Player] // 勝者配列（しょてんこ: 1人、バースト: 複数人、通常: 1人）
    let losers: [Player] // 敗者配列（しょてんこ: 複数人、バースト: 1人、通常: 1人）
    let deckBottomCard: Card?
    let consecutiveCards: [Card] // 連続特殊カードのリスト
    let baseRate: Int
    let upRate: Int
    let finalMultiplier: Int
    let totalScore: Int
    
    // しょてんこ・バースト情報
    let isShotenkoRound: Bool
    let isBurstRound: Bool
    let shotenkoWinnerId: String?
    let burstPlayerId: String?
    
    init(
        winners: [Player] = [],
        losers: [Player] = [],
        deckBottomCard: Card?,
        consecutiveCards: [Card] = [],
        baseRate: Int,
        upRate: Int,
        finalMultiplier: Int,
        totalScore: Int,
        isShotenkoRound: Bool = false,
        isBurstRound: Bool = false,
        shotenkoWinnerId: String? = nil,
        burstPlayerId: String? = nil
    ) {
        self.winners = winners
        self.losers = losers
        self.deckBottomCard = deckBottomCard
        self.consecutiveCards = consecutiveCards
        self.baseRate = baseRate
        self.upRate = upRate
        self.finalMultiplier = finalMultiplier
        self.totalScore = totalScore
        self.isShotenkoRound = isShotenkoRound
        self.isBurstRound = isBurstRound
        self.shotenkoWinnerId = shotenkoWinnerId
        self.burstPlayerId = burstPlayerId
    }
} 