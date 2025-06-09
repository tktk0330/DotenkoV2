import SwiftUI
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
    
    // リベンジシステム
    @Published var revengeCountdown: Int = 5
    @Published var isRevengeWaiting: Bool = false
    @Published var dotenkoWinnerId: String? = nil
    @Published var revengeEligiblePlayers: [String] = []
    
    // チャレンジゾーンシステム
    @Published var isChallengeZone: Bool = false
    @Published var challengeParticipants: [String] = []
    @Published var currentChallengePlayerIndex: Int = 0
    @Published var challengeRoundCount: Int = 0
    
    // しょてんこ・バーストシステム
    @Published var isShotenkoRound: Bool = false
    @Published var shotenkoWinnerId: String? = nil
    @Published var burstPlayerId: String? = nil
    @Published var isFirstCardDealt: Bool = false
    @Published var isBurst: Bool = false
    
    // アナウンスシステム
    @Published var showAnnouncement: Bool = false
    @Published var announcementText: String = ""
    @Published var announcementSubText: String = ""
    @Published var isAnnouncementBlocking: Bool = false
    
    // レートアップエフェクトシステム
    @Published var showRateUpEffect: Bool = false
    @Published var rateUpMultiplier: Int = 1
    private var rateUpEffectTimer: Timer?
    
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
    private var countdownTimer: Timer?
    private var revengeTimer: Timer?
    
    // MARK: - Lifecycle
    deinit {
        // タイマーのクリーンアップ
        countdownTimer?.invalidate()
        revengeTimer?.invalidate()
        rateUpEffectTimer?.invalidate()
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
    }
    
    // MARK: - Game Initialization
    func initializeGame() {
        setupGameInfo()
        setupPlayers()
        setupDeck()
        // 初期カード配布はアニメーション付きで実行
        gamePhase = .playing
        
        // ラウンド開始アナウンス
        showAnnouncementMessage(
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
        
        // スコア計算システムの初期化
        currentUpRate = 1
        consecutiveCardCount = 0
        lastPlayedCardValue = nil
        roundScore = 0
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
        for i in 0..<min(neededBots, availableBots.count) {
            let bot = availableBots[i]
            let botPlayer = Player(
                id: bot.id,
                side: players.count,
                name: bot.name,
                icon_url: bot.icon_url,
                dtnk: false
            )
            players.append(botPlayer)
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
        let botPlayers = players.filter { $0.id.hasPrefix("bot-") }
        
        switch maxPlayers {
        case 2:
            return Array(botPlayers.prefix(1))
        case 3:
            return Array(botPlayers.prefix(2))
        case 4:
            return Array(botPlayers.prefix(1))
        case 5:
            return Array(botPlayers.prefix(2))
        default:
            return Array(botPlayers.prefix(1))
        }
    }
    
    /// 左側プレイヤーを取得
    func getLeftPlayers() -> [Player] {
        let botPlayers = players.filter { $0.id.hasPrefix("bot-") }
        
        switch maxPlayers {
        case 4:
            return Array(botPlayers.dropFirst(1).prefix(1))
        case 5:
            return Array(botPlayers.dropFirst(2).prefix(1))
        default:
            return []
        }
    }
    
    /// 右側プレイヤーを取得
    func getRightPlayers() -> [Player] {
        let botPlayers = players.filter { $0.id.hasPrefix("bot-") }
        
        switch maxPlayers {
        case 4:
            return Array(botPlayers.dropFirst(2).prefix(1))
        case 5:
            return Array(botPlayers.dropFirst(3).prefix(1))
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
            showAnnouncementMessage(
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
    private func drawCardFromDeck(playerId: String) {
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
    private func moveSelectedCardsToField(playerIndex: Int, player: Player) {
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
        print("ターン変更: プレイヤー\(currentTurnPlayerIndex + 1) (\(getCurrentTurnPlayer()?.name ?? "不明")) のターン")
        
        // BOTのターンの場合は自動処理を開始
        if let currentPlayer = getCurrentTurnPlayer(), currentPlayer.id != "player" {
            startBotTurn(player: currentPlayer)
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
        if isAnnouncementBlocking {
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
        
        // カードが選択されているかチェック
        if selectedCards.isEmpty {
            return (false, "カードが選択されていません")
        }
        
        // 場にカードがあるかチェック
        guard let fieldCard = fieldCards.last else {
            return (false, "場にカードがありません")
        }
        
        // カード出しルールの検証
        return validateCardPlayRules(selectedCards: selectedCards, fieldCard: fieldCard)
    }
    
    /// カード出しルールの検証
    private func validateCardPlayRules(selectedCards: [Card], fieldCard: Card) -> (canPlay: Bool, reason: String) {
        let fieldCardValue = fieldCard.card.handValue().first ?? 0
        let fieldCardSuit = fieldCard.card.suit()
        
        print("🔍 カード出し判定開始")
        print("   場のカード: \(fieldCard.card.rawValue) (数字:\(fieldCardValue), スート:\(fieldCardSuit.rawValue))")
        print("   選択カード: \(selectedCards.map { "\($0.card.rawValue)" }.joined(separator: ", "))")
        
        // ルール1: 同じ数字（1枚）
        if selectedCards.count == 1 {
            let selectedCard = selectedCards[0]
            print("   ルール1チェック: 1枚のカード")
            
            // ジョーカーの場合は常に出せる
            if selectedCard.card.suit() == .joker {
                print("   ✅ ジョーカーのため出せます")
                return (true, "ジョーカーは任意のカードとして出せます")
            }
            
            // 同じ数字チェック
            if selectedCard.card.handValue().contains(fieldCardValue) {
                print("   ✅ 同じ数字のため出せます")
                return (true, "同じ数字のカードです")
            }
            
            // 同じスートチェック
            if selectedCard.card.suit() == fieldCardSuit {
                print("   ✅ 同じスートのため出せます")
                return (true, "同じスートのカードです")
            }
            
            print("   ❌ ルール1: 条件に合いません")
        }
        
        // 複数枚の場合のルールチェック
        if selectedCards.count > 1 {
            print("   複数枚のカードチェック")
            
            // ルール2: 同じ数字で複数（スート関係なし）
            let allSameNumber = selectedCards.allSatisfy { card in
                card.card.suit() == .joker || card.card.handValue().contains(fieldCardValue)
            }
            
            print("   ルール2チェック: 全て同じ数字? \(allSameNumber)")
            if allSameNumber {
                print("   ✅ 全て同じ数字のため出せます")
                return (true, "全て同じ数字のカードです")
            }
            
            // ルール4: 同じスートで複数（場と同じスートが最初に選択必須 + 全て同じ数字）
            let firstCard = selectedCards[0]
            print("   ルール4チェック: 最初のカード \(firstCard.card.rawValue)")
            
            // 最初のカードが場と同じスートまたはジョーカー
            if firstCard.card.suit() == fieldCardSuit || firstCard.card.suit() == .joker {
                print("   ルール4: 最初のカードが場と同じスートまたはジョーカー")
                
                // 全てのカードが同じ数字かチェック（ジョーカー除く）
                let nonJokerCards = selectedCards.filter { $0.card.suit() != .joker }
                print("   ルール4: ジョーカー以外のカード \(nonJokerCards.map { $0.card.rawValue })")
                
                if !nonJokerCards.isEmpty {
                    // ジョーカー以外のカードが全て同じ数字かチェック
                    let firstNonJokerValue = nonJokerCards[0].card.handValue().first ?? 0
                    let allSameNumberInSuit = nonJokerCards.allSatisfy { card in
                        card.card.handValue().contains(firstNonJokerValue)
                    }
                    
                    print("   ルール4: 最初の数字 \(firstNonJokerValue), 全て同じ数字? \(allSameNumberInSuit)")
                    
                    if allSameNumberInSuit {
                        print("   ✅ 場と同じスートから始まる同じ数字のため出せます")
                        return (true, "場と同じスートから始まる同じ数字のカードです")
                    }
                }
            } else {
                print("   ルール4: 最初のカードが場と異なるスート")
            }
            
            // ルール5: 合計が同じ（ジョーカー対応）
            print("   ルール5チェック: 合計値判定")
            let totalValidation = validateTotalSum(selectedCards: selectedCards, targetSum: fieldCardValue)
            if totalValidation.canPlay {
                print("   ✅ 合計値が一致するため出せます")
                return totalValidation
            }
        }
        
        print("   ❌ どのルールにも該当しません")
        return (false, "出せるカードの組み合わせではありません")
    }
    
    /// 合計値の検証（ジョーカー対応）
    private func validateTotalSum(selectedCards: [Card], targetSum: Int) -> (canPlay: Bool, reason: String) {
        // ジョーカーと通常カードを分離
        let jokers = selectedCards.filter { $0.card.suit() == .joker }
        let normalCards = selectedCards.filter { $0.card.suit() != .joker }
        
        // 通常カードの合計値
        let normalSum = normalCards.reduce(0) { sum, card in
            sum + (card.card.handValue().first ?? 0)
        }
        
        // ジョーカーがない場合
        if jokers.isEmpty {
            if normalSum == targetSum {
                return (true, "合計値が一致します")
            }
            return (false, "合計値が一致しません")
        }
        
        // ジョーカーがある場合の全パターンチェック
        return checkJokerCombinations(jokers: jokers, normalSum: normalSum, targetSum: targetSum)
    }
    
    /// ジョーカーの組み合わせをチェック
    private func checkJokerCombinations(jokers: [Card], normalSum: Int, targetSum: Int) -> (canPlay: Bool, reason: String) {
        let jokerCount = jokers.count
        
        // ジョーカーの可能な値の組み合わせを生成（-1, 0, 1）
        func generateJokerCombinations(count: Int) -> [[Int]] {
            if count == 0 { return [[]] }
            if count == 1 { return [[-1], [0], [1]] }
            
            let subCombinations = generateJokerCombinations(count: count - 1)
            var combinations: [[Int]] = []
            
            for value in [-1, 0, 1] {
                for subCombination in subCombinations {
                    combinations.append([value] + subCombination)
                }
            }
            
            return combinations
        }
        
        let combinations = generateJokerCombinations(count: jokerCount)
        
        for combination in combinations {
            let jokerSum = combination.reduce(0, +)
            let totalSum = normalSum + jokerSum
            
            if totalSum == targetSum {
                let jokerDescription = combination.map { "\($0)" }.joined(separator: ", ")
                return (true, "ジョーカーを[\(jokerDescription)]として計算すると合計値が一致します")
            }
        }
        
        return (false, "ジョーカーを含めても合計値が一致しません")
    }
    
    /// カード出し判定結果の表示用メッセージを取得
    func getCardPlayValidationMessage(playerId: String) -> String {
        let validation = canPlaySelectedCards(playerId: playerId)
        return validation.reason
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
        
        let fieldValue = fieldCard.card.handValue().first ?? 0
        let handTotals = calculateHandTotals(cards: player.hand)
        
        print("🔍 どてんこ判定 - プレイヤー: \(player.name)")
        print("   場のカード: \(fieldCard.card.rawValue) (値: \(fieldValue))")
        print("   手札の可能な合計値: \(handTotals)")
        
        // 手札の合計値のいずれかが場のカードと一致するかチェック
        let canDeclare = handTotals.contains(fieldValue)
        print("   どてんこ宣言可能: \(canDeclare ? "✅" : "❌")")
        
        return canDeclare
    }
    
    /// 手札の合計値を計算（ジョーカー対応）
    func calculateHandTotals(cards: [Card]) -> [Int] {
        // ジョーカーと通常カードを分離
        let jokers = cards.filter { $0.card.suit() == .joker }
        let normalCards = cards.filter { $0.card.suit() != .joker }
        
        // 通常カードの合計値
        let normalSum = normalCards.reduce(0) { sum, card in
            sum + (card.card.handValue().first ?? 0)
        }
        
        // ジョーカーがない場合
        if jokers.isEmpty {
            return [normalSum]
        }
        
        // ジョーカーがある場合の全パターン計算
        return calculateJokerHandCombinations(jokers: jokers, normalSum: normalSum)
    }
    
    /// ジョーカーを含む手札の全パターンを計算
    private func calculateJokerHandCombinations(jokers: [Card], normalSum: Int) -> [Int] {
        let jokerCount = jokers.count
        
        // ジョーカーの可能な値の組み合わせを生成（-1, 0, 1）
        func generateJokerCombinations(count: Int) -> [[Int]] {
            if count == 0 { return [[]] }
            if count == 1 { return [[-1], [0], [1]] }
            
            let subCombinations = generateJokerCombinations(count: count - 1)
            var combinations: [[Int]] = []
            
            for value in [-1, 0, 1] {
                for subCombination in subCombinations {
                    combinations.append([value] + subCombination)
                }
            }
            
            return combinations
        }
        
        let combinations = generateJokerCombinations(count: jokerCount)
        var totals: [Int] = []
        
        for combination in combinations {
            let jokerSum = combination.reduce(0, +)
            let totalSum = normalSum + jokerSum
            totals.append(totalSum)
        }
        
        // 重複を除去してソート
        return Array(Set(totals)).sorted()
    }
    
    /// どてんこ宣言を処理
    func handleDotenkoDeclaration(playerId: String) {
        guard let playerIndex = players.firstIndex(where: { $0.id == playerId }) else { return }
        guard canPlayerDeclareDotenko(playerId: playerId) else {
            print("⚠️ どてんこ宣言失敗: 条件を満たしていません - プレイヤー \(players[playerIndex].name)")
            return
        }
        
        print("🎉 どてんこ宣言成功! - プレイヤー \(players[playerIndex].name)")
        
        // どてんこ状態を更新
        players[playerIndex].dtnk = true
        dotenkoWinnerId = playerId
        
        // ゲームフェーズに応じて処理を分岐
        if self.gamePhase == .challengeZone {
            // チャレンジゾーン中の場合
            self.handleChallengeDotenkoDeclaration(playerId: playerId)
        } else {
            // 通常のゲーム中の場合
            self.startRevengeWaitingPhase()
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
        if isAnnouncementBlocking {
            return false
        }
        
        // 通常のゲーム進行中かつ場にカードがある場合
        if gamePhase == .playing && !fieldCards.isEmpty {
            return canPlayerDeclareDotenko(playerId: "player")
        }
        
        // チャレンジゾーン中で自分のターンの場合
        if gamePhase == .challengeZone && isChallengeZone {
            guard let currentPlayer = getCurrentChallengePlayer() else { return false }
            return currentPlayer.id == "player" && canPlayerDeclareDotenko(playerId: "player")
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
        checkBotRealtimeDotenkoDeclarations()
    }
    
    /// 場のカードが変更された時の処理（どてんこチェック用）
    func onFieldCardChanged() {
        // BOTのどてんこ宣言チェック
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkBotDotenkoDeclarations()
        }
    }
    
    // MARK: - Revenge System
    
    /// リベンジ待機フェーズを開始
    private func startRevengeWaitingPhase() {
        gamePhase = .revengeWaiting
        isRevengeWaiting = true
        revengeCountdown = 5
        
        // リベンジ可能なプレイヤーを特定
        updateRevengeEligiblePlayers()
        
        print("🔄 リベンジ待機フェーズ開始 - 5秒間待機")
        print("   リベンジ可能プレイヤー: \(revengeEligiblePlayers)")
        
        // リベンジタイマー開始
        startRevengeTimer()
        
        // BOTのリベンジチェック（少し遅延して実行）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkBotRevengeDeclarations()
        }
    }
    
    /// リベンジ可能なプレイヤーを更新
    private func updateRevengeEligiblePlayers() {
        guard let fieldCard = fieldCards.last else {
            revengeEligiblePlayers = []
            return
        }
        
        let fieldValue = fieldCard.card.handValue().first ?? 0
        revengeEligiblePlayers = []
        
        for player in players {
            // どてんこした人以外で、リベンジ条件を満たすプレイヤー
            if player.id != dotenkoWinnerId && !player.dtnk {
                let handTotals = calculateHandTotals(cards: player.hand)
                if handTotals.contains(fieldValue) {
                    revengeEligiblePlayers.append(player.id)
                }
            }
        }
    }
    
    /// リベンジタイマーを開始
    private func startRevengeTimer() {
        revengeTimer?.invalidate()
        
        revengeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.revengeCountdown -= 1
            print("リベンジカウントダウン: \(self.revengeCountdown)")
            
            if self.revengeCountdown <= 0 {
                timer.invalidate()
                self.finishRevengeWaiting()
            }
        }
    }
    
    /// リベンジ待機終了処理
    private func finishRevengeWaiting() {
        isRevengeWaiting = false
        revengeTimer?.invalidate()
        revengeTimer = nil
        
        print("⏰ リベンジ待機終了")
        
        // チャレンジゾーンを開始
        startChallengeZone()
    }
    
    /// プレイヤーがリベンジ宣言できるかチェック
    func canPlayerDeclareRevenge(playerId: String) -> Bool {
        guard gamePhase == .revengeWaiting else { 
            print("🔍 リベンジ判定: ゲームフェーズが異なります (\(gamePhase))")
            return false 
        }
        guard isRevengeWaiting else { 
            print("🔍 リベンジ判定: リベンジ待機中ではありません")
            return false 
        }
        guard playerId != dotenkoWinnerId else { 
            print("🔍 リベンジ判定: どてんこした人はリベンジ不可 (\(playerId))")
            return false 
        }
        
        let canRevenge = revengeEligiblePlayers.contains(playerId)
        print("🔍 リベンジ判定 - プレイヤー: \(playerId)")
        print("   リベンジ可能プレイヤー: \(revengeEligiblePlayers)")
        print("   リベンジ宣言可能: \(canRevenge ? "✅" : "❌")")
        
        return canRevenge
    }
    
    /// リベンジ宣言を処理
    func handleRevengeDeclaration(playerId: String) {
        guard let playerIndex = players.firstIndex(where: { $0.id == playerId }) else { return }
        guard canPlayerDeclareRevenge(playerId: playerId) else {
            print("⚠️ リベンジ宣言失敗: 条件を満たしていません - プレイヤー \(players[playerIndex].name)")
            return
        }
        
        print("🔥 リベンジ宣言成功! - プレイヤー \(players[playerIndex].name)")
        
        // リベンジ状態を更新
        players[playerIndex].dtnk = true
        
        // 前のどてんこ勝者を敗者に変更
        if let previousWinnerId = dotenkoWinnerId,
           let previousWinnerIndex = players.firstIndex(where: { $0.id == previousWinnerId }) {
            players[previousWinnerIndex].rank = players.count // 最下位
            print("💀 前のどてんこ勝者が敗者に: \(players[previousWinnerIndex].name)")
        }
        
        // 新しいどてんこ勝者を設定
        dotenkoWinnerId = playerId
        
        // リベンジ待機を再開（連鎖リベンジ対応）
        self.startRevengeWaitingPhase()
    }
    
    /// BOTプレイヤーのリベンジ宣言チェック（リアルタイム）
    func checkBotRevengeDeclarations() {
        guard gamePhase == .revengeWaiting else { return }
        
        // アナウンス中は処理しない
        if isAnnouncementBlocking {
            return
        }
        
        // BOTプレイヤーのみをチェック
        let botPlayers = players.filter { $0.id != "player" }
        
        for bot in botPlayers {
            if canPlayerDeclareRevenge(playerId: bot.id) {
                // BOTは見逃しなしで即座にリベンジ宣言（少し遅延を入れて人間らしく）
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...2.0)) {
                    if self.canPlayerDeclareRevenge(playerId: bot.id) {
                        print("🤖 BOT \(bot.name) がリベンジ宣言!")
                        self.handleRevengeDeclaration(playerId: bot.id)
                    }
                }
                return // 最初に宣言したBOTで処理終了
            }
        }
    }
    
    // MARK: - Challenge Zone System
    
    /// チャレンジゾーンを開始
    private func startChallengeZone() {
        guard let fieldCard = fieldCards.last else {
            // 場にカードがない場合は直接勝利確定
            finalizeDotenko()
            return
        }
        
        let fieldValue = fieldCard.card.handValue().first ?? 0
        
        // チャレンジゾーン参加条件をチェック（手札合計 < 場のカード数字）
        challengeParticipants = []
        
        for player in players {
            // どてんこした人以外で、参加条件を満たすプレイヤー
            if player.id != dotenkoWinnerId && !player.dtnk {
                let handTotals = calculateHandTotals(cards: player.hand)
                let minHandTotal = handTotals.min() ?? 0
                
                if minHandTotal < fieldValue {
                    challengeParticipants.append(player.id)
                }
            }
        }
        
        if challengeParticipants.isEmpty {
            print("🏁 チャレンジゾーン参加者なし - どてんこ勝利確定")
            finalizeDotenko()
            return
        }
        
        // チャレンジゾーン開始
        gamePhase = .challengeZone
        isChallengeZone = true
        challengeRoundCount = 0
        
        // どてんこした次の人から時計回りで開始
        if let dotenkoWinnerIndex = players.firstIndex(where: { $0.id == dotenkoWinnerId }) {
            currentChallengePlayerIndex = (dotenkoWinnerIndex + 1) % players.count
        } else {
            currentChallengePlayerIndex = 0
        }
        
        print("🎯 チャレンジゾーン開始!")
        print("   参加者: \(challengeParticipants.count)人")
        print("   開始プレイヤー: \(getCurrentChallengePlayer()?.name ?? "不明")")
        
        // チャレンジゾーン開始アナウンス
        // チャレンジゾーンの進行を開始
        self.processChallengeZoneTurn()
    }
    
    /// 現在のチャレンジプレイヤーを取得
    func getCurrentChallengePlayer() -> Player? {
        guard currentChallengePlayerIndex < players.count else { return nil }
        return players[currentChallengePlayerIndex]
    }
    
    /// チャレンジゾーンのターン処理
    private func processChallengeZoneTurn() {
        guard let currentPlayer = getCurrentChallengePlayer() else {
            finalizeDotenko()
            return
        }
        
        // 参加者でない場合は次のプレイヤーへ
        if !challengeParticipants.contains(currentPlayer.id) {
            nextChallengePlayer()
            return
        }
        
        // 参加条件を再チェック
        guard let fieldCard = fieldCards.last else {
            finalizeDotenko()
            return
        }
        
        let fieldValue = fieldCard.card.handValue().first ?? 0
        let handTotals = calculateHandTotals(cards: currentPlayer.hand)
        let minHandTotal = handTotals.min() ?? 0
        
        if minHandTotal >= fieldValue {
            // 参加条件を満たさなくなった場合は除外
            challengeParticipants.removeAll { $0 == currentPlayer.id }
            print("❌ \(currentPlayer.name) はチャレンジ条件を満たさなくなりました")
            
            if challengeParticipants.isEmpty {
                print("🏁 全参加者がチャレンジ条件を満たさなくなりました")
                finalizeDotenko()
                return
            }
            
            // 次のプレイヤーへ
            self.nextChallengePlayer()
            return
        }
        
        print("🎯 チャレンジターン: \(currentPlayer.name)")
        
        // BOTの場合は自動でカードを引く
        if currentPlayer.id != "player" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.performBotChallengeAction(player: currentPlayer)
            }
        } else {
            // 人間プレイヤーの場合は手動操作待ち
            print("👤 プレイヤーのチャレンジターン - カードを引いてください")
        }
    }
    
    /// BOTのチャレンジアクション
    private func performBotChallengeAction(player: Player) {
        // デッキからカードを引く
        drawCardFromDeck(playerId: player.id)
        
        // ジョーカー自動選択でどてんこ判定
        if canPlayerDeclareDotenko(playerId: player.id) {
            print("🤖 BOT \(player.name) がチャレンジでどてんこ宣言!")
            handleChallengeDotenkoDeclaration(playerId: player.id)
        } else {
            // 次のプレイヤーへ
            nextChallengePlayer()
        }
    }
    
    /// チャレンジゾーンでのどてんこ宣言処理
    private func handleChallengeDotenkoDeclaration(playerId: String) {
        guard let playerIndex = players.firstIndex(where: { $0.id == playerId }) else { return }
        
        print("🔥 チャレンジゾーンでどてんこ宣言! - プレイヤー \(players[playerIndex].name)")
        
        // 新しいリベンジ勝者を設定
        players[playerIndex].dtnk = true
        
        // 前のどてんこ勝者を敗者に変更
        if let previousWinnerId = dotenkoWinnerId,
           let previousWinnerIndex = players.firstIndex(where: { $0.id == previousWinnerId }) {
            players[previousWinnerIndex].rank = players.count // 最下位
            print("💀 前のどてんこ勝者が敗者に: \(players[previousWinnerIndex].name)")
        }
        
        // 新しいどてんこ勝者を設定
        dotenkoWinnerId = playerId
        
        // チャレンジゾーンを継続（連鎖対応）
        challengeParticipants.removeAll { $0 == playerId } // 宣言した人は除外
        
        if challengeParticipants.isEmpty {
            print("🏁 チャレンジゾーン終了 - 全参加者が除外されました")
            finalizeDotenko()
        } else {
            print("🔄 チャレンジゾーン継続 - 残り参加者: \(challengeParticipants.count)人")
            nextChallengePlayer()
        }
    }
    
    /// 次のチャレンジプレイヤーに進む
    private func nextChallengePlayer() {
        challengeRoundCount += 1
        
        // 無限ループ防止（最大100ターン）
        if challengeRoundCount > 100 {
            print("⚠️ チャレンジゾーン強制終了 - 最大ターン数に達しました")
            finalizeDotenko()
            return
        }
        
        currentChallengePlayerIndex = (currentChallengePlayerIndex + 1) % players.count
        
        // 次のターンを処理
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.processChallengeZoneTurn()
        }
    }
    
    /// プレイヤーがチャレンジゾーンでカードを引く
    func handleChallengeDrawCard() {
        guard gamePhase == .challengeZone else { return }
        guard let currentPlayer = getCurrentChallengePlayer() else { return }
        guard currentPlayer.id == "player" else { return }
        
        // デッキからカードを引く
        drawCardFromDeck(playerId: currentPlayer.id)
        
        // どてんこ判定
        if canPlayerDeclareDotenko(playerId: currentPlayer.id) {
            // どてんこボタンを表示（自動宣言はしない）
            print("✨ チャレンジでどてんこ可能! - どてんこボタンが表示されます")
        } else {
            // 次のプレイヤーへ
            nextChallengePlayer()
        }
    }
    
    /// どてんこ勝利を確定
    private func finalizeDotenko() {
        isChallengeZone = false
        
        // ゲーム終了処理
        gamePhase = .finished
        
        if let winnerId = dotenkoWinnerId {
            handleDotenkoVictory(winnerId: winnerId)
        } else {
            // 勝者がいない場合は直接スコア計算
            startScoreCalculation()
        }
        
        print("🎮 ゲーム終了 - どてんこ勝利確定")
    }
    
    /// リベンジボタンを表示すべきかチェック
    func shouldShowRevengeButton(for playerId: String) -> Bool {
        // アナウンス中は表示しない
        if isAnnouncementBlocking {
            return false
        }
        
        return canPlayerDeclareRevenge(playerId: playerId)
    }
    
    // MARK: - Shotenko & Burst System
    
    /// しょてんこ宣言をチェック（最初の場札配布後）
    private func checkShotenkoDeclarations() {
        guard isFirstCardDealt && !fieldCards.isEmpty else { return }
        guard let fieldCard = fieldCards.first else { return }
        
        let fieldValue = fieldCard.card.handValue().first ?? 0
        print("🎯 しょてんこ判定開始 - 最初の場札: \(fieldCard.card.rawValue) (値: \(fieldValue))")
        
        // 全プレイヤーのしょてんこ判定（BOT優先）
        for player in players {
            let handTotals = calculateHandTotals(cards: player.hand)
            print("   プレイヤー \(player.name): 手札合計値 \(handTotals)")
            
            if handTotals.contains(fieldValue) {
                print("🎊 しょてんこ発生! - プレイヤー \(player.name)")
                
                // BOTの場合は即座に宣言、人間の場合は少し待機
                if player.id != "player" {
                    handleShotenkoDeclaration(playerId: player.id)
                } else {
                    // 人間プレイヤーの場合は3秒間ボタン表示
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        // 3秒後にまだ宣言されていなければ自動宣言
                        if !self.isShotenkoRound && self.canPlayerDeclareShotenko(playerId: player.id) {
                            print("⏰ しょてんこ自動宣言 - プレイヤー \(player.name)")
                            self.handleShotenkoDeclaration(playerId: player.id)
                        }
                    }
                }
                return // 最初に見つかったプレイヤーで処理終了
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
        
        // チャレンジゾーンを開始（しょてんこでもチャレンジゾーン発生）
        self.startChallengeZone()
    }
    
    /// バーストイベントを処理
    private func handleBurstEvent(playerId: String) {
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
        showAnnouncementMessage(
            title: "バースト発生！",
            subtitle: "\(players[playerIndex].name) の敗北"
        ) {
            // バーストの場合はチャレンジゾーンをスキップして直接スコア確定
            self.gamePhase = .finished
            print("🎮 ラウンド終了 - バーストによる勝敗確定（チャレンジゾーンスキップ）")
            
            // スコア計算を開始
            self.startScoreCalculation()
        }
    }
    
    /// プレイヤーがしょてんこ宣言できるかチェック（最初の場札のみ）
    func canPlayerDeclareShotenko(playerId: String) -> Bool {
        guard isFirstCardDealt && !isShotenkoRound else { return false }
        guard let player = players.first(where: { $0.id == playerId }) else { return false }
        guard let fieldCard = fieldCards.first else { return false }
        
        let fieldValue = fieldCard.card.handValue().first ?? 0
        let handTotals = calculateHandTotals(cards: player.hand)
        
        return handTotals.contains(fieldValue)
    }
    
    /// しょてんこボタンを表示すべきかチェック
    func shouldShowShotenkoButton() -> Bool {
        // アナウンス中は表示しない
        if isAnnouncementBlocking {
            return false
        }
        
        return canPlayerDeclareShotenko(playerId: "player")
    }
    
    /// プレイヤーのしょてんこ宣言を処理（手動宣言用）
    func handlePlayerShotenkoDeclaration(playerId: String) {
        guard canPlayerDeclareShotenko(playerId: playerId) else {
            print("⚠️ しょてんこ宣言失敗: 条件を満たしていません")
            return
        }
        
        handleShotenkoDeclaration(playerId: playerId)
    }
    
    // MARK: - Announcement System
    
    /// アナウンスを表示（右から流れて中央で停止して左に完全に流れ切る）
    /// - Parameters:
    ///   - title: メインタイトルテキスト
    ///   - subtitle: サブタイトルテキスト（オプション）
    ///   - completion: アニメーション完了後のコールバック
    func showAnnouncementMessage(title: String, subtitle: String = "", completion: (() -> Void)? = nil) {
        announcementText = title
        announcementSubText = subtitle
        isAnnouncementBlocking = true
        
        print("📢 アナウンス表示開始: \(title)")
        if !subtitle.isEmpty {
            print("   サブタイトル: \(subtitle)")
        }
        
        // アナウンス表示開始
        showAnnouncement = true
        
        // 総アニメーション時間を定数から取得
        // 構成: 開始遅延(0.1秒) + 右→中央(0.8秒) + 中央停止(1.5秒) + 中央→左(1.2秒) = 3.6秒
        let totalDuration = LayoutConstants.AnnouncementAnimation.totalDuration
        
        print("   総アニメーション時間: \(totalDuration)秒")
        print("   - 右→中央: \(LayoutConstants.AnnouncementAnimation.enteringDuration)秒")
        print("   - 中央停止: \(LayoutConstants.AnnouncementAnimation.stayingDuration)秒")
        print("   - 中央→左: \(LayoutConstants.AnnouncementAnimation.exitingDuration)秒")
        
        // アニメーション完了後に処理再開とコールバック実行
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            self.hideAnnouncement()
            completion?()
        }
    }
    
    /// アナウンスを非表示
    func hideAnnouncement() {
        showAnnouncement = false
        isAnnouncementBlocking = false
        announcementText = ""
        announcementSubText = ""
        print("📢 アナウンス表示終了")
    }
    
    // MARK: - Rate Up Effect System
    
    /// レートアップエフェクトを表示
    /// - Parameter multiplier: 現在の倍率
    func showRateUpEffect(multiplier: Int) {
        // 既存のタイマーをキャンセル
        rateUpEffectTimer?.invalidate()
        
        rateUpMultiplier = multiplier
        showRateUpEffect = true
        
        print("📈 レートアップエフェクト表示: ×\(multiplier)")
        
        // 5.0秒後にエフェクトを非表示（5回発射 + スローアニメーション完了時間に合わせて調整）
        rateUpEffectTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.hideRateUpEffect()
        }
    }
    
    /// レートアップエフェクトを非表示
    func hideRateUpEffect() {
        rateUpEffectTimer?.invalidate()
        rateUpEffectTimer = nil
        showRateUpEffect = false
        rateUpMultiplier = 1
        print("📈 レートアップエフェクト終了")
    }
    
    // MARK: - Score Calculation System
    
    /// スコア計算エンジン
    @Published var currentUpRate: Int = 1 // 現在の上昇レート倍率
    @Published var consecutiveCardCount: Int = 0 // 連続同じ数字カウント
    @Published var lastPlayedCardValue: Int? = nil // 最後に出されたカードの数字

    @Published var roundScore: Int = 0 // ラウンドスコア
    
    /// スコア確定画面表示用
    @Published var showScoreResult: Bool = false
    @Published var scoreResultData: ScoreResultData? = nil
    @Published var consecutiveSpecialCards: [Card] = [] // 連続特殊カード
    
    /// ラウンド終了時のスコア計算を開始
    func startScoreCalculation() {
        guard gamePhase == .finished else { return }
        
        print("💰 スコア計算開始")
        
        // デッキの裏確認演出を開始
        showAnnouncementMessage(
            title: "スコア計算",
            subtitle: "デッキの裏を確認します"
        ) {
            self.revealDeckBottom()
        }
    }
    
    /// デッキの裏（山札の一番下）を確認
    private func revealDeckBottom() {
        guard !deckCards.isEmpty else {
            // デッキが空の場合は場のカードから確認
            revealFromFieldCards()
            return
        }
        
        let bottomCard = deckCards.last!
        print("🔍 デッキの裏確認: \(bottomCard.card.rawValue)")
        
        // 特殊カード判定と演出
        processSpecialCardEffect(card: bottomCard) {
            self.calculateFinalScore(bottomCard: bottomCard)
        }
    }
    
    /// 場のカードからデッキの裏を確認（デッキが空の場合）
    private func revealFromFieldCards() {
        guard !fieldCards.isEmpty else {
            print("⚠️ デッキも場も空のため、スコア計算をスキップします")
            finishScoreCalculation()
            return
        }
        
        let bottomCard = fieldCards.first!
        print("🔍 場のカードから裏確認: \(bottomCard.card.rawValue)")
        
        // 特殊カード判定と演出
        processSpecialCardEffect(card: bottomCard) {
            self.calculateFinalScore(bottomCard: bottomCard)
        }
    }
    
    /// 特殊カード効果の処理と演出
    private func processSpecialCardEffect(card: Card, completion: @escaping () -> Void) {
        print("🎴 特殊カード効果処理開始")
        print("   カード: \(card.card.rawValue)")
        
        // CardModelの統合されたメソッドを使用して特殊効果を判定
        if card.card.isUpRateCard() {
            // 1、2、ジョーカー：2倍演出
            print("🎯 1、2、ジョーカー判定: 上昇レート2倍")
            showSpecialCardEffect(
                title: "特殊カード発生！",
                subtitle: "\(card.card.rawValue) - 2倍",
                effectType: .multiplier50
            ) {
                self.currentUpRate = self.safeMultiply(self.currentUpRate, by: ScoreConstants.specialCardMultiplier2)
                self.checkConsecutiveSpecialCards(from: card, completion: completion)
            }
        } else if card.card == .diamond3 {
            // ダイヤ3：最終数字30として扱う（上昇レート倍増なし）
            print("💎 ダイヤ3判定: 最終数字30（上昇レート変更なし）")
            showSpecialCardEffect(
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
            showSpecialCardEffect(
                title: "黒3発生！",
                subtitle: "勝敗逆転",
                effectType: .black3Reverse
            ) {
                self.reverseWinLose()
                completion()
            }
        } else {
            // 通常カード（ハート3も含む）
            print("🔢 通常カード判定: 特殊効果なし")
            completion()
        }
    }
    
    /// 連続特殊カード確認（1、2、ジョーカーの場合）
    private func checkConsecutiveSpecialCards(from currentCard: Card, completion: @escaping () -> Void) {
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
            
            // 実際のデッキからも削除
            if let actualIndex = deckCards.firstIndex(where: { $0.id == nextCard.id }) {
                deckCards.remove(at: actualIndex)
                print("🗑️ 連続特殊カードを実際のデッキからも削除: \(nextCard.card.rawValue)")
            }
            
            showAnnouncementMessage(
                title: "連続特殊カード！",
                subtitle: "\(nextCard.card.rawValue) - さらに2倍"
            ) {
                self.currentUpRate = self.safeMultiply(self.currentUpRate, by: ScoreConstants.specialCardMultiplier2)
                print("🎯 連続特殊カード処理完了! 新倍率: ×\(self.currentUpRate)")
                self.checkConsecutiveSpecialCards(from: nextCard, completion: completion)
            }
        } else {
            print("🔄 連続特殊カード終了 - 通常カード: \(nextCard.card.rawValue)")
            completion()
        }
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
    
    /// 最終スコア計算
    private func calculateFinalScore(bottomCard: Card) {
        let baseRate = Int(gameRuleInfo.gameRate) ?? 1
        
        // デッキの裏カードの値を取得（CardModelの新しいメソッドを使用）
        let bottomCardValue: Int
        
        print("🔍 最終数字計算開始")
        print("   カード: \(bottomCard.card.rawValue)")
        print("   スート: \(bottomCard.card.suit())")
        
        // CardModelの新しいメソッドを使用して最終数字を決定
        bottomCardValue = bottomCard.card.finalScoreNum()
        
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
        
        // 基本計算式：初期レート × 上昇レート × デッキの裏の数字
        roundScore = baseRate * currentUpRate * bottomCardValue
        
        // スコア上限チェック
        if let maxScoreString = gameRuleInfo.maxScore,
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
        
        // 勝者・敗者を特定
        let winner = players.first { $0.rank == 1 }
        let loser = players.first { $0.rank == players.count }
        let winnerHand = winner?.hand ?? []
        
        // しょてんこ・バーストの場合は該当プレイヤーも渡す
        var shotenkoPlayer: Player? = nil
        var burstPlayer: Player? = nil
        
        if isShotenkoRound, let shotenkoWinnerId = shotenkoWinnerId {
            shotenkoPlayer = players.first { $0.id == shotenkoWinnerId }
        }
        
        if isBurst, let burstPlayerId = burstPlayerId {
            burstPlayer = players.first { $0.id == burstPlayerId }
        }
        
        // スコア確定画面データを作成
        scoreResultData = ScoreResultData(
            winner: shotenkoPlayer ?? winner,
            loser: burstPlayer ?? loser,
            deckBottomCard: bottomCard,
            consecutiveCards: consecutiveSpecialCards,
            winnerHand: winnerHand,
            baseRate: baseRate,
            upRate: currentUpRate,
            finalMultiplier: bottomCardValue,
            totalScore: roundScore,
            isShotenkoRound: isShotenkoRound,
            isBurstRound: isBurst,
            shotenkoWinnerId: shotenkoWinnerId,
            burstPlayerId: burstPlayerId
        )
        
        // スコア確定画面を表示
        showScoreResult = true
    }
    
    /// スコア確定画面のOKボタン処理
    func onScoreResultOK() {
        print("✅ スコア確定画面 - OKボタンタップ")
        showScoreResult = false
        scoreResultData = nil
        
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
        currentUpRate = 1
        consecutiveCardCount = 0
        lastPlayedCardValue = nil
        roundScore = 0
        consecutiveSpecialCards.removeAll()
        
        // リベンジ・チャレンジ状態をリセット
        dotenkoWinnerId = nil
        revengeEligiblePlayers.removeAll()
        challengeParticipants.removeAll()
        isChallengeZone = false
        isRevengeWaiting = false
        
        // しょてんこ・バースト状態をリセット
        isShotenkoRound = false
        shotenkoWinnerId = nil
        burstPlayerId = nil
        isFirstCardDealt = false
        isBurst = false
        
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
    
    /// ゲーム中の上昇レート管理
    func updateUpRateForCardPlay(card: Card) {
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
                
                // 上昇レート演出（矢印エフェクト）
                showRateUpEffect(multiplier: currentUpRate)
            }
        }
    }
    
    /// 特殊カード演出の種類
    enum SpecialCardEffectType {
        case multiplier50
        case diamond3
        case black3Reverse
        case heart3
    }
    
    /// 特殊カード演出を表示
    private func showSpecialCardEffect(title: String, subtitle: String, effectType: SpecialCardEffectType, completion: @escaping () -> Void) {
        // 特殊カード演出（アナウンス削除）
        print("🎴 特殊カード演出: \(title) - \(subtitle)")
        completion()
    }
    
    /// ゲーム開始時の上昇レート判定（1、2、ジョーカー）
    private func checkGameStartUpRate(card: Card) {
        // CardModelの統合されたメソッドを使用
        if card.card.isUpRateCard() {
            currentUpRate = safeMultiply(currentUpRate, by: ScoreConstants.specialCardMultiplier2)
            print("🎯 ゲーム開始時上昇レート発生! カード: \(card.card.rawValue), 倍率: ×\(currentUpRate)")
            
            // 上昇レート演出（矢印エフェクト）
            showRateUpEffect(multiplier: currentUpRate)
            
            // 連続確認
            checkConsecutiveGameStartCards(from: card)
        }
    }
    
    /// ゲーム開始時の連続特殊カード確認
    private func checkConsecutiveGameStartCards(from currentCard: Card) {
        // デッキから次のカードを確認
        guard !deckCards.isEmpty else { 
            print("🔄 デッキが空のため連続確認を終了")
            return 
        }
        
        // 処理済みカードをデッキから削除
        if let currentIndex = deckCards.firstIndex(where: { $0.id == currentCard.id }) {
            deckCards.remove(at: currentIndex)
            print("🗑️ 処理済みカードをデッキから削除: \(currentCard.card.rawValue)")
        }
        
        // デッキが空になった場合は終了
        guard !deckCards.isEmpty else { 
            print("🔄 デッキが空になったため連続確認を終了")
            return 
        }
        
        // 次のカードを取得（デッキの最後から）
        let nextCard = deckCards.last!
        
        print("🔍 次のカード確認: \(nextCard.card.rawValue)")
        
        // 連続特殊カード判定（CardModelの統合されたメソッドを使用）
        if nextCard.card.isUpRateCard() {
            currentUpRate = safeMultiply(currentUpRate, by: ScoreConstants.specialCardMultiplier2)
            print("🎯 連続特殊カード発生! カード: \(nextCard.card.rawValue), 新倍率: ×\(currentUpRate)")
            
            // 連続ボーナス演出（矢印エフェクト）
            showRateUpEffect(multiplier: currentUpRate)
            
            // 連続確認を継続（次のカードで再帰）
            checkConsecutiveGameStartCards(from: nextCard)
        } else {
            print("🔄 連続特殊カード終了 - 通常カード: \(nextCard.card.rawValue)")
        }
    }
    
    // MARK: - BOT思考システム
    
    /// BOTのターンを開始
    func startBotTurn(player: Player) {
        guard player.id != "player" else { return }
        
        print("🤖 BOTターン開始: \(player.name)")
        
        // 思考時間をランダムに設定（0.5-3秒）
        let thinkingTime = Double.random(in: 0.5...3.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + thinkingTime) {
            self.performBotAction(player: player)
        }
    }
    
    /// BOTの行動を実行
    private func performBotAction(player: Player) {
        guard let playerIndex = players.firstIndex(where: { $0.id == player.id }) else { return }
        
        // 1. どてんこ宣言チェック（最優先）
        if canPlayerDeclareDotenko(playerId: player.id) {
            print("🤖 BOT \(player.name) がどてんこ宣言!")
            handleDotenkoDeclaration(playerId: player.id)
            return
        }
        
        // 2. カード出し判定
        let playableCards = getBotPlayableCards(player: player)
        if !playableCards.isEmpty {
            // 最適なカードを選択
            let bestCards = selectBestCards(from: playableCards, player: player)
            
            // カードを選択状態にする
            players[playerIndex].selectedCards = bestCards
            
            print("🤖 BOT \(player.name) がカードを出します: \(bestCards.map { $0.card.rawValue })")
            
            // カード出し実行
            executeBotCardPlay(player: player)
            return
        }
        
        // 3. デッキから引くかパス
        executeBotDrawOrPass(player: player)
    }
    
    /// BOTが出せるカードの組み合わせを取得
    private func getBotPlayableCards(player: Player) -> [[Card]] {
        guard let fieldCard = fieldCards.last else { return [] }
        
        var playableCardSets: [[Card]] = []
        let hand = player.hand
        
        // 1枚出しの判定
        for card in hand {
            let testCards = [card]
            if validateCardPlayRules(selectedCards: testCards, fieldCard: fieldCard).canPlay {
                playableCardSets.append(testCards)
            }
        }
        
        // 2枚組み合わせの判定
        for i in 0..<hand.count {
            for j in (i+1)..<hand.count {
                let testCards = [hand[i], hand[j]]
                if validateCardPlayRules(selectedCards: testCards, fieldCard: fieldCard).canPlay {
                    playableCardSets.append(testCards)
                }
            }
        }
        
        return playableCardSets
    }
    
    /// 最適なカードを選択
    private func selectBestCards(from playableCardSets: [[Card]], player: Player) -> [Card] {
        guard !playableCardSets.isEmpty else { return [] }
        
        // カードの優先度を計算
        var bestCards = playableCardSets[0]
        var bestPriority = calculateBotCardPriority(cards: bestCards)
        
        for cardSet in playableCardSets {
            let priority = calculateBotCardPriority(cards: cardSet)
            if priority > bestPriority {
                bestPriority = priority
                bestCards = cardSet
            }
        }
        
        return bestCards
    }
    
    /// BOTのカード優先度を計算
    private func calculateBotCardPriority(cards: [Card]) -> Int {
        guard let fieldCard = fieldCards.last else { return 0 }
        
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
    
    /// BOTのカード出しを実行
    private func executeBotCardPlay(player: Player) {
        guard let playerIndex = players.firstIndex(where: { $0.id == player.id }) else { return }
        
        // 選択されたカードをフィールドに移動
        moveSelectedCardsToField(playerIndex: playerIndex, player: player)
        
        // 次のターンに進む
        nextTurn()
    }
    
    /// BOTのデッキ引きまたはパス
    private func executeBotDrawOrPass(player: Player) {
        // カードを引いていない場合は引く
        if !player.hasDrawnCardThisTurn {
            if !deckCards.isEmpty && player.hand.count < 7 {
                print("🤖 BOT \(player.name) がデッキからカードを引きます")
                drawCardFromDeck(playerId: player.id)
            }
            return
        }
        
        // カードを引いている場合はパス
        print("🤖 BOT \(player.name) がパスします")
        
        // バースト判定
        if player.hand.count >= 7 {
            handleBurstEvent(playerId: player.id)
            return
        }
        
        // 次のターンに進む
        nextTurn()
    }
    
    /// BOTのリアルタイムどてんこ宣言チェック
    func checkBotRealtimeDotenkoDeclarations() {
        guard gamePhase == .playing else { return }
        
        // アナウンス中は処理しない
        if isAnnouncementBlocking {
            return
        }
        
        // BOTプレイヤーのみをチェック
        let botPlayers = players.filter { $0.id != "player" }
        
        for bot in botPlayers {
            if canPlayerDeclareDotenko(playerId: bot.id) && !bot.dtnk {
                // BOTは見逃しなしで即座に宣言（少し遅延を入れて人間らしく）
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.1...2.0)) {
                    if self.canPlayerDeclareDotenko(playerId: bot.id) && !bot.dtnk {
                        print("🤖 BOT \(bot.name) がリアルタイムどてんこ宣言!")
                        self.handleDotenkoDeclaration(playerId: bot.id)
                    }
                }
                return // 最初に宣言したBOTで処理終了
            }
        }
    }
} 
