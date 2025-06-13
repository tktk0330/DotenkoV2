import SwiftUI
import Combine

// MARK: - Game Revenge Manager
/// リベンジシステムとチャレンジゾーンシステムを管理するマネージャー
class GameRevengeManager: ObservableObject {
    
    // MARK: - Published Properties
    
    // リベンジシステム
    @Published var dotenkoWinnerId: String? = nil
    @Published var revengeEligiblePlayers: [String] = []
    
    // チャレンジゾーンシステム
    @Published var isChallengeZone: Bool = false
    @Published var challengeParticipants: [String] = []
    @Published var currentChallengePlayerIndex: Int = 0
    @Published var challengeRoundCount: Int = 0
    
    // チャレンジゾーン参加モーダル
    @Published var showChallengeParticipationModal: Bool = false
    @Published var challengeParticipationChoices: [String: ChallengeZoneParticipationModal.ParticipationChoice] = [:]
    
    // 手札公開システム
    @Published var showHandReveal: Bool = false // 手札公開表示フラグ
    
    // MARK: - Private Properties
    private weak var gameViewModel: GameViewModel?
    private let botManager: BotManagerProtocol
    private var isProcessingChallengeParticipation: Bool = false // 重複実行防止フラグ
    
    // MARK: - Initialization
    init(botManager: BotManagerProtocol) {
        self.botManager = botManager
    }
    
    // MARK: - Lifecycle
    deinit {
        print("🔄 GameRevengeManager解放")
    }
    
    // MARK: - Setup
    func setGameViewModel(_ gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
    }
    
    // MARK: - Revenge System
    
    /// チャレンジゾーン参加判定を開始（即座にモーダル表示）
    func startChallengeZoneParticipation() {
        guard let gameViewModel = gameViewModel else { return }
        
        // 重複実行防止チェック
        guard !isProcessingChallengeParticipation else {
            print("🛑 チャレンジゾーン参加判定重複実行防止")
            return
        }
        isProcessingChallengeParticipation = true
        
        // 🔄 BOT処理を再開（リベンジ・チャレンジ処理のため）
        gameViewModel.gameBotManager.resumeBotActions()
        
        // リベンジ可能なプレイヤーを特定
        updateRevengeEligiblePlayers()
        
        print("🔄 リベンジ・チャレンジゾーン判定開始")
        print("   リベンジ可能プレイヤー: \(revengeEligiblePlayers)")
        
        // 即座にチャレンジゾーン参加モーダルを表示
        showChallengeZoneParticipationModal()
    }
    
    /// リベンジ可能なプレイヤーを更新
    private func updateRevengeEligiblePlayers() {
        guard let gameViewModel = gameViewModel else { return }
        guard let fieldCard = gameViewModel.fieldCards.last else {
            revengeEligiblePlayers = []
            return
        }
        
        let fieldValue = fieldCard.card.handValue().first ?? 0
        revengeEligiblePlayers = []
        
                 for player in gameViewModel.players {
             // どてんこした人以外で、リベンジ条件を満たすプレイヤー
             if player.id != dotenkoWinnerId && !player.dtnk {
                 let handTotals = gameViewModel.calculateHandTotals(cards: player.hand)
                if handTotals.contains(fieldValue) {
                    revengeEligiblePlayers.append(player.id)
                }
            }
        }
    }
    

    
    /// プレイヤーがリベンジ宣言できるかチェック
    func canPlayerDeclareRevenge(playerId: String) -> Bool {
        guard let gameViewModel = gameViewModel else { return false }
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
        guard let gameViewModel = gameViewModel else { return }
        guard let playerIndex = gameViewModel.players.firstIndex(where: { $0.id == playerId }) else { return }
        guard canPlayerDeclareRevenge(playerId: playerId) else {
            print("⚠️ リベンジ宣言失敗: 条件を満たしていません - プレイヤー \(gameViewModel.players[playerIndex].name)")
            return
        }
        
        print("🔥 リベンジ宣言成功! - プレイヤー \(gameViewModel.players[playerIndex].name)")
        
        // リベンジ状態を更新
        gameViewModel.players[playerIndex].dtnk = true
        
        // 前のどてんこ勝者を敗者に変更
        if let previousWinnerId = dotenkoWinnerId,
           let previousWinnerIndex = gameViewModel.players.firstIndex(where: { $0.id == previousWinnerId }) {
            gameViewModel.players[previousWinnerIndex].rank = gameViewModel.players.count // 最下位
            print("💀 前のどてんこ勝者が敗者に: \(gameViewModel.players[previousWinnerIndex].name)")
        }
        
        // 新しいどてんこ勝者を設定
        dotenkoWinnerId = playerId
        
        // リベンジ宣言時に即座に全プレイヤーの処理を停止
        gameViewModel.stopAllPlayerActions()
        
        // リベンジアニメーションを表示
        let playerName = gameViewModel.players[playerIndex].name
        gameViewModel.announcementEffectManager.showDeclarationAnimation(type: .revenge, playerName: playerName) {
            // アニメーション完了後にリベンジ待機を再開
            DispatchQueue.main.async {
                // チャレンジゾーン参加判定を再開（連鎖リベンジ対応）
                self.startChallengeZoneParticipation()
            }
        }
    }
    

    
    // MARK: - Challenge Zone Participation Modal System
    
