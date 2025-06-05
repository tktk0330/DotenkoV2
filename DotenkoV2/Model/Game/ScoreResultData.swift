import Foundation

// MARK: - Score Result Data
/// スコア確定画面表示用のデータ構造
struct ScoreResultData {
    let winner: Player?
    let loser: Player?
    let deckBottomCard: Card?
    let consecutiveCards: [Card] // 連続特殊カードのリスト
    let winnerHand: [Card]
    let baseRate: Int
    let upRate: Int
    let finalMultiplier: Int
    let totalScore: Int
    
    init(
        winner: Player?,
        loser: Player?,
        deckBottomCard: Card?,
        consecutiveCards: [Card] = [],
        winnerHand: [Card] = [],
        baseRate: Int,
        upRate: Int,
        finalMultiplier: Int,
        totalScore: Int
    ) {
        self.winner = winner
        self.loser = loser
        self.deckBottomCard = deckBottomCard
        self.consecutiveCards = consecutiveCards
        self.winnerHand = winnerHand
        self.baseRate = baseRate
        self.upRate = upRate
        self.finalMultiplier = finalMultiplier
        self.totalScore = totalScore
    }
} 