import SwiftUI
import Foundation
import Combine

// MARK: - Game View Model
/// ゲーム全体の状態管理を行うViewModel
class GameViewModel: ObservableObject {
    
    // MARK: - Score Constants
    private enum ScoreConstants {
        static let maxUpRate: Int = 1_000_000 // 上昇レートの上限値
        static let specialCardMultiplier2: Int = 2  // 特殊カード（1、2、ジョーカー）の実際の倍率
        // specialCardMultiplier30とspecialCardMultiplier3は削除 - 要件に合わせて修正
    }
    
    // MARK: - Published Properties
    
    // ゲーム基本情報
    @Published var players: [Player] = []
    @Published var maxPlayers: Int = 5
    @Published var gameType: GameType = .vsBot
    @Published var gamePhase: GamePhase = .waiting
    
    // ゲームルール情報
    @Published var gameRuleInfo: GameRuleModel
    
    // ゲーム進行情報
    @Published var currentRound: Int = 1
    @Published var totalRounds: Int = 10
    @Published var currentRate: Int = 10
    @Published var upRate: Int = 3
    @Published var currentPot: Int = 0
    
    // カウントダウン情報
    @Published var countdownValue: Int = 5
    @Published var isCountdownActive: Bool = false
    @Published var showCountdown: Bool = false
    
    // ターン管理情報
    @Published var currentTurnPlayerIndex: Int = 0
    @Published var isWaitingForFirstCard: Bool = false
    
    // デッキ情報
    @Published var deckCards: [Card] = []
    // フィールド情報
    @Published var fieldCards: [Card] = []
    
    // カード選択状態
    @Published var selectedCardIndices: Set<Int> = []
    
    // 最後にカードを出したプレイヤーID（どてんこ制限用）
    @Published var lastCardPlayerId: String? = nil
    
    // 複数同時宣言処理用（最後の宣言者が勝ち）
    private var dotenkoDeclarationTimestamps: [String: Date] = [:]
    
    // プレイヤーがカードを出したかどうかの追跡（しょてんこボタン制御用）
    @Published var hasAnyPlayerPlayedCard: Bool = false
    
    // リベンジ・チャレンジゾーンシステム（マネージャーに委譲）
    var revengeCountdown: Int { revengeManager.revengeCountdown }
    var isRevengeWaiting: Bool { revengeManager.isRevengeWaiting }
    var dotenkoWinnerId: String? { revengeManager.dotenkoWinnerId }
    var revengeEligiblePlayers: [String] { revengeManager.revengeEligiblePlayers }
    var isChallengeZone: Bool { revengeManager.isChallengeZone }
    var challengeParticipants: [String] { revengeManager.challengeParticipants }
    var currentChallengePlayerIndex: Int { revengeManager.currentChallengePlayerIndex }
    var challengeRoundCount: Int { revengeManager.challengeRoundCount }
    
    // チャレンジゾーン参加モーダル
    var showChallengeParticipationModal: Bool { revengeManager.showChallengeParticipationModal }
    var challengeParticipationChoices: [String: ChallengeZoneParticipationModal.ParticipationChoice] { revengeManager.challengeParticipationChoices }
    
    // 手札公開システム
    var showHandReveal: Bool { revengeManager.showHandReveal }
    
    // しょてんこ・バーストシステム
    @Published var isShotenkoRound: Bool = false
    @Published var shotenkoWinnerId: String? = nil
    @Published var burstPlayerId: String? = nil
    @Published var isFirstCardDealt: Bool = false
    @Published var isBurst: Bool = false
    
    // アナウンス・エフェクトシステム（マネージャーに委譲）
    var showAnnouncement: Bool { announcementEffectManager.showAnnouncement }
    var announcementText: String { announcementEffectManager.announcementText }
    var announcementSubText: String { announcementEffectManager.announcementSubText }
    var isAnnouncementBlocking: Bool { announcementEffectManager.isAnnouncementBlocking }
    
    // どてんこロゴアニメーションシステム（マネージャーに委譲）
    var showDotenkoLogoAnimation: Bool { announcementEffectManager.showDotenkoLogoAnimation }
    var dotenkoAnimationTitle: String { announcementEffectManager.dotenkoAnimationTitle }
    var dotenkoAnimationSubtitle: String { announcementEffectManager.dotenkoAnimationSubtitle }
    var dotenkoAnimationColorType: DotenkoAnimationType { announcementEffectManager.dotenkoAnimationColorType }
    var showRateUpEffect: Bool { announcementEffectManager.showRateUpEffect }
    var rateUpMultiplier: Int { announcementEffectManager.rateUpMultiplier }
    
    // 中間結果画面システム
    @Published var showInterimResult: Bool = false
    @Published var isWaitingForOthers: Bool = false

    @Published var playersReadyCount: Int = 0
    
    // 最終結果画面システム
    @Published var showFinalResult: Bool = false
    
    // ⭐ 設定モーダル表示状態を追加
    @Published var showGameSettingsModal: Bool = false
    
    // MARK: - Private Properties
    private let userProfileRepository = UserProfileRepository.shared
    private let botManager: BotManagerProtocol = BotManager()
    let cardValidationManager = GameCardValidationManager() // カード出し判定マネージャー
    let announcementEffectManager = GameAnnouncementEffectManager() // アナウンス・エフェクトマネージャー
    private let scoreCalculationManager: GameScoreCalculationManager // スコア計算マネージャー
    private let revengeManager: GameRevengeManager // リベンジ・チャレンジゾーンマネージャー
    let gameBotManager: GameBotManager // BOT思考システムマネージャー
    private var countdownTimer: Timer?
    private var cancellables = Set<AnyCancellable>() // Combine用のキャンセル可能オブジェクト
    