    /// チャレンジゾーン参加モーダルを表示
    func showChallengeZoneParticipationModal() {
        guard let gameViewModel = gameViewModel else { return }
        
        print("🎯 チャレンジゾーン参加モーダル表示開始")
        
        // 参加選択をリセット
        challengeParticipationChoices.removeAll()
        
        // メインスレッドでUI更新を確実に実行
        DispatchQueue.main.async {
            // モーダルを表示
            self.showChallengeParticipationModal = true
            print("🎯 モーダル表示設定完了: \(self.showChallengeParticipationModal)")
            
            // SwiftUIに状態変更を強制通知
            self.objectWillChange.send()
            
            // GameViewModelにも状態変更を通知
            gameViewModel.objectWillChange.send()
        }
    }
    
    /// プレイヤーの参加選択を処理
    func handlePlayerParticipationChoice(playerId: String, choice: ChallengeZoneParticipationModal.ParticipationChoice) {
        challengeParticipationChoices[playerId] = choice
        
        print("🎯 プレイヤー \(playerId) の選択: \(choice)")
        
        // リベンジ選択の場合は即座に処理
        if choice == .revenge {
            handleRevengeDeclaration(playerId: playerId)
            return
        }
        
        // 全プレイヤーが選択完了したかチェック
        checkAllPlayersSelectedParticipation()
    }
    
    /// 参加モーダルのタイムアウト処理
    func handleParticipationModalTimeout() {
        guard let gameViewModel = gameViewModel else { return }
        
        print("⏰ チャレンジゾーン参加モーダル タイムアウト")
        
        // 未選択のプレイヤーにデフォルト選択を適用
        for player in gameViewModel.players {
            if challengeParticipationChoices[player.id] == nil {
                let defaultChoice: ChallengeZoneParticipationModal.ParticipationChoice
                if revengeEligiblePlayers.contains(player.id) {
                    defaultChoice = .revenge
                } else if player.id == dotenkoWinnerId {
                    defaultChoice = .decline
                } else {
                    defaultChoice = .participate
                }
                challengeParticipationChoices[player.id] = defaultChoice
                print("🎯 プレイヤー \(player.id) にデフォルト選択適用: \(defaultChoice)")
            }
        }
        
        // 全選択完了処理
        finishParticipationSelection()
    }
    
    /// 全プレイヤーの参加選択完了チェック
    private func checkAllPlayersSelectedParticipation() {
        guard let gameViewModel = gameViewModel else { return }
        
        if challengeParticipationChoices.count >= gameViewModel.players.count {
            finishParticipationSelection()
        }
    }
    
    /// 参加選択完了処理
    private func finishParticipationSelection() {
        showChallengeParticipationModal = false
        isProcessingChallengeParticipation = false // 処理完了フラグをリセット
        
        // リベンジ選択があるかチェック
        let revengeChoices = challengeParticipationChoices.filter { $0.value == .revenge }
        if !revengeChoices.isEmpty {
            // リベンジがある場合は処理済みなので何もしない
            print("🔥 リベンジ選択があったため、チャレンジゾーンはスキップ")
            return
        }
        
        // チャレンジゾーン参加者を決定
        let participants = challengeParticipationChoices.compactMap { (playerId, choice) in
            choice == .participate ? playerId : nil
        }
        
        if participants.isEmpty {
            // 参加者がいない場合は勝利確定
            print("🎯 チャレンジゾーン参加者なし - 勝利確定")
            finalizeChallengeZone()
        } else {
            // チャレンジゾーンを開始
            challengeParticipants = participants
            startChallengeZone()
        }
    }
    
    // MARK: - Challenge Zone System
    
