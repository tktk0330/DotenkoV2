/**
 BOT思考・操作管理システム
 */

import Foundation
import SwiftUI

// MARK: - BOT Manager Protocol
/// BOT管理システムのプロトコル
protocol BotManagerProtocol {
    func startBotTurn(player: Player, gameState: BotGameState, completion: @escaping (BotAction) -> Void)
    func checkRealtimeDotenkoDeclarations(players: [Player], gameState: BotGameState, completion: @escaping ([String]) -> Void)
    func performChallengeAction(player: Player, gameState: BotGameState, completion: @escaping (BotChallengeAction) -> Void)
    func checkRealtimeCardPlay(player: Player, gameState: BotGameState, completion: @escaping ([Card]) -> Void)
    func checkFirstCardPass(player: Player, gameState: BotGameState, completion: @escaping (Bool) -> Void)
}

// MARK: - BOT Game State
/// BOTが判断に必要なゲーム状態情報
struct BotGameState {
    let fieldCards: [Card]
    let deckCards: [Card]
    let gamePhase: GamePhase
    let isAnnouncementBlocking: Bool
    let isCountdownActive: Bool
    let isWaitingForFirstCard: Bool
    let dotenkoWinnerId: String?
    let revengeEligiblePlayers: [String]
    let challengeParticipants: [String]
    
    // カード出し判定用のクロージャ
    let validateCardPlayRules: ([Card], Card) -> (canPlay: Bool, reason: String)
    let canPlayerDeclareDotenko: (String) -> Bool
    let canPlayerDeclareRevenge: (String) -> Bool
    let calculateHandTotals: ([Card]) -> [Int]
}

// MARK: - BOT Action Types
/// BOTの行動タイプ
enum BotAction {
    case dotenkoDeclaration(playerId: String)
    case playCards(playerId: String, cards: [Card])
    case drawCard(playerId: String)
    case pass(playerId: String)
    case burst(playerId: String)
}

/// BOTのチャレンジアクション
enum BotChallengeAction {
    case dotenkoDeclaration(playerId: String)
    case drawAndContinue(playerId: String)
}

// MARK: - BOT Manager Implementation
/// BOT思考・操作管理システム
class BotManager: BotManagerProtocol {
    
    // MARK: - Properties
    private let thinkingTimeRange: ClosedRange<Double> = 0.5...3.0
    private let realtimeDelayRange: ClosedRange<Double> = 0.1...2.0
    private let revengeDelayRange: ClosedRange<Double> = 0.5...2.0
    
    // MARK: - Public Methods
    
