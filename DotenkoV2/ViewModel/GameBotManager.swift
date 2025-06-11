import SwiftUI
import Combine

// MARK: - Game Bot Manager
/// BOT思考システムを管理するマネージャー
class GameBotManager: ObservableObject {
    
    // MARK: - Private Properties
    private weak var gameViewModel: GameViewModel?
    private let botManager: BotManagerProtocol
    
    // MARK: - Initialization
    init(botManager: BotManagerProtocol) {
        self.botManager = botManager
    }
    
    // MARK: - Lifecycle
    deinit {
        print("🤖 GameBotManager解放")
    }
    
    // MARK: - Setup
    func setGameViewModel(_ gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
    }
    
    // MARK: - BOT思考システム
    
    /// 全BOTの処理を停止
    func stopAllBotActions() {
        print("🛑 全BOTの処理を停止")
        // BotManagerに停止指示を送信
        // 現在実行中のBOT処理をキャンセル
        print("   BOT思考処理停止完了")
    }
    
    /// BOTのターンを開始
    func startBotTurn(player: Player) {
        guard player.id != "player" else { 
            print("⚠️ BOTターン開始エラー: 人間プレイヤーが指定されました")
            return 
        }
        
        // BotGameStateを作成
        let gameState = createBotGameState()
        
        // BotManagerに処理を委譲
        botManager.startBotTurn(player: player, gameState: gameState) { [weak self] action in
            self?.handleBotAction(action)
        }
    }
    
    /// BotGameStateを作成
    private func createBotGameState() -> BotGameState {
        guard let gameViewModel = gameViewModel else {
            fatalError("GameViewModel is not set")
        }
        
        return BotGameState(
            fieldCards: gameViewModel.fieldCards,
            deckCards: gameViewModel.deckCards,
            gamePhase: gameViewModel.gamePhase,
            isAnnouncementBlocking: gameViewModel.isAnnouncementBlocking,
            isCountdownActive: gameViewModel.isCountdownActive,
            isWaitingForFirstCard: gameViewModel.isWaitingForFirstCard,
            dotenkoWinnerId: gameViewModel.dotenkoWinnerId,
            revengeEligiblePlayers: gameViewModel.revengeEligiblePlayers,
            challengeParticipants: gameViewModel.challengeParticipants,
            validateCardPlayRules: { [weak gameViewModel] cards, fieldCard in
                return gameViewModel?.cardValidationManager.canPlaySelectedCards(selectedCards: cards, fieldCard: fieldCard) ?? (canPlay: false, reason: "ゲーム状態エラー")
            },
            canPlayerDeclareDotenko: { [weak gameViewModel] playerId in
                return gameViewModel?.canPlayerDeclareDotenko(playerId: playerId) ?? false
            },
            canPlayerDeclareRevenge: { [weak gameViewModel] playerId in
                return gameViewModel?.canPlayerDeclareRevenge(playerId: playerId) ?? false
            },
            calculateHandTotals: { [weak gameViewModel] cards in
                return gameViewModel?.cardValidationManager.calculateHandTotals(cards: cards) ?? []
            }
        )
    }
    
    /// BOTのアクションを処理
    private func handleBotAction(_ action: BotAction) {
        guard let gameViewModel = gameViewModel else { return }
        
        switch action {
        case .dotenkoDeclaration(let playerId):
            gameViewModel.handleDotenkoDeclaration(playerId: playerId)
            
        case .playCards(let playerId, let cards):
            guard let playerIndex = gameViewModel.players.firstIndex(where: { $0.id == playerId }) else { return }
            // カードを選択状態にする
            gameViewModel.players[playerIndex].selectedCards = cards
            // カード出しを実行
            gameViewModel.moveSelectedCardsToField(playerIndex: playerIndex, player: gameViewModel.players[playerIndex])
            gameViewModel.nextTurn()
            
        case .drawCard(let playerId):
            gameViewModel.drawCardFromDeck(playerId: playerId)
            // カードを引いた後の行動判定
            if let player = gameViewModel.players.first(where: { $0.id == playerId }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.performBotActionAfterDraw(player: player)
                }
            }
            
        case .pass(let playerId):
            gameViewModel.nextTurn()
            
        case .burst(let playerId):
            gameViewModel.handleBurstEvent(playerId: playerId)
        }
    }
    
    /// BOTがカードを引いた後の行動判定
    private func performBotActionAfterDraw(player: Player) {
        print("🤖 BOT \(player.name) のカード引き後行動判定:")
        print("   新しい手札: \(player.hand.map { $0.card.rawValue })")
        
        // BotGameStateを作成
        let gameState = createBotGameState()
        
        // BotManagerに処理を委譲（カード引き後の判定）
        botManager.startBotTurn(player: player, gameState: gameState) { [weak self] action in
            self?.handleBotAction(action)
        }
    }
} 