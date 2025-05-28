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
    
    // ゲーム進行情報
    @Published var currentRound: Int = 1
    @Published var totalRounds: Int = 10
    @Published var currentRate: Int = 10
    @Published var upRate: Int = 3
    @Published var currentPot: Int = 0
    
    // デッキ情報
    @Published var deckCount: Int = 30
    @Published var deckCards: [Card] = []
    
    // プレイヤー配置情報
    @Published var topPlayers: [Player] = []
    @Published var leftPlayers: [Player] = []
    @Published var rightPlayers: [Player] = []
    @Published var currentPlayer: Player?
    
    // MARK: - Private Properties
    private let userProfileRepository = UserProfileRepository.shared
    
    // MARK: - Initialization
    init(players: [Player] = [], maxPlayers: Int = 5, gameType: GameType = .vsBot) {
        self.players = players
        self.maxPlayers = maxPlayers
        self.gameType = gameType
        
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
        deckCount = 30
        deckCards = []
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
    }
    
    // MARK: - Game Actions
    
    /// パス/引くアクションを処理
    func handlePassAction() {
        // TODO: パス/引くロジックを実装
        print("パス/引くアクションが実行されました")
    }
    
    /// 出すアクションを処理
    func handlePlayAction() {
        // TODO: 出すロジックを実装
        print("出すアクションが実行されました")
    }
    
    /// デッキタップ時の処理
    func handleDeckTap() {
        // TODO: カードを引く処理を実装
        print("デッキがタップされました - カードを引く処理")
        
        // デッキ枚数を減らす（仮の処理）
        if deckCount > 0 {
            deckCount -= 1
        }
    }
    
    /// 設定ボタンアクション
    func handleSettingsAction() {
        print("設定ボタンが押されました")
    }
} 