    /// チャレンジゾーンを開始
    func startChallengeZone() {
        guard let gameViewModel = gameViewModel else { return }
        guard let fieldCard = gameViewModel.fieldCards.last else {
            finalizeChallengeZone()
            return
        }
        
        // 🔄 BOT処理を再開（チャレンジゾーン処理のため）
        gameViewModel.gameBotManager.resumeBotActions()
        
        let fieldValue = fieldCard.card.handValue().first ?? 0
        
        // チャレンジゾーン参加条件をチェック（手札合計 < 場のカード数字）
        challengeParticipants = []
        
        for player in gameViewModel.players {
            // どてんこした人以外で、参加条件を満たすプレイヤー
                         if player.id != dotenkoWinnerId && !player.dtnk {
                 let handTotals = gameViewModel.calculateHandTotals(cards: player.hand)
                let minHandTotal = handTotals.min() ?? 0
                
                if minHandTotal < fieldValue {
                    challengeParticipants.append(player.id)
                }
            }
        }
        
        if challengeParticipants.isEmpty {
            print("🏁 全参加者がチャレンジ条件を満たさなくなりました")
            finalizeChallengeZone()
            return
        }
        
        // チャレンジゾーン開始
        gameViewModel.gamePhase = .challengeZone
        isChallengeZone = true
        challengeRoundCount = 0
        
        // どてんこした次の人から時計回りで開始
        if let dotenkoWinnerIndex = gameViewModel.players.firstIndex(where: { $0.id == dotenkoWinnerId }) {
            currentChallengePlayerIndex = (dotenkoWinnerIndex + 1) % gameViewModel.players.count
        } else {
            currentChallengePlayerIndex = 0
        }
        
        print("🎯 チャレンジゾーン開始!")
        print("   参加者: \(challengeParticipants.count)人")
        print("   開始プレイヤー: \(getCurrentChallengePlayer()?.name ?? "不明")")
        
        // チャレンジゾーン開始アナウンスを表示
        gameViewModel.announcementEffectManager.showChallengeZoneStartAnnouncement(participantCount: challengeParticipants.count) {
            // アナウンス完了後に手札公開とチャレンジゾーン進行を開始
            DispatchQueue.main.async {
                // 手札公開を開始
                self.showHandReveal = true
                print("👁️ 手札公開表示開始 - 参加者: \(self.challengeParticipants)")
                
                // チャレンジゾーンの進行を開始
                self.processChallengeZoneTurn()
            }
        }
    }
    
    /// 現在のチャレンジプレイヤーを取得
    func getCurrentChallengePlayer() -> Player? {
        guard let gameViewModel = gameViewModel else { return nil }
        guard currentChallengePlayerIndex < gameViewModel.players.count else { return nil }
        return gameViewModel.players[currentChallengePlayerIndex]
    }
    
