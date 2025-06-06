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
        Color.black.opacity(InterimResultConstants.Colors.backgroundOpacity)
            .ignoresSafeArea()
    }
    
    // MARK: - Content
    private func contentView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            titleView
            playerCardsView(geometry: geometry)
            actionButtonView
            Spacer()
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
        .padding(.top, InterimResultConstants.Layout.buttonTopPadding)
    }
    
    // MARK: - Helper Methods
    private func calculateCardHeight(playerCount: Int, screenHeight: CGFloat) -> CGFloat {
        let titleHeight = InterimResultConstants.Layout.titleTopPadding + 
                         InterimResultConstants.Typography.titleSize + 
                         InterimResultConstants.Spacing.titleSpacing
        let reservedHeight = titleHeight + 
                           InterimResultConstants.Layout.cardStartPadding + 
                           InterimResultConstants.Layout.buttonTopPadding + 
                           InterimResultConstants.Dimensions.buttonHeight + 
                           InterimResultConstants.Layout.bottomReservedHeight
        
        let availableHeight = screenHeight - reservedHeight
        let spacing = InterimResultConstants.CardSpacing.spacing(for: playerCount)
        let totalSpacing = spacing * CGFloat(playerCount - 1)
        let cardHeight = (availableHeight - totalSpacing) / CGFloat(playerCount)
        
        return max(min(cardHeight, InterimResultConstants.Dimensions.maxCardHeight), 
                  InterimResultConstants.Dimensions.minCardHeight)
    }
    
    private func getScoreChange(for player: Player) -> Int {
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
    
    var body: some View {
        VStack(spacing: InterimResultConstants.Spacing.titleSpacing) {
            Text("ラウンド \(roundNumber)")
                .font(.system(size: InterimResultConstants.Typography.titleSize, weight: .black))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
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
    
    var body: some View {
        VStack(spacing: cardSpacing) {
            ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
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
    }
}

// MARK: - Action Button Component
private struct InterimResultActionButtonView: View {
    let isWaitingForOthers: Bool
    let onOKTapped: () -> Void
    
    var body: some View {
        VStack(spacing: InterimResultConstants.Spacing.buttonSpacing) {
            if isWaitingForOthers {
                waitingView
            } else {
                okButton
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
        .padding(.horizontal, 30)
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



#Preview {
    InterimResultView(viewModel: GameViewModel())
}
