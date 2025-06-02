import SwiftUI
import Combine

// MARK: - Game Main View
/// ゲームメイン画面View
struct GameMainView: View {
    @EnvironmentObject private var allViewNavigator: NavigationAllViewStateManager
    @StateObject private var viewModel: GameViewModel
    @Namespace private var namespace
    
    init(players: [Player] = [], maxPlayers: Int = 5, gameType: GameType = .vsBot) {
        self._viewModel = StateObject(wrappedValue: GameViewModel(
            players: players,
            maxPlayers: maxPlayers,
            gameType: gameType
        ))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // メインゲーム画面レイアウト
                gameMainLayout(geometry: geometry)
                
                // UI オーバーレイ（戻るボタンなど）
                GameUIOverlayView(
                    onBackAction: { allViewNavigator.pop() },
                    onSettingsAction: viewModel.handleSettingsAction
                )
                
                // デッキ表示
                DeckView(
                    deckCards: viewModel.deckCards, 
                    namespace: namespace,
                    viewModel: viewModel
                )
                    .position(
                        x: geometry.size.width * GameLayoutConfig.deckPositionXRatio,
                        y: geometry.size.height * GameLayoutConfig.deckPositionYRatio
                    )
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

// MARK: - Private Methods
private extension GameMainView {
    /// メインゲーム画面のレイアウト
    func gameMainLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // ヘッダーエリア（ゲーム情報表示）
            GameHeaderView(
                currentRound: viewModel.currentRound,
                totalRounds: viewModel.totalRounds,
                upRate: viewModel.upRate,
                currentRate: viewModel.currentRate
            )
            .frame(height: geometry.size.height * GameLayoutConfig.headerAreaHeightRatio)
            
            // プレイヤーエリア
            GamePlayersAreaView(
                players: viewModel.players,
                maxPlayers: viewModel.maxPlayers,
                onPassAction: viewModel.handlePassAction,
                onPlayAction: viewModel.handlePlayAction,
                viewModel: viewModel,
                namespace: namespace
            )
        }
    }
}
