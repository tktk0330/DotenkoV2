import SwiftUI

// MARK: - Main View
/// 中間結果画面
/// ラウンド終了後にスコア変動を表示し、全プレイヤーの確認を待つ画面
struct InterimResultView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView
                contentView(geometry: geometry)
            }
        }
        .onAppear {
            print("\(InterimResultConstants.Messages.logDisplayMessage) - ラウンド \(viewModel.currentRound)")
        }
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        Color.black.opacity(0.95)
            .ignoresSafeArea()
    }
    
    // MARK: - Content
    private func contentView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            titleView
            playerCardsView(geometry: geometry)
            Spacer()
            actionButtonView
        }
    }
    
    // MARK: - Title Section
    private var titleView: some View {
        InterimResultTitleView(roundNumber: viewModel.currentRound)
            .padding(.top, InterimResultConstants.Layout.titleTopPadding)
    }
    
    // MARK: - Player Cards Section
    private func playerCardsView(geometry: GeometryProxy) -> some View {
        InterimResultPlayerCardsView(
            players: viewModel.players,
            getScoreChange: getScoreChange,
            cardHeight: calculateCardHeight(
                playerCount: viewModel.players.count,
                screenHeight: geometry.size.height
            ),
            cardSpacing: InterimResultConstants.CardSpacing.spacing(for: viewModel.players.count)
        )
        .padding(.top, InterimResultConstants.Layout.cardStartPadding)
        .padding(.horizontal, InterimResultConstants.Layout.horizontalPadding)
    }
    
    // MARK: - Action Button Section
    private var actionButtonView: some View {
        InterimResultActionButtonView(
            isWaitingForOthers: viewModel.isWaitingForOthers,
            onOKTapped: handleOKButtonTapped
        )
        .padding(.bottom, InterimResultConstants.Layout.buttonBottomPadding)
        .padding(.horizontal, InterimResultConstants.Layout.horizontalPadding)
    }
    
    // MARK: - Helper Methods
    private func calculateCardHeight(playerCount: Int, screenHeight: CGFloat) -> CGFloat {
        let titleHeight = InterimResultConstants.Layout.titleTopPadding + 
                         InterimResultConstants.Typography.titleSize + 
                         InterimResultConstants.Spacing.titleSpacing
        let buttonHeight = InterimResultConstants.Dimensions.buttonHeight + 
                          InterimResultConstants.Layout.buttonBottomPadding
        let reservedHeight = titleHeight + 
                           InterimResultConstants.Layout.cardStartPadding + 
                           buttonHeight + 
                           InterimResultConstants.Layout.bottomReservedHeight
        
        let availableHeight = screenHeight - reservedHeight
        let spacing = InterimResultConstants.CardSpacing.spacing(for: playerCount)
        let totalSpacing = spacing * CGFloat(playerCount - 1)
        let cardHeight = (availableHeight - totalSpacing) / CGFloat(playerCount)
        
        return max(min(cardHeight, InterimResultConstants.Dimensions.maxCardHeight), 
                  InterimResultConstants.Dimensions.minCardHeight)
    }
    
    private func getScoreChange(for player: Player) -> Int {
        // しょてんこの場合の特別計算
        if viewModel.isShotenkoRound, let shotenkoWinnerId = viewModel.shotenkoWinnerId {
            let otherPlayersCount = viewModel.players.count - 1
            
            if player.id == shotenkoWinnerId {
                // しょてんこした人：他の全プレイヤー分のスコアを獲得
                return viewModel.lastRoundScore * otherPlayersCount
            } else {
                // その他のプレイヤー：ラウンドスコアを失う
                return -viewModel.lastRoundScore
            }
        }
        
        // バーストの場合の特別計算
        if viewModel.isBurst, let burstPlayerId = viewModel.burstPlayerId {
            let otherPlayersCount = viewModel.players.count - 1
            
            if player.id == burstPlayerId {
                // バーストした人：他の全プレイヤー分のスコアを失う
                return -(viewModel.lastRoundScore * otherPlayersCount)
            } else {
                // その他のプレイヤー：ラウンドスコアを獲得
                return viewModel.lastRoundScore
            }
        }
        
        // 通常のどてんこの場合
        if player.rank == 1 {
            return viewModel.lastRoundScore
        } else if player.rank == viewModel.players.count {
            return -viewModel.lastRoundScore
        } else {
            return 0
        }
    }
    
    private func handleOKButtonTapped() {
        print(InterimResultConstants.Messages.logOKButtonMessage)
        viewModel.handleInterimResultOK()
    }
}

// MARK: - Title Component
private struct InterimResultTitleView: View {
    let roundNumber: Int
    @State private var titleScale: CGFloat = 0.5
    @State private var titleOpacity: Double = 0.0
    @State private var glowIntensity: Double = 0.0
    
