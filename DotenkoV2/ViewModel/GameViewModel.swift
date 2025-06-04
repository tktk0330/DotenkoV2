import SwiftUI
import Combine

// MARK: - Game View Model
/// ゲーム全体の状態管理を行うViewModel
class GameViewModel: ObservableObject {
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
    
    // MARK: - Private Properties
    private let userProfileRepository = UserProfileRepository.shared
    private var countdownTimer: Timer?
    
    // MARK: - Initialization
    init(players: [Player] = [], maxPlayers: Int = 5, gameType: GameType = .vsBot) {
        self.players = players
        self.maxPlayers = maxPlayers
        self.gameType = gameType
        
        // 一時的にデフォルト値で初期化
        self.gameRuleInfo = GameRuleModel(
            roundCount: "5",
            jokerCount: "2", 
            gameRate: "10",
            maxScore: "1000",
            upRate: "3",
            deckCycle: "3"
        )
        
        initializeGame()
    }
    
    // MARK: - Game Initialization
    func initializeGame() {
        setupGameInfo()
        setupPlayers()
        setupDeck()
        // 初期カード配布はアニメーション付きで実行
        gamePhase = .playing
        
        // 少し遅延してからカード配布開始
        DispatchQueue.main.asyncAfter(deadline: .now() + LayoutConstants.CardDealAnimation.initialDelay) {
            self.dealInitialCardsWithAnimation()
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
    }
    
    private func setupPlayers() {
        // プレイヤーが不足している場合は補完
        if players.isEmpty {
            // デフォルトの現在プレイヤーを追加
            let defaultPlayer = Player(
                id: "current-player",
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
    
    /// 最初の場札を1枚めくる
    private func dealInitialFieldCard() {
        guard !deckCards.isEmpty else { return }
        
        // 場札もスプリングアニメーションで表示
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.3)) {
            let firstFieldCard = deckCards.removeFirst()
            var fieldCard = firstFieldCard
            fieldCard.location = .field
            
            fieldCards.append(fieldCard)
        }
        
        print("最初の場札: \(fieldCards.last?.card.rawValue ?? "なし")")
    }
    
    private func setupDeck() {
        // 標準的なトランプデッキを作成（52枚 + ジョーカー2枚）
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
        
        // ジョーカーを追加
        cards.append(Card(card: .whiteJoker, location: .deck))
        cards.append(Card(card: .blackJoker, location: .deck))
        
        // デッキをシャッフル
        deckCards = cards.shuffled()
    }
    
    // MARK: - Player Position Management (動的計算用)
    
    /// 現在のプレイヤー（人間プレイヤー）を取得
    func getCurrentPlayer() -> Player? {
        return players.first { !$0.id.hasPrefix("bot-") }
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
        } else {
            gamePhase = .finished
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
        
        print("パス/引くアクションが実行されました - プレイヤー \(currentPlayer.name)")
        
        // 現在のプレイヤーの選択をクリア
        clearPlayerSelectedCards(playerId: currentPlayer.id)
        
        // 次のターンに進む
        nextTurn()
        
        print("プレイヤー \(currentPlayer.name) の手札: \(currentPlayer.hand)")
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
        
        // TODO: カード出し判定ロジックを実装
        // 現在は仮で全て通す
        
        // 選択されたカードをフィールドに移動
        moveSelectedCardsToField(playerIndex: playerIndex, player: player)
        
        // 次のターンに進む
        nextTurn()
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
                }
            }
            
            // 選択をクリア
            clearPlayerSelectedCards(playerId: player.id)
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
        countdownValue = 5
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
        currentTurnPlayerIndex = (currentTurnPlayerIndex + 1) % players.count
        print("ターン変更: プレイヤー\(currentTurnPlayerIndex + 1) (\(getCurrentTurnPlayer()?.name ?? "不明")) のターン")
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
} 
