import SwiftUI
import Combine

// MARK: - Score Result ViewModel
/// スコア結果画面のビジネスロジックを管理するViewModel
class ScoreResultViewModel: ObservableObject {
    
    // MARK: - Constants
    private enum AnimationTiming {
        static let cardPreparation: Double = 0.5
        static let cardFlip: Double = 1.0
        static let cardMovement: Double = 1.0
        static let cardPlacement: Double = 0.8
        static let nextCardDelay: Double = 0.5
        static let calculationDelay: Double = 0.5
        static let reversalDelay: Double = 1.5
        static let reversalDuration: Double = 1.0
        static let reversalComplete: Double = 4.0
    }
    
    private enum ScoreAnimationTiming {
        static let sectionShow: Double = 0.5
        static let baseRateDelay: Double = 0.5
        static let upRateDelay: Double = 1.8
        static let finalMultiplierDelay: Double = 3.1
        static let totalScoreDelay: Double = 4.4
        static let okButtonDelay: Double = 6.2
        static let countUpDuration: Double = 1.0
        static let totalScoreCountDuration: Double = 1.5
    }
    
    private enum CardConstants {
        static let deckDisplayCount = 5
        static let dummyCardCount = 4
    }
    
    private enum ScoreConstants {
        static let maxUpRate: Int = 1_000_000 // 上昇レートの上限値
        // 特殊カード倍率定数は削除 - 重複処理防止のため
    }
    
    // MARK: - Published Properties
    
    // アニメーション設定
    @Published var animationSpeed: Double = 0.8
    
    // デッキとカード状態
    @Published var deckCards: [Card] = []
    @Published var revealedCards: [Card] = []
    @Published var showDeck = true
    
    // カードアニメーション状態
    @Published var floatingCard: Card?
    @Published var isCardFlipped: Bool = false
    @Published var isCardMoving: Bool = false
    @Published var showFloatingCard: Bool = false
    @Published var animationPhase: AnimationPhase = .waiting
    
    // スコア計算アニメーション状態
    @Published var showCalculation: Bool = false
    @Published var animatedBaseRate: Int = 0
    @Published var animatedUpRate: Int = 0
    @Published var animatedFinalMultiplier: Int = 0
    @Published var animatedTotalScore: Int = 0
    @Published var showBaseRate: Bool = false
    @Published var showUpRate: Bool = false
    @Published var showFinalMultiplier: Bool = false
    @Published var showTotalScore: Bool = false
    @Published var showOKButton: Bool = false
    
    // 逆転アニメーション状態
    @Published var isReversed: Bool = false
    @Published var showReversalAnimation: Bool = false
    @Published var reversalAnimationPhase: Int = 0
    @Published var currentWinner: Player? // UI表示用（代表勝者）
    @Published var currentLoser: Player? // UI表示用（代表敗者）
    
    // MARK: - Private Properties
    private var currentRevealIndex: Int = 0
    private var currentUpRate: Int = 0
    private var needsAdditionalCard: Bool = false
    private var additionalCards: [Card] = []
    
    // 入力データ（配列対応）
    private let winners: [Player] // 勝者配列
    private let losers: [Player] // 敗者配列
    private let deckBottomCard: Card?
    private let consecutiveCards: [Card]
    private let baseRate: Int
    private let upRate: Int
    private let finalMultiplier: Int
    private let totalScore: Int
    
    // しょてんこ・バースト情報
    private let isShotenkoRound: Bool
    private let isBurstRound: Bool
    private let shotenkoWinnerId: String?
    private let burstPlayerId: String?
    
    // MARK: - Animation Phase Enum
    enum AnimationPhase {
        case waiting
        case revealing
        case moving
        case placed
    }
    
    // MARK: - Initialization
    init(winners: [Player] = [], losers: [Player] = [], deckBottomCard: Card?, consecutiveCards: [Card], 
         baseRate: Int, upRate: Int, finalMultiplier: Int, totalScore: Int,
         isShotenkoRound: Bool = false, isBurstRound: Bool = false,
         shotenkoWinnerId: String? = nil, burstPlayerId: String? = nil) {
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
        
        setupInitialState()
    }
    
    // MARK: - Setup Methods
    
    /// 初期状態を設定
    private func setupInitialState() {
        setupPlayerStates()
        setupDeckCards()
        scheduleCardRevealStart()
    }
    