    // MARK: - Lifecycle
    deinit {
        // タイマーのクリーンアップ
        countdownTimer?.invalidate()
        
        // Combineのクリーンアップ
        cancellables.removeAll()
        
        print("🎮 GameViewModel解放")
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
    
    // MARK: - Initialization
    init(players: [Player] = [], maxPlayers: Int = 5, gameType: GameType = .vsBot) {
        self.players = players
        self.maxPlayers = maxPlayers
        self.gameType = gameType
        
        // スコア計算マネージャーを初期化
        self.scoreCalculationManager = GameScoreCalculationManager(announcementEffectManager: announcementEffectManager)
        
        // リベンジ・チャレンジゾーンマネージャーを初期化
        self.revengeManager = GameRevengeManager(botManager: botManager)
        
        // BOT思考システムマネージャーを初期化
        self.gameBotManager = GameBotManager(botManager: botManager)
        
        // ユーザープロフィールから設定を読み込み
        if case .success(let profile) = userProfileRepository.getOrCreateProfile() {
            self.gameRuleInfo = GameRuleModel(
                roundCount: profile.rmRoundCount,
                jokerCount: profile.rmJokerCount,
                gameRate: profile.rmGameRate,
                maxScore: profile.rmMaxScore,
                upRate: profile.rmUpRate,
                deckCycle: profile.rmDeckCycle
            )
            print("🎮 ゲーム設定読み込み完了:")
            print("   ラウンド数: \(profile.rmRoundCount)")
            print("   ジョーカー枚数: \(profile.rmJokerCount)")
            print("   ゲームレート: \(profile.rmGameRate)")
        } else {
            // フォールバック: デフォルト値で初期化
            self.gameRuleInfo = GameRuleModel(
                roundCount: "5",
                jokerCount: "2", 
                gameRate: "10",
                maxScore: "1000",
                upRate: "3",
                deckCycle: "3"
            )
            print("⚠️ ユーザー設定読み込み失敗 - デフォルト値を使用")
        }
        
        initializeGame()
        
        // マネージャーにGameViewModelの参照を設定
        revengeManager.setGameViewModel(self)
        gameBotManager.setGameViewModel(self)
        
        // スコア計算マネージャーの状態変更を監視
        setupScoreCalculationBinding()
    }
    
    // MARK: - Game Initialization
    func initializeGame() {
        setupGameInfo()
        setupPlayers()
        setupDeck()
        // 初期カード配布はアニメーション付きで実行
        gamePhase = .playing
        
        // ラウンド開始アナウンス
        announcementEffectManager.showAnnouncementMessage(
            title: "Round \(currentRound) Start",
            subtitle: ""
        ) {
            // アナウンス完了後にカード配布開始
            DispatchQueue.main.asyncAfter(deadline: .now() + LayoutConstants.CardDealAnimation.initialDelay) {
                self.dealInitialCardsWithAnimation()
            }
        }
    }
    
    private func setupGameInfo() {
        // ユーザー設定からゲーム情報を取得（デフォルト値で初期化）
        totalRounds = 10
        currentRate = 10
        upRate = 3
        
        // ユーザープロフィールから設定を取得
        if case .success(let profile) = userProfileRepository.getOrCreateProfile() {
            totalRounds = Int(profile.rmRoundCount) ?? 10
            currentRate = Int(profile.rmGameRate) ?? 10
            upRate = Int(profile.rmUpRate) ?? 3
        }
        
        // 初期ポット計算（プレイヤー数 × 基本レート）
        currentPot = maxPlayers * currentRate
        
        // ゲーム状態フラグの初期化
        hasAnyPlayerPlayedCard = false
        lastCardPlayerId = nil
        dotenkoDeclarationTimestamps.removeAll()
        
        // スコア計算システムの初期化
        scoreCalculationManager.initializeScoreSystem()
    }
    
    private func setupPlayers() {
        // プレイヤーが不足している場合は補完
        if players.isEmpty {
            // デフォルトの現在プレイヤーを追加
            let defaultPlayer = Player(
                id: "player",
                side: 0,
                name: "あなた",
                icon_url: nil,
                dtnk: false
            )
            players.append(defaultPlayer)
        }
        
        // ボットプレイヤーを追加（maxPlayersに達するまで）
        let botList = BotPlayerList()
        let availableBots = botList.getBotPlayer().shuffled()
        
        let neededBots = maxPlayers - players.count
        
        // 時計回りの順序でBotを配置
        // 5人対戦の場合: 自分(0) → 中央左(1) → 上左(2) → 上右(3) → 中央右(4)
        let clockwiseOrder = getClockwiseBotOrder(totalPlayers: maxPlayers)
        
        for i in 0..<min(neededBots, availableBots.count) {
            let bot = availableBots[i]
            let botPlayer = Player(
                id: bot.id,
                side: clockwiseOrder[i],
                name: bot.name,
                icon_url: bot.icon_url,
                dtnk: false
            )
            players.append(botPlayer)
        }
    }
    
    /// 時計回りのBot配置順序を取得
    private func getClockwiseBotOrder(totalPlayers: Int) -> [Int] {
        switch totalPlayers {
        case 2:
            // 2人: 自分(0) → 上(1)
            return [1]
        case 3:
            // 3人: 自分(0) → 左(1) → 右(2)
            return [1, 2]
        case 4:
            // 4人: 自分(0) → 左(1) → 上(2) → 右(3)
            return [1, 2, 3]
        case 5:
            // 5人: 自分(0) → 中央左(1) → 上左(2) → 上右(3) → 中央右(4)
            return [1, 2, 3, 4]
        default:
            // デフォルト: 順番通り
            return Array(1..<totalPlayers)
        }
    }
    
    /// アニメーション付きでカードを配布
    private func dealInitialCardsWithAnimation() {
        let cardsPerPlayer = LayoutConstants.CardDealAnimation.initialCardsPerPlayer
        let totalPlayers = players.count
        var currentRound = 0 // 配布ラウンド（1枚目、2枚目...）
        var currentPlayerIndex = 0 // 現在配布中のプレイヤー
        
        print("カード配布開始: \(totalPlayers)人のプレイヤーに\(cardsPerPlayer)枚ずつ配布")
        
        // カード配布のタイマー
        Timer.scheduledTimer(withTimeInterval: LayoutConstants.CardDealAnimation.dealInterval, repeats: true) { timer in
            
            // 配布完了チェック
            if currentRound >= cardsPerPlayer {
                timer.invalidate()
                print("カード配布完了")
                
                // 配布完了後、5秒カウントダウンを開始
                DispatchQueue.main.asyncAfter(deadline: .now() + LayoutConstants.CardDealAnimation.fieldCardDelay) {
                    self.startCountdown()
                }
                return
            }
            
            // カードが残っているかチェック
            guard !self.deckCards.isEmpty else {
                timer.invalidate()
                print("デッキが空になりました")
                return
            }
            
            // スプリングアニメーションでカード配布
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)) {
                let card = self.deckCards.removeFirst()
                var handCard = card
                handCard.location = .hand(playerIndex: currentPlayerIndex, cardIndex: currentRound)
                
                self.players[currentPlayerIndex].hand.append(handCard)
                
                // デバッグ用ログ
                print("カード配布: プレイヤー\(currentPlayerIndex + 1) - \(currentRound + 1)枚目 - \(handCard.card.rawValue)")
            }
            
            // 次のプレイヤーに進む
            currentPlayerIndex += 1
            
            // 全プレイヤーに配布完了したら次のラウンドへ
            if currentPlayerIndex >= totalPlayers {
                currentPlayerIndex = 0
                currentRound += 1
                print("--- \(currentRound)枚目配布完了 ---")
            }
        }
    }
    
    /// 最初の場札を1枚めくる（特殊カードの場合は引き直し）
    private func dealInitialFieldCard() {
        guard !deckCards.isEmpty else { return }
        
        // 特殊カードでない場札が出るまで繰り返し
        dealNonSpecialFieldCard()
    }
    
    /// 特殊カードでない場札を引くまで繰り返す
    private func dealNonSpecialFieldCard() {
        guard !deckCards.isEmpty else { 
            print("⚠️ デッキが空のため、場札を配布できません")
            return 
        }
        
        // 無限ループ防止：最大試行回数を設定
        let maxAttempts = deckCards.count
        var attempts = 0
        
        func attemptDealCard() {
            attempts += 1
            
            // 最大試行回数に達した場合は強制的に場札として確定
            if attempts > maxAttempts {
                print("⚠️ 最大試行回数に達しました。最後のカードを場札として確定します")
                if !deckCards.isEmpty {
                    let lastCard = deckCards.removeFirst()
                    var fieldCard = lastCard
                    fieldCard.location = .field
                    fieldCards.append(fieldCard)
                    isFirstCardDealt = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.checkShotenkoDeclarations()
                    }
                }
                return
            }
            
            guard !deckCards.isEmpty else { 
                print("⚠️ デッキが空になりました")
                return 
            }
            
            // 山札からカードを引くアニメーション
            withAnimation(.easeOut(duration: 0.4)) {
                let drawnCard = deckCards.removeFirst()
                
                // カードを場に配置
                var fieldCard = drawnCard
                fieldCard.location = .field
                fieldCards.append(fieldCard)
                
                print("🎯 場札候補: \(drawnCard.card.rawValue) (試行回数: \(attempts)/\(maxAttempts))")
                
                // 特殊カード判定（1、2、ジョーカー）
                if isSpecialCard(drawnCard) {
                    print("🎯 特殊カード発生: \(drawnCard.card.rawValue) - レートアップ後に引き直し")
                    
                    // ゲーム開始時の上昇レート判定とアニメーション
                    checkGameStartUpRate(card: drawnCard)
                    
                    // レートアップアニメーション終了後に引き直し処理
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) { // レートアップアニメーション時間を考慮
                        print("🔄 レートアップアニメーション終了 - 次のカードを引きます")
                        attemptDealCard() // 再帰呼び出しではなく内部関数を呼び出し
                    }
                    return
                }
                
                // 特殊カードでない場合は場札として確定
                isFirstCardDealt = true
                print("✅ 最初の場札確定: \(fieldCards.last?.card.rawValue ?? "なし") (試行回数: \(attempts))")
                
                // しょてんこ判定を実行
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.checkShotenkoDeclarations()
                }
            }
        }
        
        // 最初の試行を開始
        attemptDealCard()
    }
    
    /// カードが特殊カード（1、2、ジョーカー）かどうかを判定
    private func isSpecialCard(_ card: Card) -> Bool {
        // CardModelの統合されたメソッドを使用
        return card.card.isUpRateCard()
    }
    
    private func setupDeck() {
        // 標準的なトランプデッキを作成（52枚 + 設定されたジョーカー枚数）
        var cards: [Card] = []
        
        // 各スートの1-13のカードを追加
        let spadeCards: [PlayCard] = [.spade1, .spade2, .spade3, .spade4, .spade5, .spade6, .spade7, .spade8, .spade9, .spade10, .spade11, .spade12, .spade13]
        let heartCards: [PlayCard] = [.heart1, .heart2, .heart3, .heart4, .heart5, .heart6, .heart7, .heart8, .heart9, .heart10, .heart11, .heart12, .heart13]
        let diamondCards: [PlayCard] = [.diamond1, .diamond2, .diamond3, .diamond4, .diamond5, .diamond6, .diamond7, .diamond8, .diamond9, .diamond10, .diamond11, .diamond12, .diamond13]
        let clubCards: [PlayCard] = [.club1, .club2, .club3, .club4, .club5, .club6, .club7, .club8, .club9, .club10, .club11, .club12, .club13]
        
        // 各スートのカードをデッキに追加
        for playCard in spadeCards + heartCards + diamondCards + clubCards {
            cards.append(Card(card: playCard, location: .deck))
        }
        
        // ユーザー設定に基づいてジョーカーを追加（0-4枚）
        let jokerCount = Int(gameRuleInfo.jokerCount) ?? 2
        print("🃏 ジョーカー枚数設定: \(jokerCount)枚")
        
        // ジョーカーを設定枚数分追加
        for i in 0..<jokerCount {
            if i % 2 == 0 {
                cards.append(Card(card: .whiteJoker, location: .deck))
            } else {
                cards.append(Card(card: .blackJoker, location: .deck))
            }
        }
        
        print("🎴 デッキ構成完了: 通常カード52枚 + ジョーカー\(jokerCount)枚 = 合計\(cards.count)枚")
        
        // デッキをシャッフル
        deckCards = cards.shuffled()
    }
    
    // MARK: - Player Position Management (動的計算用)
    
    /// 現在のプレイヤー（人間プレイヤー）を取得
    func getCurrentPlayer() -> Player? {
        return players.first { $0.id == "player" }
    }
    
    /// 上部プレイヤーを取得
    func getTopPlayers() -> [Player] {
        switch maxPlayers {
        case 2:
            // 2人: side 1 (上)
            return players.filter { $0.side == 1 }
        case 3:
            // 3人: side 1 (左), side 2 (右)
            return players.filter { $0.side == 1 || $0.side == 2 }.sorted { $0.side < $1.side }
        case 4:
            // 4人: side 2 (上)
            return players.filter { $0.side == 2 }
        case 5:
            // 5人: side 2 (上左), side 3 (上右)
            return players.filter { $0.side == 2 || $0.side == 3 }.sorted { $0.side < $1.side }
        default:
            return []
        }
    }
    
    /// 左側プレイヤーを取得
    func getLeftPlayers() -> [Player] {
        switch maxPlayers {
        case 4:
            // 4人: side 1 (左)
            return players.filter { $0.side == 1 }
        case 5:
            // 5人: side 1 (中央左)
            return players.filter { $0.side == 1 }
        default:
            return []
        }
    }
    
    /// 右側プレイヤーを取得
    func getRightPlayers() -> [Player] {
        switch maxPlayers {
        case 4:
            // 4人: side 3 (右)
            return players.filter { $0.side == 3 }
        case 5:
            // 5人: side 4 (中央右)
            return players.filter { $0.side == 4 }
        default:
            return []
        }
    }
    
    // MARK: - Card Selection Management
    
    /// カードを選択/選択解除する
    func toggleCardSelection(at index: Int) {
        if selectedCardIndices.contains(index) {
            selectedCardIndices.remove(index)
        } else {
            selectedCardIndices.insert(index)
        }
    }
    
    /// プレイヤーのカード選択/選択解除を切り替える
    func togglePlayerCardSelection(playerId: String, card: Card) {
        if let playerIndex = players.firstIndex(where: { $0.id == playerId }) {
            if let cardIndex = players[playerIndex].selectedCards.firstIndex(of: card) {
                // 既に選択されている場合は選択解除
                players[playerIndex].selectedCards.remove(at: cardIndex)
            } else {
                // 選択されていない場合は選択に追加
                players[playerIndex].selectedCards.append(card)
            }
        }
    }
    
    /// 指定されたカードが選択されているかチェック
    func isCardSelected(at index: Int) -> Bool {
        return selectedCardIndices.contains(index)
    }
    
    /// 全てのカード選択を解除
    func clearCardSelection() {
        selectedCardIndices.removeAll()
        // プレイヤーごとの選択カードもクリア
        for index in players.indices {
            players[index].selectedCards.removeAll()
        }
    }
    
    /// プレイヤーの選択されたカードをクリア
    func clearPlayerSelectedCards(playerId: String) {
        if let playerIndex = players.firstIndex(where: { $0.id == playerId }) {
            players[playerIndex].selectedCards.removeAll()
        }
    }
    
    /// 選択されたカードの数を取得
    var selectedCardCount: Int {
        return selectedCardIndices.count
    }
    
    /// 指定プレイヤーの選択されたカード数を取得
    func getPlayerSelectedCardCount(playerId: String) -> Int {
        return players.first(where: { $0.id == playerId })?.selectedCards.count ?? 0
    }
    
    // MARK: - Game Control Methods
    
    /// 次のラウンドに進む
    func nextRound() {
        if currentRound < totalRounds {
            currentRound += 1
            resetRoundInfo()
            
            // 次のラウンド開始アナウンス
            announcementEffectManager.showAnnouncementMessage(
                title: "Round \(currentRound) Start",
                subtitle: ""
            ) {
                // アナウンス後にゲーム初期化
                self.initializeGame()
            }
        } else {
            gamePhase = .finished
            
            // ゲーム終了後の処理
            print("🎮 全ゲーム終了")
        }
    }
    
    /// レートを更新
    func updateRate(_ newRate: Int) {
        currentRate = newRate
    }
    
    /// アップレートを更新
    func updateUpRate(_ newUpRate: Int) {
        upRate = newUpRate
    }
    
    /// ポットを更新
    func updatePot(_ newPot: Int) {
        currentPot = newPot
    }
    
    /// ラウンド情報をリセット
    private func resetRoundInfo() {
        // 新しいラウンドの初期設定
        // 必要に応じてレートやポットをリセット
        clearCardSelection()
    }
    
    // MARK: - Game Actions
    
    /// パス/引くアクションを処理
    func handlePassAction() {
        guard let currentPlayer = getCurrentPlayer() else { return }
        
        // アクション実行権限チェック
        if !canPlayerPerformAction(playerId: currentPlayer.id) {
            print("パス/引くアクション拒否: プレイヤー \(currentPlayer.name) のターンではありません")
            return
        }
        
        // カードを引いていない場合は引く
        if !currentPlayer.hasDrawnCardThisTurn {
            print("カード引きアクションが実行されました - プレイヤー \(currentPlayer.name)")
            
            // 現在のプレイヤーの選択をクリア
            clearPlayerSelectedCards(playerId: currentPlayer.id)
            
            // デッキからカードを引く
            drawCardFromDeck(playerId: currentPlayer.id)
            
            print("プレイヤー \(currentPlayer.name) の手札: \(currentPlayer.hand)")
            return
        }
        
        // カードを引いている場合はパス
        // バースト判定（手札7枚でパス）
        if currentPlayer.hand.count >= 7 {
            print("💥 バースト発生! - プレイヤー \(currentPlayer.name) (手札\(currentPlayer.hand.count)枚)")
            handleBurstEvent(playerId: currentPlayer.id)
            return
        }
        
        print("パスアクションが実行されました - プレイヤー \(currentPlayer.name)")
        
        // 現在のプレイヤーの選択をクリア
        clearPlayerSelectedCards(playerId: currentPlayer.id)
        
        // 次のターンに進む
        nextTurn()
    }
    
    /// デッキからカードを引く
    func drawCardFromDeck(playerId: String) {
        // 🔥 どてんこ処理中は通常のカード引きを停止（チャレンジゾーンは除く）
        if gamePhase == .dotenkoProcessing {
            print("🛑 カード引き停止: どてんこ処理中のため処理をキャンセル")
            return
        }
        
        guard let playerIndex = players.firstIndex(where: { $0.id == playerId }) else { return }
        
        // デッキが空の場合は山札を再構築
        if deckCards.isEmpty {
            reshuffleDeck()
        }
        
        // デッキからカードを引く
        if !deckCards.isEmpty {
            withAnimation(.easeOut(duration: 0.3)) {
                let drawnCard = deckCards.removeFirst()
                var handCard = drawnCard
                handCard.location = .hand(playerIndex: playerIndex, cardIndex: players[playerIndex].hand.count)
                
                players[playerIndex].hand.append(handCard)
                players[playerIndex].hasDrawnCardThisTurn = true // カードを引いた状態を記録
                print("プレイヤー \(players[playerIndex].name) がカードを引きました: \(handCard.card.rawValue)")
            }
        } else {
            print("⚠️ デッキが空のため、カードを引けませんでした")
        }
    }
    
    /// 山札を再構築（場の一番上を残してシャッフル）
    private func reshuffleDeck() {
        guard fieldCards.count > 1 else {
            print("⚠️ 場のカードが不足しているため、山札を再構築できません")
            return
        }
        
        print("山札が空になりました。場のカードをシャッフルして山札を再構築します")
        
        // 場の一番上のカード以外を山札に戻す
        let cardsToReshuffle = Array(fieldCards.dropLast())
        fieldCards = Array(fieldCards.suffix(1)) // 最後の1枚のみ残す
        
        // カードの位置をデッキに変更してシャッフル
        var reshuffledCards = cardsToReshuffle.map { card in
            var deckCard = card
            deckCard.location = .deck
            deckCard.handRotation = 0 // 角度をリセット
            return deckCard
        }
        
        reshuffledCards.shuffle()
        deckCards = reshuffledCards
        
        print("山札を再構築しました。新しい山札枚数: \(deckCards.count)")
    }
    
    /// 出すアクションを処理
    func handlePlayAction() {
        // 🔥 どてんこ処理中は通常のカード出しを停止
        if gamePhase == .dotenkoProcessing {
            print("🛑 カード出し停止: どてんこ処理中のため処理をキャンセル")
            return
        }
        
        guard let currentPlayer = getCurrentPlayer() else { return }
        
        // 早い者勝ちの場合（カウントダウン中）
        if isWaitingForFirstCard {
            handleFirstCardPlay(player: currentPlayer)
            return
        }
        
        // 通常のターン制の場合
        if !canPlayerPerformAction(playerId: currentPlayer.id) {
            print("出すアクション拒否: プレイヤー \(currentPlayer.name) のターンではありません")
            return
        }
        
        handleNormalCardPlay(player: currentPlayer)
    }
    
    /// 最初のカード出し処理（早い者勝ち）
    private func handleFirstCardPlay(player: Player) {
        guard let playerIndex = players.firstIndex(where: { $0.id == player.id }) else { return }
        
        let selectedCount = getPlayerSelectedCardCount(playerId: player.id)
        print("最初のカード出し - プレイヤー \(player.name) の選択されたカード数: \(selectedCount)")
        
        // カウントダウンをキャンセル
        cancelCountdown()
        
        // 選択されたカードをフィールドに移動
        moveSelectedCardsToField(playerIndex: playerIndex, player: player)
        
        // このプレイヤーからターン開始
        startTurnFromPlayer(playerId: player.id)
        
        // 次のターンに進む
        nextTurn()
    }
    
    /// 通常のカード出し処理（ターン制）
    private func handleNormalCardPlay(player: Player) {
        guard let playerIndex = players.firstIndex(where: { $0.id == player.id }) else { return }
        
        let selectedCount = getPlayerSelectedCardCount(playerId: player.id)
        print("出すアクションが実行されました - プレイヤー \(player.name) の選択されたカード数: \(selectedCount)")
        
        // カード出し判定
        let validation = canPlaySelectedCards(playerId: player.id)
        
        if !validation.canPlay {
            // 出せない場合はエラーメッセージを表示
            showCardPlayError(message: validation.reason)
            print("カード出し拒否: \(validation.reason)")
            return
        }
        
        print("カード出し成功: \(validation.reason)")
        
        // 選択されたカードをフィールドに移動
        moveSelectedCardsToField(playerIndex: playerIndex, player: player)
        
        // 次のターンに進む
        nextTurn()
    }
    
    /// カード出しエラーメッセージを表示
    private func showCardPlayError(message: String) {
        // TODO: アラート表示機能を実装
        // 現在は仮でコンソール出力のみ
        print("⚠️ カード出しエラー: \(message)")
        
        // 将来的にはアラート表示やUI通知を実装
        // 例: showAlert = true, alertMessage = message
    }
    
    /// 選択されたカードをフィールドに移動する共通処理
    func moveSelectedCardsToField(playerIndex: Int, player: Player) {
        withAnimation(.easeOut) {
            let selectedCards = player.selectedCards
            for card in selectedCards {
                if let handIndex = players[playerIndex].hand.firstIndex(of: card) {
                    var movedCard = players[playerIndex].hand.remove(at: handIndex)
                    
                    // 手札の角度を保持してフィールドに移動
                    movedCard.location = .field
                    // 手札の角度に少しランダム性を追加して乱雑さを演出
                    let randomVariation = Double.random(in: -LayoutConstants.FieldCard.additionalRotationRange...LayoutConstants.FieldCard.additionalRotationRange)
                    movedCard.handRotation += randomVariation
                    
                    fieldCards.append(movedCard)
                    
                    // 上昇レート管理（最後に出されたカードで判定）
                    updateUpRateForCardPlay(card: movedCard)
                }
            }
            
            // 最後にカードを出したプレイヤーIDを記録（どてんこ制限用）
            lastCardPlayerId = player.id
            
            // プレイヤーがカードを出したフラグを設定（しょてんこボタン制御用）
            hasAnyPlayerPlayedCard = true
            
            print("🎴 カード出し記録: プレイヤー \(player.name) (ID: \(player.id))")
            print("🎴 プレイヤーカード出しフラグ: \(hasAnyPlayerPlayedCard)")
            print("🎴 しょてんこボタン表示: \(shouldShowShotenkoButton())")
            print("🎴 どてんこボタン表示: \(shouldShowDotenkoButton())")
            print("🎴 プレイヤーのしょてんこ条件: \(canPlayerDeclareShotenko(playerId: "player"))")
            print("🎴 プレイヤーのどてんこ条件: \(canPlayerDeclareDotenko(playerId: "player"))")
            
            // 選択をクリア
            clearPlayerSelectedCards(playerId: player.id)
            
            // 場のカードが変更されたのでどてんこチェックを実行
            onFieldCardChanged()
        }
    }
    
    /// デッキタップ時の処理
    func handleDeckTap() {
        withAnimation(.easeOut) {
            // TODO: カードを引く処理を実装
            print("デッキがタップされました - カードを引く処理")
            
            // デッキからカードを引く処理（仮の処理）
            if !deckCards.isEmpty,
               let currentPlayer = getCurrentPlayer(),
               let playerIndex = players.firstIndex(where: { $0.id == currentPlayer.id }) {
                let drawnCard = deckCards.removeFirst()
                players[playerIndex].hand.append(drawnCard)
                print("引いたカード: \(drawnCard.card.rawValue)")
            }
        }
    }
    
    /// 設定ボタンアクション
    func handleSettingsAction() {
        print("設定ボタンが押されました")
        showGameSettingsModal = true
    }
    
    /// ゲーム終了アクション
    func handleExitGame() {
        print("ゲームを終了します")
        // ゲーム終了処理をここに実装
        // 例: ナビゲーションの戻る処理など
    }
    
    // MARK: - Player Management Methods
    
    /// プレイヤーの手札を更新
    func updatePlayerHand(playerId: String, cards: [Card]) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].hand = cards
        }
    }
    
    /// プレイヤーの選択されたカードを更新
    func updatePlayerSelectedCards(playerId: String, cards: [Card]) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].selectedCards = cards
        }
    }
    
    /// プレイヤーのスコアを更新
    func updatePlayerScore(playerId: String, score: Int) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].score = score
        }
    }
    
    /// プレイヤーのランクを更新
    func updatePlayerRank(playerId: String, rank: Int) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].rank = rank
        }
    }
    
    /// プレイヤーのドテンコ状態を更新
    func updatePlayerDtnkStatus(playerId: String, dtnk: Bool) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].dtnk = dtnk
        }
    }
    
    /// 指定されたプレイヤーを取得
    func getPlayer(by id: String) -> Player? {
        return players.first { $0.id == id }
    }
    
    /// 現在のプレイヤーの手札を取得
    func getCurrentPlayerHand() -> [Card] {
        return getCurrentPlayer()?.hand ?? []
    }
    
    /// 現在のプレイヤーの選択されたカードを取得
    func getCurrentPlayerSelectedCards() -> [Card] {
        return getCurrentPlayer()?.selectedCards ?? []
    }
    
    /// カードの手札角度を記録する
    func updateCardHandRotation(playerId: String, cardId: UUID, rotation: Double) {
        if let playerIndex = players.firstIndex(where: { $0.id == playerId }),
           let cardIndex = players[playerIndex].hand.firstIndex(where: { $0.id == cardId }) {
            players[playerIndex].hand[cardIndex].handRotation = rotation
        }
    }
    
    // MARK: - Countdown System
    /// 5秒カウントダウンを開始
    func startCountdown() {
        countdownValue = 1
        isCountdownActive = true
        showCountdown = true
        isWaitingForFirstCard = true
        
        print("5秒カウントダウン開始")
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.countdownValue -= 1
            print("カウントダウン: \(self.countdownValue)")
            
            if self.countdownValue <= 0 {
                timer.invalidate()
                self.finishCountdown()
            }
        }
    }
    
    /// カウントダウン終了処理
    private func finishCountdown() {
        isCountdownActive = false
        showCountdown = false
        isWaitingForFirstCard = false
        
        print("カウントダウン終了 - 最初の場札をめくります")
        
        // 最初の場札を1枚めくる
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dealInitialFieldCard()
            
            // 場札配布後、ターンシステムを開始
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.resetTurn() // プレイヤー1からターン開始
                print("ターンシステム開始 - \(self.getCurrentTurnPlayer()?.name ?? "不明") のターンです")
                
                // 最初のプレイヤーがBOTの場合は自動処理を開始
                if let currentPlayer = self.getCurrentTurnPlayer(), currentPlayer.id != "player" {
                    self.startBotTurn(player: currentPlayer)
                }
            }
        }
    }
    
    /// カウントダウンをキャンセル（早い者勝ちでカードが出された場合）
    func cancelCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        isCountdownActive = false
        showCountdown = false
        isWaitingForFirstCard = false
        
        print("カウントダウンキャンセル - 早い者勝ちでゲーム開始")
    }
    
    // MARK: - Turn Management System
    /// 次のプレイヤーのターンに進む
    func nextTurn() {
        // 全プレイヤーのカード引き状態をリセット
        for index in players.indices {
            players[index].hasDrawnCardThisTurn = false
        }
        
        currentTurnPlayerIndex = (currentTurnPlayerIndex + 1) % players.count
        let currentPlayer = getCurrentTurnPlayer()
        print("ターン変更: プレイヤー\(currentTurnPlayerIndex + 1) (\(currentPlayer?.name ?? "不明")) のターン")
        print("   プレイヤーID: \(currentPlayer?.id ?? "不明")")
        print("   プレイヤータイプ: \(currentPlayer?.id == "player" ? "人間" : "BOT")")
        
        // BOTのターンの場合は自動処理を開始
        if let currentPlayer = getCurrentTurnPlayer(), currentPlayer.id != "player" {
            print("🤖 BOTターン検出 - 自動処理を開始します")
            startBotTurn(player: currentPlayer)
        } else {
            print("👤 人間プレイヤーのターン - 手動操作待ち")
        }
    }
    
    /// 現在のターンのプレイヤーを取得
    func getCurrentTurnPlayer() -> Player? {
        guard currentTurnPlayerIndex < players.count else { return nil }
        return players[currentTurnPlayerIndex]
    }
    
    /// 指定されたプレイヤーが現在のターンかチェック
    func isPlayerTurn(playerId: String) -> Bool {
        guard let currentPlayer = getCurrentTurnPlayer() else { return false }
        return currentPlayer.id == playerId
    }
    
    /// 最初にカードを出したプレイヤーからターンを開始
    func startTurnFromPlayer(playerId: String) {
        if let playerIndex = players.firstIndex(where: { $0.id == playerId }) {
            currentTurnPlayerIndex = playerIndex
            print("ターン開始: プレイヤー\(currentTurnPlayerIndex + 1) (\(getCurrentTurnPlayer()?.name ?? "不明")) から開始")
        }
    }
    
    /// ターンをリセット（ラウンド開始時など）
    func resetTurn() {
        // 全プレイヤーのカード引き状態をリセット
        for index in players.indices {
            players[index].hasDrawnCardThisTurn = false
        }
        
        currentTurnPlayerIndex = 0
        print("ターンリセット: プレイヤー1から開始")
    }
    
    /// 現在のターンプレイヤーのインデックスを取得
    func getCurrentTurnPlayerIndex() -> Int {
        return currentTurnPlayerIndex
    }
    
    // MARK: - Player Action Validation
    /// プレイヤーがアクションを実行できるかチェック
    func canPlayerPerformAction(playerId: String) -> Bool {
        // アナウンス中は操作不可
        if announcementEffectManager.isAnnouncementActive() {
            return false
        }
        
        // カウントダウン中や待機中は操作不可
        if isCountdownActive || isWaitingForFirstCard {
            return false
        }
        
        // 現在のターンのプレイヤーのみアクション可能
        return isPlayerTurn(playerId: playerId)
    }
    
    /// 早い者勝ちでカードを出せるかチェック（カウントダウン中のみ）
    func canPlayerPlayFirstCard(playerId: String) -> Bool {
        return isWaitingForFirstCard && !fieldCards.isEmpty == false
    }
    
    /// プレイヤーがこのターンでカードを引いたかチェック
    func hasPlayerDrawnCardThisTurn(playerId: String) -> Bool {
        guard let player = players.first(where: { $0.id == playerId }) else { return false }
        return player.hasDrawnCardThisTurn
    }
    
    // MARK: - Card Play Validation System
    
    /// 選択されたカードが出せるかチェック
    func canPlaySelectedCards(playerId: String) -> (canPlay: Bool, reason: String) {
        guard let player = players.first(where: { $0.id == playerId }) else {
            return (false, "プレイヤーが見つかりません")
        }
        
        let selectedCards = player.selectedCards
        
        // 場にカードがあるかチェック
        guard let fieldCard = fieldCards.last else {
            return (false, "場にカードがありません")
        }
        
        // カード出し判定マネージャーに委譲
        return cardValidationManager.canPlaySelectedCards(selectedCards: selectedCards, fieldCard: fieldCard)
    }
    

    

    
    /// カード出し判定結果の表示用メッセージを取得
    func getCardPlayValidationMessage(playerId: String) -> String {
        guard let player = players.first(where: { $0.id == playerId }) else {
            return "プレイヤーが見つかりません"
        }
        
        guard let fieldCard = fieldCards.last else {
            return "場にカードがありません"
        }
        
        // カード出し判定マネージャーに委譲
        return cardValidationManager.getCardPlayValidationMessage(selectedCards: player.selectedCards, fieldCard: fieldCard)
    }
    
    // MARK: - Dotenko Declaration System
    
    /// プレイヤーがどてんこ宣言できるかチェック
    func canPlayerDeclareDotenko(playerId: String) -> Bool {
        guard let player = players.first(where: { $0.id == playerId }) else { 
            print("🔍 どてんこ判定: プレイヤー \(playerId) が見つかりません")
            return false 
        }
        guard let fieldCard = fieldCards.last else { 
            print("🔍 どてんこ判定: 場にカードがありません")
            return false 
        }
        
        // 自分が出したカードにはどてんこ不可
        if let lastPlayerId = lastCardPlayerId, lastPlayerId == playerId {
            print("🔍 どてんこ判定: 自分が出したカードにはどてんこできません - プレイヤー: \(player.name)")
            return false
        }
        
        let fieldValue = fieldCard.card.handValue().first ?? 0
        let handTotals = calculateHandTotals(cards: player.hand)
        
        print("🔍 どてんこ判定 - プレイヤー: \(player.name)")
        print("   場のカード: \(fieldCard.card.rawValue) (値: \(fieldValue))")
        print("   手札の可能な合計値: \(handTotals)")
        print("   最後にカードを出したプレイヤー: \(lastCardPlayerId ?? "なし")")
        
        // 手札の合計値のいずれかが場のカードと一致するかチェック
        let canDeclare = handTotals.contains(fieldValue)
        print("   どてんこ宣言可能: \(canDeclare ? "✅" : "❌")")
        
        return canDeclare
    }
    
    /// 手札の合計値を計算（ジョーカー対応）
    func calculateHandTotals(cards: [Card]) -> [Int] {
        // カード出し判定マネージャーに委譲
        return cardValidationManager.calculateHandTotals(cards: cards)
    }
    

    
    /// どてんこ宣言を処理
    func handleDotenkoDeclaration(playerId: String) {
        guard let playerIndex = players.firstIndex(where: { $0.id == playerId }) else { return }
        guard canPlayerDeclareDotenko(playerId: playerId) else {
            print("⚠️ どてんこ宣言失敗: 条件を満たしていません - プレイヤー \(players[playerIndex].name)")
            return
        }
        
        // 宣言タイムスタンプを記録（複数同時宣言対応）
        let currentTime = Date()
        dotenkoDeclarationTimestamps[playerId] = currentTime
        
        print("🎉 どてんこ宣言成功! - プレイヤー \(players[playerIndex].name) (時刻: \(currentTime))")
        
        // どてんこ状態を更新
        players[playerIndex].dtnk = true
        
        // 最後の宣言者を勝者に設定（複数同時宣言の場合は最後の人が勝ち）
        updateDotenkoWinnerToLatest()
        
        // どてんこアニメーションを表示
        let playerName = players[playerIndex].name
        announcementEffectManager.showDeclarationAnimation(type: .dotenko, playerName: playerName) {
            // アニメーション完了後にゲーム処理を継続
            DispatchQueue.main.async {
                // どてんこ宣言時に全プレイヤーの処理を停止
                self.stopAllPlayerActions()
                
                // ゲームフェーズに応じて処理を分岐
                if self.gamePhase == .challengeZone {
                    // チャレンジゾーン中の場合
                    self.revengeManager.handleChallengeDotenkoDeclaration(playerId: playerId)
                } else {
                    // 通常のゲーム中の場合
                    self.revengeManager.startRevengeWaitingPhase()
                }
            }
        }
    }
    
    /// 最後にどてんこ宣言したプレイヤーを勝者に設定
    private func updateDotenkoWinnerToLatest() {
        // 宣言したプレイヤーの中で最も遅い時刻の人を勝者に設定
        let dotenkoPlayers = players.filter { $0.dtnk }
        guard !dotenkoPlayers.isEmpty else { return }
        
        var latestPlayer: Player?
        var latestTime: Date?
        
        for player in dotenkoPlayers {
            if let timestamp = dotenkoDeclarationTimestamps[player.id] {
                if latestTime == nil || timestamp > latestTime! {
                    latestTime = timestamp
                    latestPlayer = player
                }
            }
        }
        
        if let winner = latestPlayer {
            revengeManager.setDotenkoWinnerId(winner.id)
            print("🏆 最後のどてんこ宣言者が勝者: \(winner.name)")
        }
    }
    
    /// どてんこ勝利処理
    private func handleDotenkoVictory(winnerId: String) {
        // 勝者の設定
        if let winnerIndex = players.firstIndex(where: { $0.id == winnerId }) {
            players[winnerIndex].rank = 1
            print("🏆 どてんこ勝者: \(players[winnerIndex].name)")
        }
        
        // 場のカードを出したプレイヤーを敗者に設定
        // 現在のターンプレイヤーが場のカードを出したプレイヤーと仮定
        if let currentTurnPlayer = getCurrentTurnPlayer(),
           currentTurnPlayer.id != winnerId {
            if let loserIndex = players.firstIndex(where: { $0.id == currentTurnPlayer.id }) {
                players[loserIndex].rank = players.count // 最下位
                print("💀 敗者（場のカードを出した人）: \(players[loserIndex].name)")
            }
        }
        
        // その他のプレイヤーは中間順位
        for index in players.indices {
            if players[index].rank == 0 { // まだ順位が決まっていないプレイヤー
                players[index].rank = 2
            }
        }
        
        // ゲーム終了処理
        gamePhase = .finished
        print("🎮 ラウンド終了 - どてんこによる勝敗確定")
        
        // スコア計算を開始
        startScoreCalculation()
    }
    
    /// 現在のプレイヤーがどてんこ宣言できるかチェック
    func canCurrentPlayerDeclareDotenko() -> Bool {
        guard let currentPlayer = getCurrentPlayer() else { return false }
        return canPlayerDeclareDotenko(playerId: currentPlayer.id)
    }
    
    /// どてんこ宣言ボタンを表示すべきかチェック
    func shouldShowDotenkoButton() -> Bool {
        // アナウンス中は表示しない
        if announcementEffectManager.isAnnouncementActive() {
            return false
        }
        
        // しょてんこボタンが表示されている場合は表示しない（競合回避）
        if shouldShowShotenkoButton() {
            return false
        }
        
        // 通常のゲーム進行中で、どてんこ条件を満たす場合のみ表示
        if gamePhase == .playing {
            return canPlayerDeclareDotenko(playerId: "player")
        }
        
        // チャレンジゾーン中で自分のターンの場合
        if gamePhase == .challengeZone && isChallengeZone {
            guard let currentPlayer = revengeManager.getCurrentChallengePlayer() else { return false }
            if currentPlayer.id == "player" {
                return canPlayerDeclareDotenko(playerId: "player")
            }
        }
        
        return false
    }
    
    /// 全プレイヤーのどてんこ宣言可能状況をチェック（リアルタイム用）
    func getPlayersWhoCanDeclareDotenko() -> [String] {
        guard gamePhase == .playing && !fieldCards.isEmpty else { return [] }
        
        var eligiblePlayers: [String] = []
        for player in players {
            if canPlayerDeclareDotenko(playerId: player.id) {
                eligiblePlayers.append(player.id)
            }
        }
        return eligiblePlayers
    }
    
    /// どてんこ宣言可能なプレイヤーがいるかチェック
    func hasAnyPlayerWhoCanDeclareDotenko() -> Bool {
        return !getPlayersWhoCanDeclareDotenko().isEmpty
    }
    
    /// BOTプレイヤーのどてんこ宣言チェック（リアルタイム）
    func checkBotDotenkoDeclarations() {
        let gameState = createBotGameState()
        botManager.checkRealtimeDotenkoDeclarations(players: players, gameState: gameState) { [weak self] declaringBotIds in
            for botId in declaringBotIds {
                self?.handleDotenkoDeclaration(playerId: botId)
            }
        }
    }
    
    /// 場のカードが変更された時の処理（どてんこチェック用）
    func onFieldCardChanged() {
        // BOTのどてんこ宣言チェック
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkBotDotenkoDeclarations()
        }
    }

    
    /// どてんこ勝利を確定
    func finalizeDotenko() {
        // ゲーム終了処理
        gamePhase = .finished
        
        // 勝敗設定（しょてんこ・バーストの場合は既に設定済み、通常のどてんこの場合は設定）
        if !isShotenkoRound && !isBurst {
            // 通常のどてんこの場合の勝敗設定
            setDotenkoVictoryRanks()
        }
        
        print("🎮 ゲーム終了 - どてんこ勝利確定")
        
        // スコア計算を開始
        startScoreCalculation()
    }
    
    /// 通常のどてんこ勝敗設定
    private func setDotenkoVictoryRanks() {
        guard let winnerId = revengeManager.dotenkoWinnerId else { return }
        
        // 勝者の設定
        if let winnerIndex = players.firstIndex(where: { $0.id == winnerId }) {
            players[winnerIndex].rank = 1
            print("🏆 どてんこ勝者: \(players[winnerIndex].name)")
        }
        
        // 場のカードを出したプレイヤーを敗者に設定
        // 現在のターンプレイヤーが場のカードを出したプレイヤーと仮定
        if let currentTurnPlayer = getCurrentTurnPlayer(),
           currentTurnPlayer.id != winnerId {
            if let loserIndex = players.firstIndex(where: { $0.id == currentTurnPlayer.id }) {
                players[loserIndex].rank = players.count // 最下位
                print("💀 敗者（場のカードを出した人）: \(players[loserIndex].name)")
            }
        }
        
        // その他のプレイヤーは中間順位
        for index in players.indices {
            if players[index].rank == 0 { // まだ順位が決まっていないプレイヤー
                players[index].rank = 2
            }
        }
    }
    
    /// リベンジボタンを表示すべきかチェック
    func shouldShowRevengeButton(for playerId: String) -> Bool {
        return revengeManager.shouldShowRevengeButton(for: playerId)
    }
    
    /// リベンジ宣言を処理
    func handleRevengeDeclaration(playerId: String) {
        revengeManager.handleRevengeDeclaration(playerId: playerId)
    }
    
    /// プレイヤーがリベンジ宣言できるかチェック
    func canPlayerDeclareRevenge(playerId: String) -> Bool {
        return revengeManager.canPlayerDeclareRevenge(playerId: playerId)
    }
    
    /// 現在のチャレンジプレイヤーを取得
    func getCurrentChallengePlayer() -> Player? {
        return revengeManager.getCurrentChallengePlayer()
    }
    
    /// プレイヤーがチャレンジゾーンでカードを引く
    func handleChallengeDrawCard() {
        revengeManager.handleChallengeDrawCard()
    }
    
    // MARK: - Challenge Zone Participation Modal System
    
    /// プレイヤーの参加選択を処理
    func handlePlayerParticipationChoice(playerId: String, choice: ChallengeZoneParticipationModal.ParticipationChoice) {
        revengeManager.handlePlayerParticipationChoice(playerId: playerId, choice: choice)
    }
    
    /// 参加モーダルのタイムアウト処理
    func handleParticipationModalTimeout() {
        revengeManager.handleParticipationModalTimeout()
    }
    
    // MARK: - Shotenko & Burst System
    
    /// しょてんこ宣言をチェック（最初の場札配布後）
    private func checkShotenkoDeclarations() {
        guard isFirstCardDealt && !fieldCards.isEmpty else { return }
        guard let fieldCard = fieldCards.first else { return }
        
        let fieldValue = fieldCard.card.handValue().first ?? 0
        print("🎯 しょてんこ判定開始 - 最初の場札: \(fieldCard.card.rawValue) (値: \(fieldValue))")
        
        // BOTプレイヤーのしょてんこ判定のみ実行
        for player in players {
            let handTotals = calculateHandTotals(cards: player.hand)
            print("   プレイヤー \(player.name): 手札合計値 \(handTotals)")
            
            if handTotals.contains(fieldValue) {
                print("🎊 しょてんこ発生! - プレイヤー \(player.name)")
                
                // BOTの場合は1-3秒の遅延後に宣言、人間プレイヤーは手動宣言のみ
                if player.id != "player" {
                    let delay = Double.random(in: 1.0...3.0)
                    print("🤖 BOT \(player.name) のしょてんこ宣言遅延: \(String(format: "%.1f", delay))秒")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        // 遅延後に条件を再確認（他のプレイヤーが先に宣言していないかチェック）
                        if !self.isShotenkoRound && self.canPlayerDeclareShotenko(playerId: player.id) {
                            self.handleShotenkoDeclaration(playerId: player.id)
                        }
                    }
                    return // BOTが宣言予定なら処理終了
                } else {
                    print("👤 プレイヤーのしょてんこ条件検出 - 手動宣言待ち")
                    // 人間プレイヤーは自動宣言しない（手動宣言のみ）
                }
            }
        }
        
        print("✅ しょてんこなし - 通常ゲーム開始")
    }
    
    /// しょてんこ宣言を処理
    private func handleShotenkoDeclaration(playerId: String) {
        guard let playerIndex = players.firstIndex(where: { $0.id == playerId }) else { return }
        
        print("🎊 しょてんこ宣言成功! - プレイヤー \(players[playerIndex].name)")
        
        // しょてんこ状態を設定
        isShotenkoRound = true
        shotenkoWinnerId = playerId
        players[playerIndex].dtnk = true
        players[playerIndex].rank = 1 // 勝者
        
        // その他全員を敗者に設定
        for index in players.indices {
            if players[index].id != playerId {
                players[index].rank = players.count // 最下位
            }
        }
        
        print("🏆 しょてんこ勝者: \(players[playerIndex].name)")
        print("💀 しょてんこ敗者: その他全員")
        
        // しょてんこアニメーションを表示
        let playerName = players[playerIndex].name
        announcementEffectManager.showDeclarationAnimation(type: .shotenko, playerName: playerName) {
            // アニメーション完了後にチャレンジゾーンを開始
            DispatchQueue.main.async {
                // しょてんこ宣言時に全プレイヤーの処理を停止
                self.stopAllPlayerActions()
                
                // チャレンジゾーンを開始（しょてんこでもチャレンジゾーン発生）
                self.revengeManager.startChallengeZone()
            }
        }
    }
    
    /// バーストイベントを処理
    func handleBurstEvent(playerId: String) {
        guard let playerIndex = players.firstIndex(where: { $0.id == playerId }) else { return }
        
        print("💥 バースト発生! - プレイヤー \(players[playerIndex].name)")
        
        // バースト状態を設定
        isBurst = true
        burstPlayerId = playerId
        players[playerIndex].rank = players.count // 敗者（最下位）
        
        // その他全員を勝者に設定
        for index in players.indices {
            if players[index].id != playerId {
                players[index].rank = 1 // 勝者
            }
        }
        
        print("💀 バースト敗者: \(players[playerIndex].name)")
        print("🏆 バースト勝者: その他全員")
        
        // バースト発生アナウンス
        announcementEffectManager.showAnnouncementMessage(
            title: "バースト発生！",
            subtitle: "\(players[playerIndex].name) の敗北"
        ) {
            // バーストの場合はチャレンジゾーンをスキップして直接スコア確定
            self.gamePhase = .finished
            print("🎮 ラウンド終了 - バーストによる勝敗確定（チャレンジゾーンスキップ）")
            
            // スコア計算を開始（正しい流れでスコア確定画面を表示）
            self.startScoreCalculation()
        }
    }
    
    /// プレイヤーがしょてんこ宣言できるかチェック（最初の場札のみ）
    func canPlayerDeclareShotenko(playerId: String) -> Bool {
        guard isFirstCardDealt && !isShotenkoRound else { return false }
        guard let player = players.first(where: { $0.id == playerId }) else { return false }
        guard let fieldCard = fieldCards.first else { return false }
        
        // 誰かがカードを出した後はしょてんこ不可
        if hasAnyPlayerPlayedCard {
            return false
        }
        
        let fieldValue = fieldCard.card.handValue().first ?? 0
        let handTotals = calculateHandTotals(cards: player.hand)
        
        return handTotals.contains(fieldValue)
    }
    
    /// しょてんこボタンを表示すべきかチェック
    func shouldShowShotenkoButton() -> Bool {
        // アナウンス中は表示しない
        if announcementEffectManager.isAnnouncementActive() {
            return false
        }
        
        // しょてんこラウンドが既に発生している場合は表示しない
        if isShotenkoRound {
            return false
        }
        
        // 誰かがカードを出した後は表示しない（どてんこボタンに切り替え）
        if hasAnyPlayerPlayedCard {
            return false
        }
        
        // 通常のゲーム進行中のみ表示
        if gamePhase != .playing {
            return false
        }
        
        // 最初の場札が配布されていて、プレイヤーがしょてんこ条件を満たす場合のみ表示
        return isFirstCardDealt && canPlayerDeclareShotenko(playerId: "player")
    }
    
    /// プレイヤーのしょてんこ宣言を処理（手動宣言用）
    func handlePlayerShotenkoDeclaration(playerId: String) {
        guard canPlayerDeclareShotenko(playerId: playerId) else {
            print("⚠️ しょてんこ宣言失敗: 条件を満たしていません")
            return
        }
        
        handleShotenkoDeclaration(playerId: playerId)
    }
    

    
    // MARK: - Score Calculation System
    
    // スコア計算システム（マネージャーに委譲）
    var currentUpRate: Int { scoreCalculationManager.currentUpRate }
    var consecutiveCardCount: Int { scoreCalculationManager.consecutiveCardCount }
    var lastPlayedCardValue: Int? { scoreCalculationManager.lastPlayedCardValue }
    var roundScore: Int { scoreCalculationManager.roundScore }
    var showScoreResult: Bool { scoreCalculationManager.showScoreResult }
    var scoreResultData: ScoreResultData? { scoreCalculationManager.scoreResultData }
    var consecutiveSpecialCards: [Card] { scoreCalculationManager.consecutiveSpecialCards }
    
    /// ラウンド終了時のスコア計算を開始
    func startScoreCalculation() {
        print("💰 スコア計算開始 - 元の自動遷移システムを使用")
        
        // デッキの裏カードを取得
        let bottomCard: Card
        if !deckCards.isEmpty {
            bottomCard = deckCards.last!
        } else if !fieldCards.isEmpty {
            bottomCard = fieldCards.first!
        } else {
            print("⚠️ デッキも場も空のため、スコア計算をスキップします")
            finishScoreCalculation()
            return
        }
        
        // 直接スコア確定画面データを作成して自動遷移
        scoreCalculationManager.calculateFinalScoreWithData(
            bottomCard: bottomCard,
            baseRate: Int(gameRuleInfo.gameRate) ?? 1,
            maxScore: gameRuleInfo.maxScore,
            players: players,
            isShotenkoRound: isShotenkoRound,
            isBurst: isBurst,
            shotenkoWinnerId: shotenkoWinnerId,
            burstPlayerId: burstPlayerId
        )
        
        print("💰 スコア計算完了 - 自動遷移開始")
    }
    

    

    
    /// 勝敗逆転処理（黒3効果）
    private func reverseWinLose() {
        print("🔄 勝敗逆転処理開始")
        
        // 現在の勝者と敗者を入れ替え
        var winners: [Int] = []
        var losers: [Int] = []
        
        for (index, player) in players.enumerated() {
            if player.rank == 1 {
                winners.append(index)
            } else if player.rank == players.count {
                losers.append(index)
            }
        }
        
        // 勝者を敗者に、敗者を勝者に変更
        for winnerIndex in winners {
            players[winnerIndex].rank = players.count // 敗者に
        }
        
        for loserIndex in losers {
            players[loserIndex].rank = 1 // 勝者に
        }
        
        print("🔄 勝敗逆転完了")
    }
    

    
    /// スコア確定画面のOKボタン処理
    func onScoreResultOK() {
        print("✅ スコア確定画面 - OKボタンタップ")
        scoreCalculationManager.clearScoreResult()
        
        // スコアをプレイヤーに適用
        applyScoreToPlayers()
        
        // 次の画面に遷移
        finishScoreCalculation()
    }
    
    /// プレイヤーにスコアを適用
    private func applyScoreToPlayers() {
        // しょてんこの場合の特別計算
        if isShotenkoRound, let shotenkoWinnerId = shotenkoWinnerId {
            applyShotenkoScore(winnerId: shotenkoWinnerId)
            return
        }
        
        // バーストの場合の特別計算
        if isBurst, let burstPlayerId = burstPlayerId {
            applyBurstScore(burstPlayerId: burstPlayerId)
            return
        }
        
        // 通常のどてんこの場合
        for index in players.indices {
            let player = players[index]
            
            if player.rank == 1 {
                // 勝者：スコアを獲得
                players[index].score += roundScore
                print("🏆 \(player.name) がスコア獲得: +\(roundScore)")
            } else if player.rank == players.count {
                // 敗者：スコアを失う
                players[index].score -= roundScore
                print("💀 \(player.name) がスコア失失: -\(roundScore)")
            }
            // 中間順位は変動なし
        }
    }
    
    /// しょてんこのスコア計算
    /// しょてんこした人が他の全プレイヤーからラウンドスコアを受け取る
    /// 例：ラウンドスコア1000、プレイヤー5人の場合
    /// しょてんこした人：+4000（1000×4人分）
    /// その他の人：-1000（各自）
    private func applyShotenkoScore(winnerId: String) {
        let otherPlayersCount = players.count - 1
        let shotenkoWinnerGain = roundScore * otherPlayersCount
        
        for index in players.indices {
            let player = players[index]
            
            if player.id == winnerId {
                // しょてんこした人：他の全プレイヤー分のスコアを獲得
                players[index].score += shotenkoWinnerGain
                print("🎊 しょてんこ勝者 \(player.name): +\(shotenkoWinnerGain) (基本スコア\(roundScore) × \(otherPlayersCount)人分)")
            } else {
                // その他のプレイヤー：ラウンドスコアを失う
                players[index].score -= roundScore
                print("💀 しょてんこ敗者 \(player.name): -\(roundScore)")
            }
        }
    }
    
    /// バーストのスコア計算
    /// バーストした人が他の全プレイヤーにラウンドスコアを支払う
    /// 例：ラウンドスコア1000、プレイヤー5人の場合
    /// バーストした人：-4000（1000×4人分）
    /// その他の人：+1000（各自）
    private func applyBurstScore(burstPlayerId: String) {
        let otherPlayersCount = players.count - 1
        let burstPlayerLoss = roundScore * otherPlayersCount
        
        for index in players.indices {
            let player = players[index]
            
            if player.id == burstPlayerId {
                // バーストした人：他の全プレイヤー分のスコアを失う
                players[index].score -= burstPlayerLoss
                print("💥 バースト敗者 \(player.name): -\(burstPlayerLoss) (基本スコア\(roundScore) × \(otherPlayersCount)人分)")
            } else {
                // その他のプレイヤー：ラウンドスコアを獲得
                players[index].score += roundScore
                print("🏆 バースト勝者 \(player.name): +\(roundScore)")
            }
        }
    }
    
    /// スコア計算完了処理
    private func finishScoreCalculation() {
        // 次のラウンドまたはゲーム終了判定
        if currentRound < totalRounds {
            // 直接中間結果画面を表示
            prepareNextRound()
        } else {
            // ゲーム終了 - 直接最終結果画面を表示
            print("🎮 全ラウンド終了 - 最終結果画面を表示")
            showFinalResults()
        }
    }
    
    /// 次のラウンド準備
    private func prepareNextRound() {
        // 中間結果画面を表示（lastRoundScoreの設定は不要 - revealedCardsから動的計算）
        showInterimResult = true
        playersReadyCount = 0
        isWaitingForOthers = false
        
        print("📊 中間結果画面表示 - ラウンド \(currentRound) 終了")
        print("📊 計算されたラウンドスコア: \(roundScore)")
        
        // BOTプレイヤーは自動的にOKを押す（3秒後）
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.handleBotPlayersOK()
        }
    }
    
    /// 中間結果画面のOKボタン処理
    func handleInterimResultOK() {
        // スコアに基づいてランクを再計算
        updatePlayerRanksByScore()
        
        playersReadyCount += 1
        print("✅ プレイヤーOK - 現在の準備完了数: \(playersReadyCount)/\(players.count)")
        
        // 全プレイヤーが準備完了したかチェック
        if playersReadyCount >= players.count {
            proceedToNextRound()
        } else {
            isWaitingForOthers = true
        }
    }
    
    /// スコアに基づいてプレイヤーのランクを更新
    private func updatePlayerRanksByScore() {
        // スコア順でソート（降順：高いスコアが上位）
        let sortedPlayers = players.sorted { $0.score > $1.score }
        
        // ランクを設定（同点の場合は同じランク）
        var currentRank = 1
        var previousScore: Int? = nil
        
        for (index, sortedPlayer) in sortedPlayers.enumerated() {
            // 同点でない場合はランクを更新
            if let prevScore = previousScore, sortedPlayer.score != prevScore {
                currentRank = index + 1
            }
            
            // 該当プレイヤーのランクを更新
            if let playerIndex = players.firstIndex(where: { $0.id == sortedPlayer.id }) {
                players[playerIndex].rank = currentRank
            }
            
            previousScore = sortedPlayer.score
        }
        
        print("🏆 スコアに基づくランク更新完了:")
        for player in players.sorted(by: { $0.rank < $1.rank }) {
            print("   \(player.name): \(player.score)点 - \(player.rank)位")
        }
    }
    
    /// BOTプレイヤーの自動OK処理
    private func handleBotPlayersOK() {
        let botCount = players.count - 1 // 人間プレイヤー以外
        playersReadyCount += botCount
        
        print("🤖 BOTプレイヤー自動OK - 準備完了数: \(playersReadyCount)/\(players.count)")
        
        // 人間プレイヤーがまだOKしていない場合は待機状態に
        if playersReadyCount < players.count {
            isWaitingForOthers = false // 人間プレイヤーの操作を待つ
        } else {
            proceedToNextRound()
        }
    }
    
    /// 次のラウンドに進む
    private func proceedToNextRound() {
        showInterimResult = false
        isWaitingForOthers = false
        
        // ゲーム状態をリセット
        currentRound += 1
        gamePhase = .waiting
        
        // プレイヤー状態をリセット
        for index in players.indices {
            players[index].hand.removeAll()
            players[index].selectedCards.removeAll()
            players[index].dtnk = false
            players[index].rank = 0
        }
        
        // カード状態をリセット
        fieldCards.removeAll()
        deckCards.removeAll()
        
        // スコア計算状態をリセット
        scoreCalculationManager.resetScoreCalculation()
        scoreCalculationManager.consecutiveSpecialCards.removeAll()
        
        // リベンジ・チャレンジ状態をリセット
        revengeManager.resetRevengeAndChallengeState()
        
        // しょてんこ・バースト状態をリセット
        isShotenkoRound = false
        shotenkoWinnerId = nil
        burstPlayerId = nil
        isFirstCardDealt = false
        isBurst = false
        
        // ゲーム状態フラグをリセット
        hasAnyPlayerPlayedCard = false
        lastCardPlayerId = nil
        dotenkoDeclarationTimestamps.removeAll()
        
        print("🎮 次のラウンド開始 - ラウンド \(currentRound)")
        
        // 新しいラウンド開始
        initializeGame()
    }
    
    /// 最終結果表示
    private func showFinalResults() {
        print("🎮 ゲーム完全終了 - 最終結果表示")
        showFinalResult = true
    }
    
    /// 最終結果画面のOKボタン処理
    func handleFinalResultOK() {
        print("✅ 最終結果画面 - ホームに戻る")
        showFinalResult = false
        
        // ナビゲーションでホーム画面に戻る
        DispatchQueue.main.async {
            NavigationAllViewStateManager.shared.popToRoot()
        }
    }
    
    /// 全プレイヤーの処理を停止（どてんこ宣言時）
    func stopAllPlayerActions() {
        print("🛑 全プレイヤーの処理を停止")
        
        // BOTの処理を停止
        gameBotManager.stopAllBotActions()
        
        // プレイヤーの操作を無効化（アニメーション中フラグで制御）
        // isAnnouncementBlocking が true の間は全ての操作が無効化される
        
        print("   BOT処理停止完了")
        print("   プレイヤー操作無効化完了")
    }
    
    /// ゲーム中の上昇レート管理
    func updateUpRateForCardPlay(card: Card) {
        let cardValue = card.card.handValue().first ?? 0
        
        // スコア計算マネージャーに委譲
        scoreCalculationManager.updateUpRateForCardPlay(card: card, gameRuleInfo: gameRuleInfo) { [weak self] multiplier in
            // 上昇レート演出（矢印エフェクト）
            self?.announcementEffectManager.showRateUpEffect(multiplier: multiplier)
        }
    }
    
    /// 特殊カード演出を表示
    private func showSpecialCardEffect(title: String, subtitle: String, effectType: GameAnnouncementEffectManager.SpecialCardEffectType, completion: @escaping () -> Void) {
        // アナウンス・エフェクトマネージャーに委譲
        announcementEffectManager.showSpecialCardEffect(title: title, subtitle: subtitle, effectType: effectType, completion: completion)
    }
    
    /// ゲーム開始時の上昇レート判定（1、2、ジョーカー）
    private func checkGameStartUpRate(card: Card) {
        // スコア計算マネージャーに委譲
        scoreCalculationManager.checkGameStartUpRate(card: card) { [weak self] multiplier in
            // 上昇レート演出（矢印エフェクト）
            self?.announcementEffectManager.showRateUpEffect(multiplier: multiplier)
            
            // 連続確認（現在のカードは既に処理済みなので、次のカードから開始）
            self?.checkConsecutiveGameStartCardsAfterProcessing(processedCard: card)
        }
    }
    
    /// ゲーム開始時の連続特殊カード確認（処理済みカード除外後）
    private func checkConsecutiveGameStartCardsAfterProcessing(processedCard: Card) {
        // 処理済みカードをデッキから削除
        if let currentIndex = deckCards.firstIndex(where: { $0.id == processedCard.id }) {
            deckCards.remove(at: currentIndex)
            print("🗑️ 処理済みカードをデッキから削除: \(processedCard.card.rawValue)")
        }
        
        // デッキが空になった場合は終了
        guard !deckCards.isEmpty else { 
            print("🔄 デッキが空になったため連続確認を終了")
            return 
        }
        
        // 次のカードを取得（デッキの最後から）
        let nextCard = deckCards.last!
        
        print("🔍 次のカード確認: \(nextCard.card.rawValue)")
        
        // 連続特殊カード判定（スコア計算マネージャーに委譲）
        scoreCalculationManager.checkConsecutiveGameStartCard(card: nextCard) { [weak self] multiplier in
            // 連続ボーナス演出（矢印エフェクト）
            self?.announcementEffectManager.showRateUpEffect(multiplier: multiplier)
            
            // 連続確認を継続（次のカードで再帰）
            self?.checkConsecutiveGameStartCardsAfterProcessing(processedCard: nextCard)
        } onEnd: {
            print("🔄 連続特殊カード終了 - 通常カード: \(nextCard.card.rawValue)")
        }
    }
    

    
    // MARK: - BOT思考システム
    
    /// BOTのターンを開始
    func startBotTurn(player: Player) {
        gameBotManager.startBotTurn(player: player)
    }
    
    /// BotGameStateを作成
    func createBotGameState() -> BotGameState {
        return BotGameState(
            fieldCards: fieldCards,
            deckCards: deckCards,
            gamePhase: gamePhase,
            isAnnouncementBlocking: isAnnouncementBlocking,
            isCountdownActive: isCountdownActive,
            isWaitingForFirstCard: isWaitingForFirstCard,
            dotenkoWinnerId: dotenkoWinnerId,
            revengeEligiblePlayers: revengeEligiblePlayers,
            challengeParticipants: challengeParticipants,
            validateCardPlayRules: { [weak self] cards, fieldCard in
                return self?.cardValidationManager.canPlaySelectedCards(selectedCards: cards, fieldCard: fieldCard) ?? (canPlay: false, reason: "ゲーム状態エラー")
            },
            canPlayerDeclareDotenko: { [weak self] playerId in
                return self?.canPlayerDeclareDotenko(playerId: playerId) ?? false
            },
            canPlayerDeclareRevenge: { [weak self] playerId in
                return self?.revengeManager.canPlayerDeclareRevenge(playerId: playerId) ?? false
            },
            calculateHandTotals: { [weak self] cards in
                return self?.cardValidationManager.calculateHandTotals(cards: cards) ?? []
            }
        )
    }
    
    /// スコア計算マネージャーの状態変更監視を設定
    private func setupScoreCalculationBinding() {
        // showScoreResultの変更を監視
        scoreCalculationManager.$showScoreResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showScoreResult in
                print("🎯 GameViewModel - showScoreResult変更検知: \(showScoreResult)")
                if showScoreResult {
                    print("🎯 GameViewModel - スコア確定画面表示要求を受信")
                    // 必要に応じて追加の処理を実行
                    self?.objectWillChange.send() // SwiftUIに変更を通知
                }
            }
            .store(in: &cancellables)
        
        // scoreResultDataの変更も監視
        scoreCalculationManager.$scoreResultData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] scoreResultData in
                print("🎯 GameViewModel - scoreResultData変更検知: \(scoreResultData != nil ? "データ設定済み" : "nil")")
                if scoreResultData != nil {
                    print("🎯 GameViewModel - スコア確定画面データ設定完了")
                    self?.objectWillChange.send() // SwiftUIに変更を通知
                }
            }
            .store(in: &cancellables)
        
        print("🎯 GameViewModel - スコア計算マネージャーの状態監視設定完了")
    }
} 
