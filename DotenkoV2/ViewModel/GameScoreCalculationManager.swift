import SwiftUI
import Foundation
import Combine

// MARK: - Game Score Calculation Manager
/// スコア計算システムを管理するクラス
/// GameViewModelから分離された独立したスコア計算機能を提供
class GameScoreCalculationManager: ObservableObject {
    
    // MARK: - Score Constants
    private enum ScoreConstants {
        static let maxUpRate: Int = 1_000_000 // 上昇レートの上限値
        static let specialCardMultiplier2: Int = 2  // 特殊カード（1、2、ジョーカー）の実際の倍率
    }
    
    // MARK: - Published Properties
    
    // スコア計算エンジン
    @Published var currentUpRate: Int = 1 // 現在の上昇レート倍率
    @Published var consecutiveCardCount: Int = 0 // 連続同じ数字カウント
    @Published var lastPlayedCardValue: Int? = nil // 最後に出されたカードの数字
    @Published var roundScore: Int = 0 // ラウンドスコア
    
    // スコア確定画面表示用
    @Published var showScoreResult: Bool = false
    @Published var scoreResultData: ScoreResultData? = nil
    @Published var consecutiveSpecialCards: [Card] = [] // 連続特殊カード
    
    // MARK: - Dependencies
    private weak var announcementEffectManager: GameAnnouncementEffectManager?
    
    // MARK: - Initialization
    init() {
        // announcementEffectManagerは後から設定
    }
    
    /// アナウンス・エフェクトマネージャーを設定
    func setAnnouncementEffectManager(_ manager: GameAnnouncementEffectManager) {
        self.announcementEffectManager = manager
    }
    
    // MARK: - Lifecycle
    deinit {
        print("💰 GameScoreCalculationManager解放")
    }
    
    // MARK: - Score Calculation System
    
    /// スコア計算システムの初期化
    func initializeScoreSystem() {
        currentUpRate = 1
        consecutiveCardCount = 0
        lastPlayedCardValue = nil
        roundScore = 0
        consecutiveSpecialCards = []
        print("💰 スコア計算システム初期化完了")
    }
    
    /// ラウンド終了時のスコア計算を開始
    func startScoreCalculation(gamePhase: GamePhase, deckCards: [Card], fieldCards: [Card], completion: @escaping () -> Void) {
        guard gamePhase == .finished else { return }
        
        print("💰 スコア計算開始")
        
        // デッキの裏確認演出を開始
        announcementEffectManager?.showAnnouncementMessage(
            title: "スコア計算",
            subtitle: "デッキの裏を確認します"
        ) {
            self.revealDeckBottom(deckCards: deckCards, fieldCards: fieldCards, completion: completion)
        }
    }
    
    /// デッキの裏（山札の一番下）を確認
    private func revealDeckBottom(deckCards: [Card], fieldCards: [Card], completion: @escaping () -> Void) {
        guard !deckCards.isEmpty else {
            // デッキが空の場合は場のカードから確認
            revealFromFieldCards(fieldCards: fieldCards, completion: completion)
            return
        }
        
        let bottomCard = deckCards.last!
        print("🔍 デッキの裏確認: \(bottomCard.card.rawValue)")
        
        // 特殊カード判定と演出
        processSpecialCardEffect(card: bottomCard, deckCards: deckCards) {
            self.calculateFinalScore(bottomCard: bottomCard, completion: completion)
        }
    }
    
    /// 場のカードからデッキの裏を確認（デッキが空の場合）
    private func revealFromFieldCards(fieldCards: [Card], completion: @escaping () -> Void) {
        guard !fieldCards.isEmpty else {
            print("⚠️ デッキも場も空のため、スコア計算をスキップします")
            completion()
            return
        }
        
        let bottomCard = fieldCards.first!
        print("🔍 場のカードから裏確認: \(bottomCard.card.rawValue)")
        
        // 特殊カード判定と演出
        processSpecialCardEffect(card: bottomCard, deckCards: []) {
            self.calculateFinalScore(bottomCard: bottomCard, completion: completion)
        }
    }
    