    /// チャレンジゾーンのターン処理
    private func processChallengeZoneTurn() {
        guard let gameViewModel = gameViewModel else { return }
        guard let currentPlayer = getCurrentChallengePlayer() else {
            finalizeChallengeZone()
            return
        }
        
        // 参加者でない場合は次のプレイヤーへ
        if !challengeParticipants.contains(currentPlayer.id) {
            nextChallengePlayer()
            return
        }
        
        // 参加条件を再チェック
        guard let fieldCard = gameViewModel.fieldCards.last else {
            gameViewModel.finalizeDotenko()
            return
        }
        
        let fieldValue = fieldCard.card.handValue().first ?? 0
                 let handTotals = gameViewModel.calculateHandTotals(cards: currentPlayer.hand)
        let minHandTotal = handTotals.min() ?? 0
        
        if minHandTotal >= fieldValue {
            // 参加条件を満たさなくなった場合は除外
            challengeParticipants.removeAll { $0 == currentPlayer.id }
            print("❌ \(currentPlayer.name) はチャレンジ条件を満たさなくなりました")
            
            if challengeParticipants.isEmpty {
                print("🏁 全参加者がチャレンジ条件を満たさなくなりました")
                finalizeChallengeZone()
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
        guard let gameViewModel = gameViewModel else { return }
        let gameState = createBotGameState()
        botManager.performChallengeAction(player: player, gameState: gameState) { [weak self] action in
            switch action {
            case .dotenkoDeclaration(let playerId):
                self?.handleChallengeDotenkoDeclaration(playerId: playerId)
            case .drawAndContinue(let playerId):
                gameViewModel.drawCardFromDeck(playerId: playerId)
                self?.nextChallengePlayer()
            }
        }
    }
    
    /// チャレンジゾーンでのどてんこ宣言処理
    func handleChallengeDotenkoDeclaration(playerId: String) {
        guard let gameViewModel = gameViewModel else { return }
        guard let playerIndex = gameViewModel.players.firstIndex(where: { $0.id == playerId }) else { return }
        
        print("🔥 チャレンジゾーンでどてんこ宣言! - プレイヤー \(gameViewModel.players[playerIndex].name)")
        
        // 新しいリベンジ勝者を設定
        gameViewModel.players[playerIndex].dtnk = true
        
        // 前のどてんこ勝者を敗者に変更
        if let previousWinnerId = dotenkoWinnerId,
           let previousWinnerIndex = gameViewModel.players.firstIndex(where: { $0.id == previousWinnerId }) {
            gameViewModel.players[previousWinnerIndex].rank = gameViewModel.players.count // 最下位
            print("💀 前のどてんこ勝者が敗者に: \(gameViewModel.players[previousWinnerIndex].name)")
        }
        
        // 新しいどてんこ勝者を設定
        dotenkoWinnerId = playerId
        
        // チャレンジゾーンを継続（連鎖対応）
        challengeParticipants.removeAll { $0 == playerId } // 宣言した人は除外
        
        if challengeParticipants.isEmpty {
            print("🏁 チャレンジゾーン終了 - 全参加者が除外されました")
            finalizeChallengeZone()
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
            finalizeChallengeZone()
            return
        }
        
        currentChallengePlayerIndex = (currentChallengePlayerIndex + 1) % (gameViewModel?.players.count ?? 1)
        
        // 次のターンを処理
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.processChallengeZoneTurn()
        }
    }
    
    /// プレイヤーがチャレンジゾーンでカードを引く
    func handleChallengeDrawCard() {
        guard let gameViewModel = gameViewModel else { return }
        guard gameViewModel.gamePhase == .challengeZone else { return }
        guard let currentPlayer = getCurrentChallengePlayer() else { return }
        guard currentPlayer.id == "player" else { return }
        
        // デッキからカードを引く
        gameViewModel.drawCardFromDeck(playerId: currentPlayer.id)
        
        // どてんこ判定
        if gameViewModel.canPlayerDeclareDotenko(playerId: currentPlayer.id) {
            // どてんこボタンを表示（自動宣言はしない）
            print("✨ チャレンジでどてんこ可能! - どてんこボタンが表示されます")
        } else {
            // 次のプレイヤーへ
            nextChallengePlayer()
        }
    }
    
    /// リベンジボタンを表示すべきかチェック
    func shouldShowRevengeButton(for playerId: String) -> Bool {
        guard let gameViewModel = gameViewModel else { return false }
        
        // アナウンス中は表示しない
        if gameViewModel.announcementEffectManager.isAnnouncementActive() {
            return false
        }
        
        return canPlayerDeclareRevenge(playerId: playerId)
    }
    
    // MARK: - Helper Methods
    
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
            dotenkoWinnerId: dotenkoWinnerId,
            revengeEligiblePlayers: revengeEligiblePlayers,
            challengeParticipants: challengeParticipants,
            validateCardPlayRules: { [weak gameViewModel] cards, fieldCard in
                return gameViewModel?.cardValidationManager.canPlaySelectedCards(selectedCards: cards, fieldCard: fieldCard) ?? (canPlay: false, reason: "ゲーム状態エラー")
            },
            canPlayerDeclareDotenko: { [weak gameViewModel] playerId in
                return gameViewModel?.canPlayerDeclareDotenko(playerId: playerId) ?? false
            },
            canPlayerDeclareRevenge: { [weak self] playerId in
                return self?.canPlayerDeclareRevenge(playerId: playerId) ?? false
            },
            calculateHandTotals: { [weak gameViewModel] cards in
                return gameViewModel?.calculateHandTotals(cards: cards) ?? []
            }
        )
    }
    
    // MARK: - Setter Methods
    
    /// どてんこ勝者IDを設定
    func setDotenkoWinnerId(_ winnerId: String?) {
        dotenkoWinnerId = winnerId
    }
    
    // MARK: - Reset Methods
    
    /// リベンジ・チャレンジ状態をリセット
    func resetRevengeAndChallengeState() {
        dotenkoWinnerId = nil
        revengeEligiblePlayers.removeAll()
        challengeParticipants.removeAll()
        isChallengeZone = false
        showChallengeParticipationModal = false
        challengeParticipationChoices.removeAll()
        showHandReveal = false
        isProcessingChallengeParticipation = false // 重複実行防止フラグもリセット
        print("🔄 リベンジ・チャレンジゾーン状態リセット完了")
    }
    
    /// チャレンジゾーンを終了（終了アナウンス付き）
    private func finalizeChallengeZone() {
        guard let gameViewModel = gameViewModel else { return }
        guard let winnerId = dotenkoWinnerId else {
            // 勝者が不明な場合は直接終了
            gameViewModel.finalizeDotenko()
            return
        }
        
        // 勝者名を取得
        let winnerName = gameViewModel.players.first(where: { $0.id == winnerId })?.name ?? "不明"
        
        print("🏁 チャレンジゾーン終了処理開始 - 勝者: \(winnerName)")
        
        // 手札公開を終了
        showHandReveal = false
        
        // チャレンジゾーン終了アナウンスを表示
        gameViewModel.announcementEffectManager.showChallengeZoneEndAnnouncement(winnerName: winnerName) {
            // アナウンス完了後にスコア確定に進む
            DispatchQueue.main.async {
                gameViewModel.finalizeDotenko()
            }
        }
    }
}