    /// BOTのターンを開始
    func startBotTurn(player: Player, gameState: BotGameState, completion: @escaping (BotAction) -> Void) {
        guard player.id != "player" else {
            print("⚠️ BOTターン開始エラー: 人間プレイヤーが指定されました")
            return
        }
        
        // 🔥 どてんこ処理中は全ての処理を停止
        if gameState.gamePhase == .dotenkoProcessing {
            print("🛑 BOTターン停止: どてんこ処理中のため処理をキャンセル - \(player.name)")
            return
        }
        
        // アナウンス中は処理しない
        if gameState.isAnnouncementBlocking {
            print("🛑 BOTターン停止: アナウンス中のため処理をキャンセル - \(player.name)")
            return
        }
        
        print("🤖 BOTターン開始: \(player.name)")
        print("   プレイヤーID: \(player.id)")
        print("   現在のゲームフェーズ: \(gameState.gamePhase)")
        print("   アナウンス中: \(gameState.isAnnouncementBlocking)")
        print("   カウントダウン中: \(gameState.isCountdownActive)")
        print("   待機中: \(gameState.isWaitingForFirstCard)")
        
        // 思考時間をランダムに設定
        let thinkingTime = Double.random(in: thinkingTimeRange)
        print("🤖 BOT思考時間: \(String(format: "%.1f", thinkingTime))秒")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + thinkingTime) {
            // 🔥 遅延実行時にも再度状態をチェック
            if gameState.gamePhase == .dotenkoProcessing {
                print("🛑 BOT思考完了時停止: どてんこ処理中のため処理をキャンセル - \(player.name)")
                return
            }
            
            print("🤖 BOT思考完了 - 行動実行開始: \(player.name)")
            self.performBotAction(player: player, gameState: gameState, completion: completion)
        }
    }
    
    /// BOTのリアルタイムどてんこ宣言チェック
    func checkRealtimeDotenkoDeclarations(players: [Player], gameState: BotGameState, completion: @escaping ([String]) -> Void) {
        guard gameState.gamePhase == .playing else { 
            completion([])
            return 
        }
        
        // 🔥 どてんこ処理中は処理しない
        if gameState.gamePhase == .dotenkoProcessing {
            completion([])
            return
        }
        
        // アナウンス中は処理しない
        if gameState.isAnnouncementBlocking {
            completion([])
            return
        }
        
        // BOTプレイヤーのみをチェック
        let botPlayers = players.filter { $0.id != "player" }
        
        for bot in botPlayers {
            if gameState.canPlayerDeclareDotenko(bot.id) && !bot.dtnk {
                // BOTは見逃しなしで即座に宣言（少し遅延を入れて人間らしく）
                let delay = Double.random(in: realtimeDelayRange)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    // 🔥 遅延実行時にも再度状態をチェック
                    if gameState.gamePhase == .dotenkoProcessing {
                        print("🛑 BOTリアルタイムどてんこ停止: どてんこ処理中のため処理をキャンセル - \(bot.name)")
                        completion([])
                        return
                    }
                    
                    if gameState.canPlayerDeclareDotenko(bot.id) && !bot.dtnk {
                        print("🤖 BOT \(bot.name) がリアルタイムどてんこ宣言!")
                        completion([bot.id])
                    }
                }
                return // 最初に宣言したBOTで処理終了
            }
        }
        
        completion([])
    }
    

    
    /// BOTのチャレンジアクション
    func performChallengeAction(player: Player, gameState: BotGameState, completion: @escaping (BotChallengeAction) -> Void) {
        // ジョーカー自動選択でどてんこ判定
        if gameState.canPlayerDeclareDotenko(player.id) {
            print("🤖 BOT \(player.name) がチャレンジでどてんこ宣言!")
            completion(.dotenkoDeclaration(playerId: player.id))
        } else {
            // デッキからカードを引いて継続
            completion(.drawAndContinue(playerId: player.id))
        }
    }
    
    // MARK: - Private Methods
    
    /// BOTの行動を実行
    private func performBotAction(player: Player, gameState: BotGameState, completion: @escaping (BotAction) -> Void) {
        print("🤖 BOT行動開始: \(player.name)")
        print("   手札: \(player.hand.map { $0.card.rawValue })")
        print("   場のカード: \(gameState.fieldCards.last?.card.rawValue ?? "なし")")
        print("   カード引き済み: \(player.hasDrawnCardThisTurn)")
        
        // 1. どてんこ宣言チェック（最優先）
        if gameState.canPlayerDeclareDotenko(player.id) {
            print("🤖 BOT \(player.name) がどてんこ宣言!")
            completion(.dotenkoDeclaration(playerId: player.id))
            return
        }
        
        // 2. カード出し判定
        let playableCards = getBotPlayableCards(player: player, gameState: gameState)
        print("🤖 BOT \(player.name) の出せるカード組み合わせ数: \(playableCards.count)")
        
        if !playableCards.isEmpty {
            // 最適なカードを選択
            let bestCards = selectBestCards(from: playableCards, gameState: gameState)
            
            print("🤖 BOT \(player.name) がカードを出します: \(bestCards.map { $0.card.rawValue })")
            completion(.playCards(playerId: player.id, cards: bestCards))
            return
        } else {
            print("🤖 BOT \(player.name) は出せるカードがありません")
        }
        
        // 3. デッキから引くかパス
        print("🤖 BOT \(player.name) はデッキから引くかパスを選択")
        executeBotDrawOrPass(player: player, gameState: gameState, completion: completion)
    }
    
    /// BOTが出せるカードの組み合わせを取得
    private func getBotPlayableCards(player: Player, gameState: BotGameState) -> [[Card]] {
        guard let fieldCard = gameState.fieldCards.last else {
            print("🤖 BOT出せるカード判定: 場にカードがありません")
            return []
        }
        
        var playableCardSets: [[Card]] = []
        let hand = player.hand
        
        print("🤖 BOT出せるカード判定開始:")
        print("   場のカード: \(fieldCard.card.rawValue)")
        print("   手札: \(hand.map { $0.card.rawValue })")
        
        // 1枚出しの判定
        for card in hand {
            let testCards = [card]
            let validation = gameState.validateCardPlayRules(testCards, fieldCard)
            print("   1枚判定 \(card.card.rawValue): \(validation.canPlay ? "✅" : "❌") - \(validation.reason)")
            if validation.canPlay {
                playableCardSets.append(testCards)
            }
        }
        
        // 2枚組み合わせの判定
        for i in 0..<hand.count {
            for j in (i+1)..<hand.count {
                let testCards = [hand[i], hand[j]]
                let validation = gameState.validateCardPlayRules(testCards, fieldCard)
                print("   2枚判定 [\(hand[i].card.rawValue), \(hand[j].card.rawValue)]: \(validation.canPlay ? "✅" : "❌") - \(validation.reason)")
                if validation.canPlay {
                    playableCardSets.append(testCards)
                }
            }
        }
        
        print("🤖 BOT出せるカード判定結果: \(playableCardSets.count)個の組み合わせが出せます")
        for (index, cardSet) in playableCardSets.enumerated() {
            print("   組み合わせ\(index + 1): \(cardSet.map { $0.card.rawValue })")
        }
        
        return playableCardSets
    }
    
    /// 最適なカードを選択
    private func selectBestCards(from playableCardSets: [[Card]], gameState: BotGameState) -> [Card] {
        guard !playableCardSets.isEmpty else { return [] }
        
        // カードの優先度を計算
        var bestCards = playableCardSets[0]
        var bestPriority = calculateBotCardPriority(cards: bestCards, gameState: gameState)
        
        for cardSet in playableCardSets {
            let priority = calculateBotCardPriority(cards: cardSet, gameState: gameState)
            if priority > bestPriority {
                bestPriority = priority
                bestCards = cardSet
            }
        }
        
        return bestCards
    }
    
    /// BOTのカード優先度を計算
    private func calculateBotCardPriority(cards: [Card], gameState: BotGameState) -> Int {
        guard let fieldCard = gameState.fieldCards.last else { return 0 }
        
        var priority = 0
        let fieldValue = fieldCard.card.handValue().first ?? 0
        let fieldSuit = fieldCard.card.suit()
        
        for card in cards {
            // 基本優先度
            priority += 10
            
            // 同じ数字は高優先度
            if card.card.handValue().contains(fieldValue) {
                priority += 100
            }
            
            // 同じスートは中優先度
            if card.card.suit() == fieldSuit {
                priority += 50
            }
            
            // ジョーカーは温存したいので低優先度
            if card.card.suit() == .joker {
                priority -= 10
            }
            
            // 高い数字は出したい
            if let cardValue = card.card.handValue().first {
                priority += cardValue
            }
        }
        
        // 複数枚出しは少し優先度を下げる
        if cards.count > 1 {
            priority -= 5
        }
        
        return priority
    }
    
    /// BOTのデッキ引きまたはパス
    private func executeBotDrawOrPass(player: Player, gameState: BotGameState, completion: @escaping (BotAction) -> Void) {
        print("🤖 BOT \(player.name) のデッキ引き/パス判定:")
        print("   カード引き済み: \(player.hasDrawnCardThisTurn)")
        print("   デッキ残り枚数: \(gameState.deckCards.count)")
        print("   手札枚数: \(player.hand.count)")
        
        // カードを引いていない場合は引く
        if !player.hasDrawnCardThisTurn {
            if !gameState.deckCards.isEmpty && player.hand.count < 7 {
                print("🤖 BOT \(player.name) がデッキからカードを引きます")
                completion(.drawCard(playerId: player.id))
            } else {
                // デッキが空または手札が7枚の場合はパス
                print("🤖 BOT \(player.name) がパスします（デッキ空または手札満杯）")
                completion(.pass(playerId: player.id))
            }
            return
        }
        
        // カードを引いている場合はパス
        print("🤖 BOT \(player.name) がパスします（カード引き済み）")
        
        // バースト判定
        if player.hand.count >= 7 {
            print("💥 BOT \(player.name) がバースト!")
            completion(.burst(playerId: player.id))
            return
        }
        
        // 通常のパス
        completion(.pass(playerId: player.id))
    }
    
    /// BOTの早い者勝ちカード出しチェック
    func checkRealtimeCardPlay(player: Player, gameState: BotGameState, completion: @escaping ([Card]) -> Void) {
        guard gameState.isWaitingForFirstCard else {
            print("🏁 BOT \(player.name) の早い者勝ちカード出し判定: 早い者勝ちモードではありません")
            completion([])
            return
        }
        
        guard let fieldCard = gameState.fieldCards.last else {
            print("🏁 BOT \(player.name) の早い者勝ちカード出し判定: 場にカードがありません")
            completion([])
            return
        }
        
        print("🏁 BOT \(player.name) の早い者勝ちカード出し判定:")
        print("   手札: \(player.hand.map { $0.card.rawValue })")
        print("   場のカード: \(fieldCard.card.rawValue)")
        
        // BOTが出せるカードの組み合わせを取得
        let playableCardSets = getBotPlayableCards(player: player, gameState: gameState)
        
        if !playableCardSets.isEmpty {
            // 最適なカードを選択
            let bestCards = selectBestCards(from: playableCardSets, gameState: gameState)
            
            // 手札に存在するカードのみを選択
            let validCards = bestCards.filter { card in
                return player.hand.contains(card)
            }
            
            if validCards.isEmpty {
                print("⚠️ BOT \(player.name) の選択カードが手札に存在しません")
                completion([])
                return
            }
            
            print("🏁 BOT \(player.name) が早い者勝ちでカードを出します: \(validCards.map { $0.card.rawValue })")
            completion(validCards)
        } else {
            print("🏁 BOT \(player.name) は早い者勝ちで出せるカードがありません")
            completion([])
        }
    }
    
    /// BOTの早い者勝ちモードでのパス判断
    func checkFirstCardPass(player: Player, gameState: BotGameState, completion: @escaping (Bool) -> Void) {
        guard gameState.isWaitingForFirstCard else {
            completion(false)
            return
        }
        
        print("🏁 BOT \(player.name) の早い者勝ちモードでのパス判断:")
        print("   手札: \(player.hand.map { $0.card.rawValue })")
        
        // BOTが出せるカードの組み合わせを取得
        let playableCardSets = getBotPlayableCards(player: player, gameState: gameState)
        
        if !playableCardSets.isEmpty {
            // 最適なカードを選択
            let bestCards = selectBestCards(from: playableCardSets, gameState: gameState)
            print("🏁 BOT \(player.name) が早い者勝ちでカードを出します: \(bestCards.map { $0.card.rawValue })")
            completion(false)
        } else {
            print("🏁 BOT \(player.name) は早い者勝ちで出せるカードがありません")
            completion(true)
        }
    }
} 
