import SwiftUI

// MARK: - Player Score Card
/// プレイヤーのスコアカード
struct PlayerScoreCard: View {
    let player: Player
    let scoreChange: Int
    let isCurrentPlayer: Bool
    let cardHeight: CGFloat
    
    // アニメーション状態管理
    @State private var animatedScore: Int = 0
    @State private var animatedScoreChange: Int = 0
    @State private var isScoreChangeVisible: Bool = false
    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0.0
    
    var body: some View {
        HStack(spacing: PlayerScoreCardConstants.Layout.cardHorizontalSpacing) {
            playerIconView
            playerNameView
            Spacer()
            scoreDisplayView
        }
        .frame(height: cardHeight)
        .padding(.horizontal, PlayerScoreCardConstants.Layout.cardHorizontalPadding)
        .padding(.vertical, PlayerScoreCardConstants.Layout.cardVerticalPadding)
        .background(casinoCardBackground)
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Icon Section
    private var playerIconView: some View {
        ZStack {
            if let iconUrl = player.icon_url, !iconUrl.isEmpty {
                CachedImageView(
                    imageUrl: iconUrl,
                    size: min(cardHeight * PlayerScoreCardConstants.Icon.sizeRatio, PlayerScoreCardConstants.Icon.maxSize),
                    isBot: player.id.hasPrefix("bot-")
                )
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(isCurrentPlayer ? 
                          Color(Appearance.Color.playerGold).opacity(PlayerScoreCardConstants.Colors.playerGoldOpacity) : 
                          Color.gray.opacity(PlayerScoreCardConstants.Colors.grayOpacity))
                    .frame(
                        width: min(cardHeight * PlayerScoreCardConstants.Icon.sizeRatio, PlayerScoreCardConstants.Icon.maxSize),
                        height: min(cardHeight * PlayerScoreCardConstants.Icon.sizeRatio, PlayerScoreCardConstants.Icon.maxSize)
                    )
                    .overlay(
                        Text(String(player.name.prefix(1)))
                            .font(.system(
                                size: min(cardHeight * PlayerScoreCardConstants.Icon.initialTextRatio, PlayerScoreCardConstants.Icon.maxInitialTextSize),
                                weight: .bold
                            ))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1, x: 0, y: 1)
                    )
            }
        }
    }
    
    // MARK: - Name Section
    private var playerNameView: some View {
        VStack(alignment: .leading, spacing: PlayerScoreCardConstants.Layout.cardVerticalSpacing) {
            Text(player.name)
                .font(.system(
                    size: min(cardHeight * PlayerScoreCardConstants.Typography.nameRatio, PlayerScoreCardConstants.Typography.maxNameSize),
                    weight: .bold
                ))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 1, x: 0, y: 1)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
    }
    
    // MARK: - Score Section
    private var scoreDisplayView: some View {
        VStack(alignment: .trailing, spacing: PlayerScoreCardConstants.Layout.cardVerticalSpacing) {
            if scoreChange != 0 {
                scoreChangeView
            }
            currentScoreView
        }
    }
    
    private var scoreChangeView: some View {
        Text(animatedScoreChange >= 0 ? "+\(formatScore(animatedScoreChange))" : "\(formatScore(animatedScoreChange))")
            .font(.system(
                size: min(cardHeight * PlayerScoreCardConstants.Typography.scoreChangeRatio, PlayerScoreCardConstants.Typography.maxScoreChangeSize),
                weight: .medium
            ))
            .foregroundColor(animatedScoreChange >= 0 ? 
                           Color.green.opacity(PlayerScoreCardConstants.Colors.greenOpacity) : 
                           Color.red.opacity(PlayerScoreCardConstants.Colors.redOpacity))
            .lineLimit(1)
            .opacity(isScoreChangeVisible ? 1.0 : 0.0)
            .scaleEffect(isScoreChangeVisible ? 1.0 : 0.5)
            .animation(.spring(response: InterimResultConstants.Animation.springResponse, 
                             dampingFraction: InterimResultConstants.Animation.springDampingFraction, 
                             blendDuration: InterimResultConstants.Animation.springBlendDuration), 
                      value: isScoreChangeVisible)
    }
    
