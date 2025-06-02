import SwiftUI
import Combine

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
                
                // Deck with matchedGeometryEffect
                ZStack {
                    ForEach(viewModel.deckCards.prefix(5), id: \.id) { card in
                        CardView(card: card, size: 80)
                            .matchedGeometryEffect(id: card.id, in: namespace)
                    }
                }
                .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.65)
                .onTapGesture {
                    viewModel.handleDeckTap()
                }
                
                // Field with matchedGeometryEffect
                ZStack {
                    ForEach(viewModel.fieldCards, id: \.id) { card in
                        CardView(card: card, size: 100)
                            .matchedGeometryEffect(id: card.id, in: namespace)
                    }
                }
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    // MARK: - Main Layout Components
    
    /// メインゲーム画面のレイアウト
    private func gameMainLayout(geometry: GeometryProxy) -> some View {
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
                onPassAction: {
                    viewModel.handlePassAction()
                },
                onPlayAction: {
                    viewModel.handlePlayAction()
                },
                viewModel: viewModel,
                namespace: namespace
            )
        }
    }
}

// MARK: - Player Position Enum
enum PlayerPosition {
    case top
    case bottom
    case left
    case right
}

// MARK: - Game Phase Enum
/// ゲームフェーズ
enum GamePhase {
    case waiting    // 待機中
    case playing    // プレイ中
    case finished   // 終了
}