    /// 特殊カード効果の処理と演出
    private func processSpecialCardEffect(card: Card, deckCards: [Card], completion: @escaping () -> Void) {
        print("🎴 特殊カード効果処理開始")
        print("   カード: \(card.card.rawValue)")
        
        // CardModelの統合されたメソッドを使用して特殊効果を判定
        if card.card.isUpRateCard() {
            // 1、2、ジョーカー：2倍演出
            print("🎯 1、2、ジョーカー判定: 上昇レート2倍")
            announcementEffectManager?.showSpecialCardEffect(
                title: "特殊カード発生！",
                subtitle: "\(card.card.rawValue) - 2倍",
                effectType: .multiplier50
            ) {
                self.currentUpRate = self.safeMultiply(self.currentUpRate, by: ScoreConstants.specialCardMultiplier2)
                self.checkConsecutiveSpecialCards(from: card, deckCards: deckCards, completion: completion)
            }
        } else if card.card == .diamond3 {
            // ダイヤ3：最終数字30として扱う（上昇レート倍増なし）
            print("💎 ダイヤ3判定: 最終数字30（上昇レート変更なし）")
            announcementEffectManager?.showSpecialCardEffect(
                title: "ダイヤ3発生！",
                subtitle: "最終数字30",
                effectType: .diamond3
            ) {
                // ダイヤ3は上昇レートを変更せず、最終数字のみ30にする
                completion()
            }
        } else if card.card.finalReverce() {
            // 黒3：勝敗逆転演出
            print("♠️♣️ 黒3判定: 勝敗逆転")
            announcementEffectManager?.showSpecialCardEffect(
                title: "黒3発生！",
                subtitle: "勝敗逆転",
                effectType: .black3Reverse
            ) {
                // 勝敗逆転処理は呼び出し元で実行
                completion()
            }
        } else {
            // 通常カード（ハート3も含む）
            print("🔢 通常カード判定: 特殊効果なし")
            completion()
        }
    }
    
    /// 連続特殊カード確認（1、2、ジョーカーの場合）
    private func checkConsecutiveSpecialCards(from currentCard: Card, deckCards: [Card], completion: @escaping () -> Void) {
        // デッキから次のカードを確認
        var cardsToCheck = deckCards
        
        // 処理済みカードをデッキから削除
        if let currentIndex = cardsToCheck.firstIndex(where: { $0.id == currentCard.id }) {
            cardsToCheck.remove(at: currentIndex)
            print("🗑️ 処理済みカードを確認用リストから削除: \(currentCard.card.rawValue)")
        }
        
        guard !cardsToCheck.isEmpty else {
            print("🔄 確認用デッキが空のため連続確認を終了")
            completion()
            return
        }
        
        let nextCard = cardsToCheck.last!
        
        print("🔍 次の連続カード確認: \(nextCard.card.rawValue)")
        
        // 連続特殊カード判定（CardModelの統合されたメソッドを使用）
        if nextCard.card.isUpRateCard() {
            // 連続特殊カードリストに追加
            consecutiveSpecialCards.append(nextCard)
            
            announcementEffectManager?.showAnnouncementMessage(
                title: "連続特殊カード！",
                subtitle: "\(nextCard.card.rawValue) - さらに2倍"
            ) {
                self.currentUpRate = self.safeMultiply(self.currentUpRate, by: ScoreConstants.specialCardMultiplier2)
                print("🎯 連続特殊カード処理完了! 新倍率: ×\(self.currentUpRate)")
                self.checkConsecutiveSpecialCards(from: nextCard, deckCards: cardsToCheck, completion: completion)
            }
        } else {
            print("🔄 連続特殊カード終了 - 通常カード: \(nextCard.card.rawValue)")
            completion()
        }
    }
    
    /// 最終スコア計算
    private func calculateFinalScore(bottomCard: Card, completion: @escaping () -> Void) {
        print("🔍 最終数字計算開始")
        print("   カード: \(bottomCard.card.rawValue)")
        print("   スート: \(bottomCard.card.suit())")
        
        // CardModelの新しいメソッドを使用して最終数字を決定
        let bottomCardValue = bottomCard.card.finalScoreNum()
        
        print("💰 最終数字決定: \(bottomCardValue)")
        
        // 特殊効果のログ出力
        if bottomCard.card.suit() == .joker {
            print("🃏 ジョーカー効果: 最終数字を\(bottomCardValue)として計算")
        } else if bottomCard.card == .diamond3 {
            print("💎 ダイヤ3効果: 最終数字を\(bottomCardValue)として計算")
        } else if bottomCard.card.finalReverce() {
            print("♠️♣️ 黒3効果: 最終数字を\(bottomCardValue)として計算")
        } else {
            print("🔢 通常カード: 最終数字を\(bottomCardValue)として計算")
        }
        
        completion()
    }
    
