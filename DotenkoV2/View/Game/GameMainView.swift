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
        ZStack {
            // メインゲーム画面
            GeometryReader { geometry in
                ZStack {
                    // デッキ表示（最初に配置）
                    DeckView(
                        deckCards: viewModel.deckCards, 
                        namespace: namespace,
                        viewModel: viewModel
                    )
                        .position(
                            x: geometry.size.width * GameLayoutConfig.deckPositionXRatio,
                            y: geometry.size.height * GameLayoutConfig.deckPositionYRatio
                        )
                    
                    // メインゲーム画面レイアウト
                    gameMainLayout(geometry: geometry)
                    
                    // UI オーバーレイ（戻るボタンなど）
                    GameUIOverlayView(
                        onBackAction: { allViewNavigator.pop() },
                        onSettingsAction: viewModel.handleSettingsAction
                    )
                    
                    // カウントダウンオーバーレイ
                    if viewModel.showCountdown {
                        CountdownOverlayView(countdownValue: viewModel.countdownValue)
                    }
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
            
            // アナウンス表示（最上位レベル）
            if viewModel.showAnnouncement {
                GameAnnouncementView(
                    title: viewModel.announcementText,
                    subtitle: viewModel.announcementSubText,
                    isVisible: viewModel.showAnnouncement
                )
                .allowsHitTesting(false)
            }
            
            // スコア確定画面
            if viewModel.showScoreResult, let scoreData = viewModel.scoreResultData {
                ScoreResultView(
                    winner: scoreData.winner,
                    loser: scoreData.loser,
                    deckBottomCard: scoreData.deckBottomCard,
                    consecutiveCards: scoreData.consecutiveCards,
                    winnerHand: scoreData.winnerHand,
                    baseRate: scoreData.baseRate,
                    upRate: scoreData.upRate,
                    finalMultiplier: scoreData.finalMultiplier,
                    totalScore: scoreData.totalScore,
                    onOKAction: viewModel.onScoreResultOK
                )
            }
            
            // 中間結果画面
            if viewModel.showInterimResult {
                InterimResultView(viewModel: viewModel)
            }
            
            // 最終結果画面
            if viewModel.showFinalResult {
                FinalResultView(
                    viewModel: viewModel,
                    onOKAction: viewModel.handleFinalResultOK
                )
            }
        }
    }
}

// MARK: - Countdown Overlay View
/// カウントダウン表示オーバーレイ
struct CountdownOverlayView: View {
    let countdownValue: Int
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("ゲーム開始まで")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                // カウントダウン数字
                Text("\(countdownValue)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(Appearance.Color.playerGold)
                    .scaleEffect(countdownValue > 0 ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: countdownValue)
                
                Text("最初のカードが出るまで待機...")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Appearance.Color.playerGold, lineWidth: 2)
                    )
            )
        }
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
                currentRate: viewModel.currentRate,
                viewModel: viewModel
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