    /// プレイヤー状態を設定
    private func setupPlayerStates() {
        // バーストの場合：バーストしたプレイヤーをLoserとして表示
        if isBurstRound, let burstPlayerId = burstPlayerId {
            // バーストしたプレイヤーを敗者として設定
            currentLoser = losers.first { $0.id == burstPlayerId }
            // 勝者は複数いるので代表として最初の人を表示
            currentWinner = winners.first
            print("💥 バースト表示設定: 敗者=\(currentLoser?.name ?? "nil"), 勝者代表=\(currentWinner?.name ?? "nil")")
        }
        // しょてんこの場合：しょてんこしたプレイヤーをWinnerとして表示
        else if isShotenkoRound, let shotenkoWinnerId = shotenkoWinnerId {
            // しょてんこしたプレイヤーを勝者として設定
            currentWinner = winners.first { $0.id == shotenkoWinnerId }
            // 敗者は複数いるので代表として最初の人を表示
            currentLoser = losers.first
            print("🎊 しょてんこ表示設定: 勝者=\(currentWinner?.name ?? "nil"), 敗者代表=\(currentLoser?.name ?? "nil")")
        }
        // 通常のどてんこの場合
        else {
            currentWinner = winners.first
            currentLoser = losers.first
            print("🎯 通常どてんこ表示設定: 勝者=\(currentWinner?.name ?? "nil"), 敗者=\(currentLoser?.name ?? "nil")")
        }
        
        currentUpRate = upRate
    }
    
    /// デッキカードを設定
    private func setupDeckCards() {
        guard let deckCard = deckBottomCard else { return }
        
        // 実際のカードを追加
        deckCards = [deckCard]
        deckCards.append(contentsOf: consecutiveCards)
        
        // 表示用ダミーカードを追加
        addDummyCards()
    }
    
    /// 表示用ダミーカードを追加
    private func addDummyCards() {
        for _ in 0..<CardConstants.dummyCardCount {
            deckCards.append(Card(card: .back, location: .deck))
        }
    }
    
