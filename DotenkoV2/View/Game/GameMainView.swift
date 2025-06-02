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
                
                
                // Deck
                ZStack {
                    ForEach(viewModel.deckCards, id: \.id) { card in
                        CardView(card: card, size: 100)
                            .matchedGeometryEffect(id: card.id, in: namespace)
                    }
                    .position(x: geometry.size.width * 0.0, y: geometry.size.height * 0.65)
                }
                
                // Field
                ZStack {
                    ForEach(viewModel.fieldCards, id: \.id) { card in
                        CardView(card: card, size: 100)
                            .matchedGeometryEffect(id: card.id, in: namespace)
                    }
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
                }
                
                // MyHand
                ZStack {
                    HStack(spacing: -50) {
                        ForEach(viewModel.players[0].hand, id: \.id) { card in
                            let isSelected = viewModel.players[0].selectedCards.contains(card)
                            
                            CardView(card: card, size: 100)
                                .matchedGeometryEffect(id: card.id, in: namespace)
                                .offset(y: isSelected ? -10 : 0)  // 選択時に少し上に移動
                                .padding(.top, isSelected ? 10 : 0) // 選択時の見切れ防止
                                .onTapGesture {
                                    if let idx = viewModel.players[0].selectedCards.firstIndex(of: card) {
                                        // 既存選択なら削除
                                        viewModel.players[0].selectedCards.remove(at: idx)
                                    } else {
                                        // 新規選択なら末尾に追加（順序を保持）
                                        viewModel.players[0].selectedCards.append(card)
                                    }
                                }
                        }
                        .position(x: geometry.size.width * 0.3, y: geometry.size.height * 0.70)
                    }
                }
                
                
                
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