    private var currentScoreView: some View {
        Text("\(formatScore(animatedScore))")
            .font(.system(
                size: min(cardHeight * PlayerScoreCardConstants.Typography.currentScoreRatio, PlayerScoreCardConstants.Typography.maxCurrentScoreSize),
                weight: .black
            ))
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(Appearance.Color.casinoGoldGlow),
                        Color(Appearance.Color.casinoGoldGlow).opacity(PlayerScoreCardConstants.Colors.casinoGoldGlowOpacity)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: Color(Appearance.Color.casinoGoldGlow).opacity(PlayerScoreCardConstants.Colors.casinoGoldGlow2Opacity), radius: 2, x: 0, y: 0)
            .shadow(color: .black, radius: 1, x: 0, y: 1)
            .lineLimit(1)
    }
    
    // MARK: - Background
    private var casinoCardBackground: some View {
        RoundedRectangle(cornerRadius: PlayerScoreCardConstants.Dimensions.cardCornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(PlayerScoreCardConstants.Colors.blackOpacity1),
                        Color(Appearance.Color.mossGreen).opacity(PlayerScoreCardConstants.Colors.mossGreenOpacity1),
                        Color.black.opacity(PlayerScoreCardConstants.Colors.blackOpacity2),
                        Color(Appearance.Color.mossGreen).opacity(PlayerScoreCardConstants.Colors.mossGreenOpacity2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: PlayerScoreCardConstants.Dimensions.cardCornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                isCurrentPlayer ? 
                                Color(Appearance.Color.playerGold).opacity(PlayerScoreCardConstants.Colors.playerGoldBorderOpacity) : 
                                Color(Appearance.Color.casinoGoldGlow).opacity(PlayerScoreCardConstants.Colors.casinoGoldBorderOpacity),
                                isCurrentPlayer ? 
                                Color(Appearance.Color.casinoGoldGlow).opacity(PlayerScoreCardConstants.Colors.casinoGoldBorder2Opacity) : 
                                Color.white.opacity(PlayerScoreCardConstants.Colors.whiteBorderOpacity)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isCurrentPlayer ? 
                        PlayerScoreCardConstants.Dimensions.playerBorderWidth : 
                        PlayerScoreCardConstants.Dimensions.otherBorderWidth
                    )
            )
            .shadow(
                color: isCurrentPlayer ? 
                Color(Appearance.Color.playerGold).opacity(PlayerScoreCardConstants.Colors.playerGoldShadowOpacity) : 
                Color.black.opacity(PlayerScoreCardConstants.Colors.blackShadowOpacity),
                radius: PlayerScoreCardConstants.Dimensions.shadowRadius,
                x: 0,
                y: PlayerScoreCardConstants.Dimensions.shadowOffset
            )
    }
    
    // MARK: - Animation Methods
    private func startAnimations() {
        // 初期値設定
        animatedScore = player.score - scoreChange
        animatedScoreChange = 0
        
        // カード表示アニメーション
        withAnimation(.spring(response: InterimResultConstants.Animation.springResponse, 
                             dampingFraction: InterimResultConstants.Animation.springDampingFraction, 
                             blendDuration: InterimResultConstants.Animation.springBlendDuration)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }
        
        // スコア変動表示アニメーション
        if scoreChange != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + InterimResultConstants.Animation.scoreChangeDelay) {
                withAnimation(.spring(response: InterimResultConstants.Animation.springResponse, 
                                     dampingFraction: InterimResultConstants.Animation.springDampingFraction, 
                                     blendDuration: InterimResultConstants.Animation.springBlendDuration)) {
                    isScoreChangeVisible = true
                }
                
                // スコア変動のカウントアニメーション
                animateScoreChange()
            }
        }
        
        // 現在スコアのカウントアニメーション
        DispatchQueue.main.asyncAfter(deadline: .now() + InterimResultConstants.Animation.scoreCountDelay) {
            animateCurrentScore()
        }
    }
    
    private func animateScoreChange() {
        let steps = min(abs(scoreChange), 20) // 最大20ステップ
        let stepValue = scoreChange / steps
        let stepDuration = InterimResultConstants.Animation.scoreCountDuration / Double(steps)
        
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                withAnimation(.easeInOut(duration: stepDuration * 0.5)) {
                    if i == steps {
                        animatedScoreChange = scoreChange
                    } else {
                        animatedScoreChange = stepValue * i
                    }
                }
            }
        }
    }
    
    private func animateCurrentScore() {
        let startScore = player.score - scoreChange
        let endScore = player.score
        let totalChange = endScore - startScore
        
        if totalChange == 0 {
            animatedScore = endScore
            return
        }
        
        let steps = min(abs(totalChange), 30) // 最大30ステップ
        let stepValue = totalChange / steps
        let stepDuration = InterimResultConstants.Animation.scoreCountDuration / Double(steps)
        
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                withAnimation(.easeInOut(duration: stepDuration * 0.5)) {
                    if i == steps {
                        animatedScore = endScore
                    } else {
                        animatedScore = startScore + (stepValue * i)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatScore(_ score: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: score)) ?? "\(score)"
    }
} 