    /// カードめくり開始をスケジュール
    private func scheduleCardRevealStart() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startCardRevealSequence()
        }
    }
    
    // MARK: - Animation Control Methods
    
    /// カードめくりシーケンスを開始
    private func startCardRevealSequence() {
        guard hasMoreCardsToReveal() else {
            // 全カードめくり終了時にデッキを非表示
            withAnimation(.easeOut(duration: 0.5)) {
                showDeck = false
            }
            startCalculationAnimation()
            return
        }
        
        let cardToReveal = deckCards[currentRevealIndex]
        
        if shouldSkipCard(cardToReveal) {
            currentRevealIndex += 1
            startCardRevealSequence()
            return
        }
        
        performCardRevealAnimation(card: cardToReveal)
    }
    
    /// めくるべきカードがまだあるかチェック
    private func hasMoreCardsToReveal() -> Bool {
        return currentRevealIndex < deckCards.count - CardConstants.dummyCardCount
    }
    
    /// カードをスキップすべきかチェック
    private func shouldSkipCard(_ card: Card) -> Bool {
        return card.card == .back
    }
    
    /// カードめくりアニメーションを実行
    private func performCardRevealAnimation(card: Card) {
        resetCardAnimationState()
        prepareCard(card)
        scheduleCardFlip(card)
        scheduleCardMovement(card)
        scheduleCardPlacement(card)
    }
    
    /// カードアニメーション状態をリセット
    private func resetCardAnimationState() {
        isCardFlipped = false
        isCardMoving = false
    }
    
    /// カードを準備
    private func prepareCard(_ card: Card) {
        floatingCard = card
        animationPhase = .revealing
        showFloatingCard = true
        print("カード準備完了: \(card.card.rawValue)")
    }
    
    /// カードフリップをスケジュール
    private func scheduleCardFlip(_ card: Card) {
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationTiming.cardPreparation) {
            print("フリップ開始: \(card.card.rawValue)")
            self.isCardFlipped = true
        }
    }
    
    /// カード移動をスケジュール
    private func scheduleCardMovement(_ card: Card) {
        let delay = AnimationTiming.cardPreparation + AnimationTiming.cardFlip
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            print("移動開始: \(card.card.rawValue)")
            self.animationPhase = .moving
            self.isCardMoving = true
        }
    }
    
    /// カード配置をスケジュール
    private func scheduleCardPlacement(_ card: Card) {
        let delay = AnimationTiming.cardPreparation + AnimationTiming.cardFlip + AnimationTiming.cardMovement
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.completeCardPlacement(card)
        }
    }
    
    /// カード配置を完了
    private func completeCardPlacement(_ card: Card) {
        print("配置完了: \(card.card.rawValue)")
        animationPhase = .placed
        
        addCardToRevealedList(card)
        resetAnimationState()
        processSpecialCard(card)
        scheduleNextCardOrAdditional()
    }
    
    /// カードをめくられたリストに追加
    private func addCardToRevealedList(_ card: Card) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            revealedCards.append(card)
        }
    }
    
    /// 次のカードまたは追加カード処理をスケジュール
    private func scheduleNextCardOrAdditional() {
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationTiming.cardPlacement) {
            self.currentRevealIndex += 1
            
            if self.needsAdditionalCard {
                self.generateAdditionalCard()
                self.needsAdditionalCard = false
            } else {
                self.startCardRevealSequence()
            }
        }
    }
    
    /// アニメーション状態をリセット
    private func resetAnimationState() {
        floatingCard = nil
        isCardFlipped = false
        isCardMoving = false
        showFloatingCard = false
        animationPhase = .waiting
    }
    
    // MARK: - Special Card Processing
    
    /// 特殊カード処理
    private func processSpecialCard(_ card: Card) {
        // 逆転カード判定
        if isReversalCard(card) && !isReversed {
            print("逆転カード検出: \(card.card.rawValue)")
            startReversalAnimation()
            return
        }
        
        // 特殊カード判定（1、2、ジョーカー）の場合は追加カード生成のみ
        // レート倍増はGameViewModelで既に処理済みのため、ここでは重複処理を避ける
        if isSpecialCard(card) {
            print("特殊カード検出: \(card.card.rawValue) - 追加カード生成")
            needsAdditionalCard = true
        }
    }
    
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
    
    /// 追加カードを生成
    private func generateAdditionalCard() {
        let additionalCard = generateRandomCard()
        deckCards.insert(additionalCard, at: currentRevealIndex)
        additionalCards.append(additionalCard)
        
        print("追加カード生成: \(additionalCard.card.rawValue)")
        
        // 追加カードのめくりを続行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.startCardRevealSequence()
        }
    }
    
    // MARK: - Helper Methods
    
    /// カードが特殊カード（1、2、ジョーカー）かどうかを判定
    private func isSpecialCard(_ card: Card) -> Bool {
        // CardModelの統合されたメソッドを使用
        return card.card.isUpRateCard()
    }
    
    /// カードが逆転カード（スペード3、クローバー3）かどうかを判定
    private func isReversalCard(_ card: Card) -> Bool {
        // CardModelの新しいメソッドを使用
        return card.card.finalReverce()
    }
    
    /// ランダムなカードを生成
    private func generateRandomCard() -> Card {
        let allCards: [PlayCard] = [
            .spade1, .spade2, .spade3, .spade4, .spade5, .spade6, .spade7, .spade8, .spade9, .spade10, .spade11, .spade12, .spade13,
            .heart1, .heart2, .heart3,
//                .heart4, .heart5, .heart6, .heart7, .heart8, .heart9, .heart10, .heart11, .heart12, .heart13,
            .diamond1, .diamond2, .diamond3,
//                .diamond4, .diamond5, .diamond6, .diamond7, .diamond8, .diamond9, .diamond10, .diamond11, .diamond12, .diamond13,
            .club1, .club2, .club3,
//                .club4, .club5, .club6, .club7, .club8, .club9, .club10, .club11, .club12, .club13,
            .whiteJoker, .blackJoker
        ]
        
        let randomPlayCard = allCards.randomElement() ?? .spade1
        return Card(card: randomPlayCard, location: .deck)
    }
    
    /// カードの表示名を取得
    func getCardDisplayName(_ playCard: PlayCard) -> String {
        switch playCard {
        case .whiteJoker, .blackJoker:
            return "ジョーカー"
        case .spade1, .spade2, .spade3, .spade4, .spade5, .spade6, .spade7, .spade8, .spade9, .spade10, .spade11, .spade12, .spade13:
            let number = playCard.rawValue.replacingOccurrences(of: "s", with: "").replacingOccurrences(of: "0", with: "")
            return "スペード\(number)"
        case .heart1, .heart2, .heart3, .heart4, .heart5, .heart6, .heart7, .heart8, .heart9, .heart10, .heart11, .heart12, .heart13:
            let number = playCard.rawValue.replacingOccurrences(of: "h", with: "").replacingOccurrences(of: "0", with: "")
            return "ハート\(number)"
        case .diamond1, .diamond2, .diamond3, .diamond4, .diamond5, .diamond6, .diamond7, .diamond8, .diamond9, .diamond10, .diamond11, .diamond12, .diamond13:
            let number = playCard.rawValue.replacingOccurrences(of: "d", with: "").replacingOccurrences(of: "0", with: "")
            return "ダイヤ\(number)"
        case .club1, .club2, .club3, .club4, .club5, .club6, .club7, .club8, .club9, .club10, .club11, .club12, .club13:
            let number = playCard.rawValue.replacingOccurrences(of: "c", with: "").replacingOccurrences(of: "0", with: "")
            return "クラブ\(number)"
        case .back:
            return "裏面"
        }
    }
    
    // MARK: - Score Calculation Animation
    
    /// スコア計算アニメーションを開始
    private func startCalculationAnimation() {
        showCalculationSection()
        scheduleBaseRateAnimation()
        scheduleUpRateAnimation()
        scheduleFinalMultiplierAnimation()
        scheduleTotalScoreAnimation()
        scheduleOKButtonAnimation()
    }
    
    /// 計算セクションを表示
    private func showCalculationSection() {
        withAnimation(.easeInOut(duration: ScoreAnimationTiming.sectionShow)) {
            showCalculation = true
        }
    }
    
    /// 初期レートアニメーションをスケジュール
    private func scheduleBaseRateAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + ScoreAnimationTiming.baseRateDelay) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.showBaseRate = true
            }
            self.animateValue(from: 0, to: self.baseRate, duration: ScoreAnimationTiming.countUpDuration) { value in
                self.animatedBaseRate = value
            }
        }
    }
    
    /// 上昇レートアニメーションをスケジュール
    private func scheduleUpRateAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + ScoreAnimationTiming.upRateDelay) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.showUpRate = true
            }
            self.animateValue(from: 0, to: self.currentUpRate, duration: ScoreAnimationTiming.countUpDuration) { value in
                self.animatedUpRate = value
            }
        }
    }
    
    /// 最終倍率アニメーションをスケジュール
    private func scheduleFinalMultiplierAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + ScoreAnimationTiming.finalMultiplierDelay) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.showFinalMultiplier = true
            }
            let calculatedFinalMultiplier = self.calculateFinalMultiplierFromRevealedCards()
            self.animateValue(from: 0, to: calculatedFinalMultiplier, duration: ScoreAnimationTiming.countUpDuration) { value in
                self.animatedFinalMultiplier = value
            }
        }
    }
    
    /// 合計スコアアニメーションをスケジュール
    private func scheduleTotalScoreAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + ScoreAnimationTiming.totalScoreDelay) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                self.showTotalScore = true
            }
            let calculatedScore = self.calculateFinalScore()
            self.animateValue(from: 0, to: calculatedScore, duration: ScoreAnimationTiming.totalScoreCountDuration) { value in
                self.animatedTotalScore = value
            }
        }
    }
    
    /// OKボタンアニメーションをスケジュール
    private func scheduleOKButtonAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + ScoreAnimationTiming.okButtonDelay) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                self.showOKButton = true
            }
        }
    }
    
    /// 最終スコアを計算（revealedCardsの最後のカードのfinalScoreNum()を使用）
    private func calculateFinalScore() -> Int {
        // 最後にめくったカードの最終数字を取得
        let calculatedFinalMultiplier = calculateFinalMultiplierFromRevealedCards()
        
        print("💰 revealedCardsを利用したスコア計算")
        print("   基本レート: \(baseRate)")
        print("   上昇レート: \(currentUpRate)")
        print("   計算された最終倍率: \(calculatedFinalMultiplier)")
        
        return baseRate * currentUpRate * calculatedFinalMultiplier
    }
    
    /// revealedCardsから最終倍率を計算（最後のカードのfinalScoreNum()を使用）
    private func calculateFinalMultiplierFromRevealedCards() -> Int {
        // 最後にめくられたカード（デッキの裏）の最終数字を使用
        guard let lastCard = revealedCards.last else {
            print("⚠️ revealedCardsが空のため、デフォルト値1を使用")
            return 1
        }
        
        let finalNum = lastCard.card.finalScoreNum()
        print("🔢 最終倍率カード: \(lastCard.card.rawValue) - 最終数字: \(finalNum)")
        
        return finalNum
    }
    
    /// revealedCardsから逆転効果があるかチェック
    private func hasReversalEffectInRevealedCards() -> Bool {
        return revealedCards.contains { card in
            card.card.finalReverce()
        }
    }
    
    /// 数値のカウントアップアニメーション
    private func animateValue(from startValue: Int, to endValue: Int, duration: Double, updateHandler: @escaping (Int) -> Void) {
        let steps = min(abs(endValue - startValue), 30)
        guard steps > 0 else {
            updateHandler(endValue)
            return
        }
        
        let stepValue = (endValue - startValue) / steps
        let stepDuration = duration / Double(steps)
        
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                let currentValue = startValue + (stepValue * i)
                withAnimation(.easeInOut(duration: stepDuration * 0.5)) {
                    if i == steps {
                        updateHandler(endValue)
                    } else {
                        updateHandler(currentValue)
                    }
                }
            }
        }
    }
    
    // MARK: - Reversal Animation
    
    /// 逆転アニメーションを開始
    private func startReversalAnimation() {
        isReversed = true
        
        showReversalMessage()
        scheduleRotationAnimation()
        schedulePlayerSwap()
        scheduleReversalComplete()
    }
    
    /// 逆転メッセージを表示
    private func showReversalMessage() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            showReversalAnimation = true
        }
    }
    
    /// 回転アニメーションをスケジュール
    private func scheduleRotationAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationTiming.reversalDelay) {
            withAnimation(.easeInOut(duration: AnimationTiming.reversalDuration)) {
                self.reversalAnimationPhase = 1
            }
        }
    }
    
    /// プレイヤー入れ替えをスケジュール
    private func schedulePlayerSwap() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.swapWinnerAndLoser()
            
            withAnimation(.easeInOut(duration: AnimationTiming.reversalDuration)) {
                self.reversalAnimationPhase = 2
            }
        }
    }
    
    /// 勝者と敗者を入れ替え
    private func swapWinnerAndLoser() {
        let tempWinner = currentWinner
        currentWinner = currentLoser
        currentLoser = tempWinner
    }
    
    /// 逆転アニメーション完了をスケジュール
    private func scheduleReversalComplete() {
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationTiming.reversalComplete) {
            self.completeReversalAnimation()
        }
    }
    
    /// 逆転アニメーションを完了
    private func completeReversalAnimation() {
        withAnimation(.easeOut(duration: 0.5)) {
            showReversalAnimation = false
            reversalAnimationPhase = 0
        }
        
        // 通常処理を続行
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationTiming.cardPlacement) {
            self.currentRevealIndex += 1
            self.startCardRevealSequence()
        }
    }
    
    // MARK: - Card Effect Methods
    
    /// カードの効果テキストを取得
    func getCardEffectText(_ card: Card) -> String {
        // CardModelの統合されたメソッドを使用して特殊効果を判定
        if card.card.isUpRateCard() {
            return "×2"
        }
        
        // 逆転カード判定
        if card.card.finalReverce() {
            return "逆転"
        }
        
        // その他のカードは数字を表示
        let cardNumber = card.card.finalScoreNum()
        return "\(cardNumber)"
    }
    
    /// カード効果の色を取得
    func getCardEffectColor(_ card: Card) -> Color {
        // CardModelの統合されたメソッドを使用して特殊効果を判定
        if card.card.isUpRateCard() {
            return .yellow
        }
        
        // 逆転カード判定
        if card.card.finalReverce() {
            return .red
        }
        
        // ダイヤ3判定
        if card.card.finalScoreNum() == 30 {
            return .orange
        }
        
        // その他のカード
        return .white
    }
} 
