import SwiftUI
import Combine

struct GameMainView: View {
    @EnvironmentObject private var allViewNavigator: NavigationAllViewStateManager
    @StateObject private var viewModel: GameViewModel
    
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
                
                // Deck（座標を直接指定）
                DeckView(
                    deckCards: viewModel.deckCards,
                    onDeckTap: viewModel.handleDeckTap
                )
                    .position(x: geometry.size.width * 0.0, y: geometry.size.height * 0.65)
                
                // UI オーバーレイ（戻るボタンなど）
                GameUIOverlayView(
                    onBackAction: { allViewNavigator.pop() },
                    onSettingsAction: viewModel.handleSettingsAction
                )
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
                topPlayers: viewModel.topPlayers,
                leftPlayers: viewModel.leftPlayers,
                rightPlayers: viewModel.rightPlayers,
                currentPlayer: viewModel.currentPlayer,
                onPassAction: {
                    viewModel.handlePassAction()
                },
                onPlayAction: {
                    viewModel.handlePlayAction()
                },
                viewModel: viewModel
            )
        }
    }
}

// MARK: - Card View
struct CardView: View {
    let card: Card
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // カード画像
            if let cardImage = card.card.image() {
                Image(uiImage: cardImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.9, height: size * 1.26)
                    .clipped()
            } else {
                // フォールバック表示
                Text(card.card.rawValue)
                    .font(.system(size: size * 0.2, weight: .bold))
                    .foregroundColor(.black)
            }
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