    /// 最終スコア計算（外部から呼び出し用）
    func calculateFinalScoreWithData(
        bottomCard: Card,
        baseRate: Int,
        maxScore: String?,
        players: [Player],
        isShotenkoRound: Bool,
        isBurst: Bool,
        shotenkoWinnerId: String?,
        burstPlayerId: String?,
        dotenkoWinnerId: String?, // 通常のどてんこ勝者ID
        lastCardPlayerId: String? // 場のカードを出したプレイヤーID
    ) {
        // CardModelの新しいメソッドを使用して最終数字を決定
        let bottomCardValue = bottomCard.card.finalScoreNum()
        
        // 基本計算式：初期レート × 上昇レート × デッキの裏の数字
        roundScore = baseRate * currentUpRate * bottomCardValue
        
        // スコア上限チェック
        if let maxScoreString = maxScore,
           maxScoreString != "♾️",
           let maxScore = Int(maxScoreString) {
            roundScore = min(roundScore, maxScore)
        }
        
        print("💰 最終スコア計算完了")
        print("   基本レート: \(baseRate)")
        print("   上昇レート: \(currentUpRate)")
        print("   デッキの裏: \(bottomCard.card.rawValue)")
        print("   最終数字: \(bottomCardValue)")
        print("   ラウンドスコア: \(roundScore)")
        
        // 勝者・敗者を特定（IDベースで正確に特定、配列対応）
        var winners: [Player] = []
        var losers: [Player] = []
        
        if isShotenkoRound, let shotenkoWinnerId = shotenkoWinnerId {
            // しょてんこの場合：勝者1人、敗者は複数人
            if let winner = players.first(where: { $0.id == shotenkoWinnerId }) {
                winners = [winner]
            }
            losers = players.filter { $0.id != shotenkoWinnerId }
            print("🎊 しょてんこ勝敗特定: 勝者=\(winners.count)人, 敗者=\(losers.count)人")
        } else if isBurst, let burstPlayerId = burstPlayerId {
            // バーストの場合：敗者1人、勝者は複数人
            winners = players.filter { $0.id != burstPlayerId }
            if let loser = players.first(where: { $0.id == burstPlayerId }) {
                losers = [loser]
            }
            print("💥 バースト勝敗特定: 勝者=\(winners.count)人, 敗者=\(losers.count)人")
        } else {
            // 通常のどてんこの場合：IDベースで特定（rank使用禁止）
            guard let winnerId = dotenkoWinnerId else {
                print("⚠️ 通常どてんこの勝者IDが見つかりません")
                return
            }
            
            if let winner = players.first(where: { $0.id == winnerId }) {
                winners = [winner]
            }
            
            // 場のカードを出したプレイヤーを敗者とする（正しい実装）
            guard let loserId = lastCardPlayerId else {
                print("⚠️ 場のカードを出したプレイヤーIDが見つかりません")
                return
            }
            
            if let loser = players.first(where: { $0.id == loserId }) {
                losers = [loser]
            }
            print("🎯 通常どてんこ勝敗特定: 勝者=\(winners.count)人, 敗者=\(losers.count)人")
        }
        
        // スコア確定画面データを作成
        let resultData = ScoreResultData(
            winners: winners,
            losers: losers,
            deckBottomCard: bottomCard,
            consecutiveCards: consecutiveSpecialCards,
            baseRate: baseRate,
            upRate: currentUpRate,
            finalMultiplier: bottomCardValue,
            totalScore: roundScore,
            isShotenkoRound: isShotenkoRound,
            isBurstRound: isBurst,
            shotenkoWinnerId: shotenkoWinnerId,
            burstPlayerId: burstPlayerId
        )
        
        print("🎯 GameScoreCalculationManager - スコア確定画面データ設定")
        // データを設定
        scoreResultData = resultData
        print("   scoreResultData設定完了: \(scoreResultData != nil)")
        
        // 少し遅延してからスコア確定画面を自動表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("🎯 GameScoreCalculationManager - 自動遷移開始")
            self.showScoreResult = true
            print("   showScoreResult設定完了: \(self.showScoreResult)")
            
            // 最終確認
            print("   最終状態確認:")
            print("     showScoreResult: \(self.showScoreResult)")
            print("     scoreResultData: \(self.scoreResultData != nil ? "設定済み" : "nil")")
        }
    }
    
    /// スコア確定画面のOKボタン処理
    func onScoreResultOK(completion: @escaping () -> Void) {
        print("✅ スコア確定画面 - OKボタンタップ")
        showScoreResult = false
        scoreResultData = nil
        completion()
    }
    
    /// プレイヤーにスコアを適用（IDベース統一）
    func applyScoreToPlayers(players: inout [Player], isShotenkoRound: Bool, isBurst: Bool, shotenkoWinnerId: String?, burstPlayerId: String?, dotenkoWinnerId: String?, lastCardPlayerId: String?) {
        // しょてんこの場合の特別計算
        if isShotenkoRound, let shotenkoWinnerId = shotenkoWinnerId {
            applyShotenkoScore(players: &players, winnerId: shotenkoWinnerId)
            return
        }
        
        // バーストの場合の特別計算
        if isBurst, let burstPlayerId = burstPlayerId {
            applyBurstScore(players: &players, burstPlayerId: burstPlayerId)
            return
        }
        
        // 通常のどてんこの場合（IDベース統一）
        applyNormalDotenkoScore(players: &players, winnerId: dotenkoWinnerId, loserId: lastCardPlayerId)
    }
    
    /// しょてんこのスコア計算
    private func applyShotenkoScore(players: inout [Player], winnerId: String) {
        guard let winnerIndex = players.firstIndex(where: { $0.id == winnerId }) else { return }
        
        let otherPlayersCount = players.count - 1
        let totalGain = roundScore * otherPlayersCount
        
        // しょてんこした人：他の全プレイヤーからラウンドスコアを受け取る
        players[winnerIndex].score += totalGain
        print("🎯 \(players[winnerIndex].name) がしょてんこでスコア獲得: +\(totalGain) (\(roundScore)×\(otherPlayersCount)人)")
        
        // その他の人：各自ラウンドスコアを失う
        for index in players.indices {
            if players[index].id != winnerId {
                players[index].score -= roundScore
                print("💀 \(players[index].name) がしょてんこでスコア失失: -\(roundScore)")
            }
        }
    }
    
    /// バーストのスコア計算
    private func applyBurstScore(players: inout [Player], burstPlayerId: String) {
        guard let burstIndex = players.firstIndex(where: { $0.id == burstPlayerId }) else { return }
        
        let otherPlayersCount = players.count - 1
        let totalLoss = roundScore * otherPlayersCount
        
        // バーストした人：他の全プレイヤーにラウンドスコアを支払う
        players[burstIndex].score -= totalLoss
        print("💥 \(players[burstIndex].name) がバーストでスコア失失: -\(totalLoss) (\(roundScore)×\(otherPlayersCount)人)")
        
        // その他の人：各自ラウンドスコアを獲得
        for index in players.indices {
            if players[index].id != burstPlayerId {
                players[index].score += roundScore
                print("🏆 \(players[index].name) がバーストでスコア獲得: +\(roundScore)")
            }
        }
    }
    
    /// 通常のどてんこのスコア計算（IDベース）
    private func applyNormalDotenkoScore(players: inout [Player], winnerId: String?, loserId: String?) {
        guard let winnerId = winnerId else {
            print("⚠️ 通常どてんこの勝者IDが見つかりません - スコア適用をスキップ")
            return
        }
        
        guard let loserId = loserId else {
            print("⚠️ 通常どてんこの敗者IDが見つかりません - スコア適用をスキップ")
            return
        }
        
        // 勝者にスコアを加算
        if let winnerIndex = players.firstIndex(where: { $0.id == winnerId }) {
            players[winnerIndex].score += roundScore
            print("🏆 \(players[winnerIndex].name) がどてんこでスコア獲得: +\(roundScore)")
        } else {
            print("⚠️ 勝者プレイヤーが見つかりません: \(winnerId)")
        }
        
        // 敗者からスコアを減算
        if let loserIndex = players.firstIndex(where: { $0.id == loserId }) {
            players[loserIndex].score -= roundScore
            print("💀 \(players[loserIndex].name) がどてんこでスコア失失: -\(roundScore)")
        } else {
            print("⚠️ 敗者プレイヤーが見つかりません: \(loserId)")
        }
        
        // その他のプレイヤーは変動なし
        let otherPlayers = players.filter { $0.id != winnerId && $0.id != loserId }
        for player in otherPlayers {
            print("➖ \(player.name) はスコア変動なし")
        }
    }
    
    /// ラウンドスコアを設定
    func setRoundScore(_ score: Int) {
        roundScore = score
    }
    
    /// スコア計算状態をリセット
    func resetScoreCalculation() {
        currentUpRate = 1
        consecutiveCardCount = 0
        lastPlayedCardValue = nil
        roundScore = 0
    }
    
    /// ゲーム中の上昇レート管理
    func updateUpRateForCardPlay(card: Card, gameRuleInfo: GameRuleModel, onRateUp: @escaping (Int) -> Void) {
        let cardValue = card.card.handValue().first ?? 0
        
        // 連続同じ数字判定
        if let lastValue = lastPlayedCardValue, lastValue == cardValue {
            consecutiveCardCount += 1
        } else {
            consecutiveCardCount = 1
            lastPlayedCardValue = cardValue
        }
        
        // 上昇レート条件チェック
        if let upRateString = gameRuleInfo.upRate,
           upRateString != "なし",
           let upRateThreshold = Int(upRateString) {
            
            if consecutiveCardCount >= upRateThreshold {
                currentUpRate = safeMultiply(currentUpRate, by: 2)
                consecutiveCardCount = 0 // リセット
                
                print("📈 上昇レート発生! 現在の倍率: \(currentUpRate)")
                
                // コールバックで演出を実行
                onRateUp(currentUpRate)
            }
        }
    }
    
    /// ゲーム開始時の上昇レート判定（1、2、ジョーカー）
    func checkGameStartUpRate(card: Card, onRateUp: @escaping (Int) -> Void) {
        // CardModelの統合されたメソッドを使用
        if card.card.isUpRateCard() {
            currentUpRate = safeMultiply(currentUpRate, by: ScoreConstants.specialCardMultiplier2)
            print("🎯 ゲーム開始時上昇レート発生! カード: \(card.card.rawValue), 倍率: ×\(currentUpRate)")
            
            // コールバックで演出を実行
            onRateUp(currentUpRate)
        }
    }
    
    /// ゲーム開始時の連続特殊カード確認
    func checkConsecutiveGameStartCard(card: Card, onRateUp: @escaping (Int) -> Void, onEnd: @escaping () -> Void) {
        // 連続特殊カード判定（CardModelの統合されたメソッドを使用）
        if card.card.isUpRateCard() {
            currentUpRate = safeMultiply(currentUpRate, by: ScoreConstants.specialCardMultiplier2)
            print("🎯 連続特殊カード発生! カード: \(card.card.rawValue), 新倍率: ×\(currentUpRate)")
            
            // コールバックで演出を実行
            onRateUp(currentUpRate)
        } else {
            onEnd()
        }
    }
    
    /// スコア確定画面データを設定
    func setScoreResultData(_ data: ScoreResultData?) {
        scoreResultData = data
    }
    
    /// スコア確定画面の表示状態を設定
    func setShowScoreResult(_ show: Bool) {
        print("🎯 スコア確定画面表示状態変更: \(showScoreResult) → \(show)")
        showScoreResult = show
        print("🎯 変更後の状態: showScoreResult = \(showScoreResult)")
    }
    
    /// スコア確定画面データをクリア
    func clearScoreResult() {
        showScoreResult = false
        scoreResultData = nil
    }
    
    // MARK: - Utility Methods
    
    /// 安全な乗算処理（オーバーフロー防止）
    private func safeMultiply(_ value: Int, by multiplier: Int) -> Int {
        // オーバーフローチェック
        if value > ScoreConstants.maxUpRate / multiplier {
            print("⚠️ 上昇レートが上限値に達しました: \(ScoreConstants.maxUpRate)")
            return ScoreConstants.maxUpRate
        }
        
        let result = value * multiplier
        return min(result, ScoreConstants.maxUpRate)
    }
    
    /// スコア計算マネージャーの状態をログ出力
    func logCurrentState() {
        print("💰 スコア計算マネージャー状態:")
        print("   現在の上昇レート: ×\(currentUpRate)")
        print("   連続カードカウント: \(consecutiveCardCount)")
        print("   最後のカード値: \(lastPlayedCardValue ?? -1)")
        print("   ラウンドスコア: \(roundScore)")
        print("   連続特殊カード数: \(consecutiveSpecialCards.count)")
        print("   スコア結果画面表示中: \(showScoreResult)")
    }
} 