    var body: some View {
        VStack(spacing: InterimResultConstants.Spacing.titleSpacing) {
            Text("ROUND \(roundNumber) RESULTS")
                .font(.system(size: InterimResultConstants.Typography.titleSize, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(Appearance.Color.casinoGoldGlow),
                            Color.yellow.opacity(0.9),
                            Color(Appearance.Color.casinoGoldGlow)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(Appearance.Color.casinoGoldGlow).opacity(glowIntensity), radius: 8, x: 0, y: 0)
                .shadow(color: Color(Appearance.Color.casinoGoldGlow).opacity(glowIntensity * 0.7), radius: 15, x: 0, y: 0)
                .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 2)
                .scaleEffect(titleScale)
                .opacity(titleOpacity)
                .onAppear {
                    withAnimation(.spring(
                        response: InterimResultConstants.Animation.springResponse,
                        dampingFraction: InterimResultConstants.Animation.springDampingFraction,
                        blendDuration: InterimResultConstants.Animation.springBlendDuration
                    )) {
                        titleScale = 1.0
                        titleOpacity = 1.0
                    }
                    
                    // グロー効果のパルスアニメーション
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        glowIntensity = 0.8
                    }
                }
        }
    }
}

// MARK: - Player Cards Component
private struct InterimResultPlayerCardsView: View {
    let players: [Player]
    let getScoreChange: (Player) -> Int
    let cardHeight: CGFloat
    let cardSpacing: CGFloat
    
    @State private var sortedPlayers: [Player] = []
    @State private var shouldSortByRank: Bool = false
    
    var body: some View {
        VStack(spacing: cardSpacing) {
            ForEach(Array(displayPlayers.enumerated()), id: \.element.id) { index, player in
                PlayerScoreCard(
                    player: player,
                    scoreChange: getScoreChange(player),
                    isCurrentPlayer: player.id == "player",
                    cardHeight: cardHeight
                )
                .animation(
                    .spring(
                        response: InterimResultConstants.Animation.springResponse,
                        dampingFraction: InterimResultConstants.Animation.springDampingFraction,
                        blendDuration: InterimResultConstants.Animation.springBlendDuration
                    )
                    .delay(InterimResultConstants.Animation.cardBaseDelay + 
                          Double(index) * InterimResultConstants.Animation.cardDelayInterval),
                    value: true
                )
            }
        }
        .animation(
            .spring(
                response: InterimResultConstants.Animation.sortSpringResponse,
                dampingFraction: InterimResultConstants.Animation.sortSpringDampingFraction,
                blendDuration: InterimResultConstants.Animation.sortSpringBlendDuration
            ),
            value: shouldSortByRank
        )
        .onAppear {
            // 最初は前回の順位（rank順）で整列
            sortedPlayers = players.sorted(by: { $0.rank < $1.rank })
            startRankSortAnimation()
        }
    }
    
    private var displayPlayers: [Player] {
        shouldSortByRank ? sortedPlayers.sorted(by: { $0.score > $1.score }) : sortedPlayers
    }
    
    private func startRankSortAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + InterimResultConstants.Animation.rankSortDelay) {
            withAnimation(
                .spring(
                    response: InterimResultConstants.Animation.sortSpringResponse,
                    dampingFraction: InterimResultConstants.Animation.sortSpringDampingFraction,
                    blendDuration: InterimResultConstants.Animation.sortSpringBlendDuration
                )
            ) {
                shouldSortByRank = true
            }
        }
    }
}

// MARK: - Action Button Component
private struct InterimResultActionButtonView: View {
    let isWaitingForOthers: Bool
    let onOKTapped: () -> Void
    
    @State private var buttonOpacity: Double = 0.0
    @State private var buttonScale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: InterimResultConstants.Spacing.buttonSpacing) {
            if isWaitingForOthers {
                waitingView
            } else {
                okButton
                    .opacity(buttonOpacity)
                    .scaleEffect(buttonScale)
                    .onAppear {
                        startButtonAnimation()
                    }
            }
        }
    }
    
    private func startButtonAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + InterimResultConstants.Animation.rankSortDelay + 0.5) {
            withAnimation(.spring(
                response: InterimResultConstants.Animation.springResponse,
                dampingFraction: InterimResultConstants.Animation.springDampingFraction,
                blendDuration: InterimResultConstants.Animation.springBlendDuration
            )) {
                buttonOpacity = 1.0
                buttonScale = 1.0
            }
        }
    }
    
    private var waitingView: some View {
        VStack(spacing: InterimResultConstants.Spacing.buttonSpacing) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.0)
            
            Text(InterimResultConstants.Messages.waitingMessage)
                .font(.system(size: InterimResultConstants.Typography.waitingMessageSize, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var okButton: some View {
        Button(action: onOKTapped) {
            HStack(spacing: InterimResultConstants.Spacing.buttonSpacing) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: InterimResultConstants.Typography.buttonFontSize, weight: .bold))
                Text("OK")
                    .font(.system(size: InterimResultConstants.Typography.buttonFontSize, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: InterimResultConstants.Dimensions.buttonHeight)
            .background(buttonBackground)
        }
    }
    
    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: InterimResultConstants.Dimensions.buttonCornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(InterimResultConstants.Colors.greenButtonTopOpacity),
                        Color.green.opacity(InterimResultConstants.Colors.greenButtonBottomOpacity)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: .black.opacity(InterimResultConstants.Colors.shadowOpacity), radius: 4, x: 0, y: 2)
    }
}
