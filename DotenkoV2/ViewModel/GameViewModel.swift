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
    
    // デッキ情報
    @Published var deckCards: [Card] = []
    // フィールド情報
    @Published var fieldCards: [Card] = []
    
    // プレイヤー配置情報
    @Published var topPlayers: [Player] = []
    @Published var leftPlayers: [Player] = []
    @Published var rightPlayers: [Player] = []
    @Published var currentPlayer: Player?
    
    // カード選択状態
    @Published var selectedCardIndices: Set<Int> = []
    
    // MARK: - Private Properties
    private let userProfileRepository = UserProfileRepository.shared
    
    // MARK: - Initialization
    init(players: [Player] = [], maxPlayers: Int = 5, gameType: GameType = .vsBot) {
        self.players = players
        self.maxPlayers = maxPlayers
        self.gameType = gameType
        self.gameRuleInfo = GameRuleModel()
        
        initializeGame()
    }
    
    // MARK: - Game Initialization
    func initializeGame() {
        setupGameInfo()
        setupPlayerPositions()
        setupDeck()
        gamePhase = .playing
    }
    
    private func setupGameInfo() {
        // ユーザー設定からゲーム情報を取得
        if case .success(let profile) = userProfileRepository.getOrCreateProfile() {
            totalRounds = Int(profile.rmRoundCount) ?? 10
            currentRate = Int(profile.rmGameRate) ?? 10
            upRate = Int(profile.rmUpRate) ?? 3
        }
        
        // 初期ポット計算（プレイヤー数 × 基本レート）
        currentPot = maxPlayers * currentRate
    }
    
    private func setupPlayerPositions() {
        // プレイヤー配置を計算
        topPlayers = getTopPlayers()
        leftPlayers = getLeftPlayers()
        rightPlayers = getRightPlayers()
        currentPlayer = getCurrentPlayer()
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
    
    // MARK: - Player Position Management
    private func getCurrentPlayer() -> Player? {
        return players.first { !$0.id.hasPrefix("bot-") }
    }
    
    private func getTopPlayers() -> [Player] {
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
    
    private func getLeftPlayers() -> [Player] {
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
    
    private func getRightPlayers() -> [Player] {
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
    
    /// 指定されたカードが選択されているかチェック
    func isCardSelected(at index: Int) -> Bool {
        return selectedCardIndices.contains(index)
    }
    
    /// 全てのカード選択を解除
    func clearCardSelection() {
        selectedCardIndices.removeAll()
    }
    
    /// 選択されたカードの数を取得
    var selectedCardCount: Int {
        return selectedCardIndices.count
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
        // TODO: パス/引くロジックを実装
        print("パス/引くアクションが実行されました")
        clearCardSelection()
    }
    
    /// 出すアクションを処理
    func handlePlayAction() {
        // TODO: 出すロジックを実装
        print("出すアクションが実行されました - 選択されたカード数: \(selectedCardCount)")
        clearCardSelection()
    }
    
    /// デッキタップ時の処理
    func handleDeckTap() {
        // TODO: カードを引く処理を実装
        print("デッキがタップされました - カードを引く処理")
        
        // デッキからカードを引く処理（仮の処理）
        if !deckCards.isEmpty {
            let drawnCard = deckCards.removeFirst()
            print("引いたカード: \(drawnCard.card.rawValue)")
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
        return currentPlayer?.hand ?? []
    }
    
    /// 現在のプレイヤーの選択されたカードを取得
    func getCurrentPlayerSelectedCards() -> [Card] {
        return currentPlayer?.selectedCards ?? []
    }
} 
