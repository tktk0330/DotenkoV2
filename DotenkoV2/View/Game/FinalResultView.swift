import SwiftUI

// MARK: - Main View
/// 最終結果画面
/// 全ラウンド終了後に最終スコアと順位を表示する画面
struct FinalResultView: View {
    @ObservedObject var viewModel: GameViewModel
    let onOKAction: () -> Void
    
    var body: some View {
        ZStack {
            backgroundView
            contentScrollView
        }
        .onAppear {
            print("🏆 最終結果画面表示")
        }
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        Appearance.Color.finalResultBackground
            .opacity(FinalResultConstants.Colors.backgroundOpacity)
            .ignoresSafeArea()
    }
    
    // MARK: - Content
    private var contentScrollView: some View {
        ScrollView {
            VStack(spacing: FinalResultConstants.Layout.sectionSpacing) {
                FinalResultTitleView()
                FinalResultRankingView(
                    players: sortedPlayers,
                    getRankColor: getRankColor
                )
                FinalResultHomeButton(action: onOKAction)
            }
            .padding(.horizontal, FinalResultConstants.Layout.horizontalPadding)
            .padding(.top, FinalResultConstants.Layout.topPadding)
            .padding(.bottom, FinalResultConstants.Layout.bottomPadding)
        }
    }
    
    // MARK: - Helper Methods
    private var sortedPlayers: [Player] {
        viewModel.players.sorted { $0.score > $1.score }
    }
    
    private func getRankColor(for rank: Int) -> Color {
        let index = rank - 1
        if index < FinalResultConstants.RankColors.colors.count {
            return FinalResultConstants.RankColors.colors[index]
        }
        return FinalResultConstants.RankColors.fallbackColor
    }
}

// MARK: - Title Component
private struct FinalResultTitleView: View {
    var body: some View {
        VStack(spacing: FinalResultConstants.Layout.titleSpacing) {
            Text("最終結果")
                .font(.system(size: FinalResultConstants.Typography.titleSize, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Appearance.Color.finalResultShadow.opacity(0.3), radius: 2, x: 0, y: 1)
            
            Rectangle()
                .fill(Appearance.Color.finalResultDivider.opacity(FinalResultConstants.Colors.dividerOpacity))
                .frame(height: FinalResultConstants.Dimensions.dividerHeight)
                .frame(maxWidth: FinalResultConstants.Dimensions.dividerMaxWidth)
        }
    }
}

// MARK: - Ranking Component
private struct FinalResultRankingView: View {
    let players: [Player]
    let getRankColor: (Int) -> Color
    
    var body: some View {
        VStack(spacing: FinalResultConstants.Layout.rankingSpacing) {
            ForEach(players.indices, id: \.self) { index in
                let player = players[index]
                let rank = index + 1
                
                FinalPlayerRankCard(
                    player: player,
                    rank: rank,
                    rankColor: getRankColor(rank),
                    isCurrentPlayer: player.id == "player"
                )
            }
        }
        .padding(.horizontal, FinalResultConstants.Layout.rankingHorizontalPadding)
    }
}

// MARK: - Home Button Component
private struct FinalResultHomeButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: FinalResultConstants.Dimensions.homeButtonSpacing) {
                Image(systemName: "house.fill")
                    .font(.system(size: FinalResultConstants.Typography.homeButtonSize, weight: .bold))
                Text("HOME")
                    .font(.system(size: FinalResultConstants.Typography.homeButtonSize, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: FinalResultConstants.Dimensions.homeButtonHeight)
            .background(homeButtonBackground)
        }
        .padding(.horizontal, FinalResultConstants.Dimensions.homeButtonHorizontalPadding)
        .padding(.top, FinalResultConstants.Dimensions.homeButtonTopPadding)
    }
    
    private var homeButtonBackground: some View {
        RoundedRectangle(cornerRadius: FinalResultConstants.Dimensions.homeButtonCornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.homeButtonGold.opacity(FinalResultConstants.Colors.goldOpacity),
                        Appearance.Color.homeButtonDarkGold.opacity(FinalResultConstants.Colors.goldSecondaryOpacity)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(
                color: Appearance.Color.finalResultShadow.opacity(FinalResultConstants.Colors.shadowOpacity),
                radius: FinalResultConstants.Dimensions.shadowRadius,
                x: 0,
                y: FinalResultConstants.Dimensions.shadowOffset
            )
    }
}

// MARK: - Player Rank Card
struct FinalPlayerRankCard: View {
    let player: Player
    let rank: Int
    let rankColor: Color
    let isCurrentPlayer: Bool
    
    var body: some View {
        VStack(spacing: RankCardConstants.Layout.cardSpacing) {
            playerHeaderView
            playerScoreView
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, RankCardConstants.Layout.horizontalPadding)
        .padding(.vertical, RankCardConstants.Layout.verticalPadding)
        .background(cardBackground)
        .scaleEffect(rank == 1 ? RankCardConstants.Dimensions.firstPlaceScale : RankCardConstants.Dimensions.normalScale)
        .animation(.easeInOut(duration: RankCardConstants.Animation.duration), value: rank)
    }
    
    // MARK: - Header Section
    private var playerHeaderView: some View {
        HStack(spacing: RankCardConstants.Layout.headerSpacing) {
            rankNumberView
            playerIconView
            playerNameView
            Spacer()
        }
    }
    
    private var rankNumberView: some View {
        Text("\(rank)")
            .font(.system(size: RankCardConstants.Typography.rankSize, weight: .black))
            .foregroundColor(rankColor)
            .shadow(color: Appearance.Color.finalResultShadow, radius: 2, x: 0, y: 1)
            .frame(width: RankCardConstants.Dimensions.rankWidth, alignment: .center)
    }
    
    private var playerIconView: some View {
        ZStack {
            Circle()
                .stroke(rankColor, lineWidth: RankCardConstants.Dimensions.iconBorderWidth)
                .frame(width: RankCardConstants.Dimensions.iconSize, height: RankCardConstants.Dimensions.iconSize)
            
            if let iconUrl = player.icon_url, !iconUrl.isEmpty {
                CachedImageView(
                    imageUrl: iconUrl,
                    size: RankCardConstants.Dimensions.iconImageSize,
                    isBot: player.id.hasPrefix("bot-")
                )
            } else {
                Text(String(player.name.prefix(1)))
                    .font(.system(size: RankCardConstants.Typography.iconTextSize, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Appearance.Color.finalResultShadow, radius: 1, x: 0, y: 1)
            }
        }
    }
    
    private var playerNameView: some View {
        Text(player.name)
            .font(.system(size: RankCardConstants.Typography.nameSize, weight: .bold))
            .foregroundColor(.white)
            .shadow(color: Appearance.Color.finalResultShadow, radius: 1, x: 0, y: 1)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
    
    // MARK: - Score Section
    private var playerScoreView: some View {
        HStack {
            Spacer()
            Text("\(player.score)")
                .font(.system(size: RankCardConstants.Typography.scoreSize, weight: .black))
                .foregroundColor(rankColor)
                .shadow(color: Appearance.Color.finalResultShadow, radius: 2, x: 0, y: 1)
            Spacer()
        }
    }
    
    // MARK: - Background
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: RankCardConstants.Dimensions.cardCornerRadius)
            .fill(cardBackgroundGradient)
            .overlay(cardBorderOverlay)
            .shadow(
                color: rankColor.opacity(RankCardConstants.Colors.shadowOpacity),
                radius: RankCardConstants.Dimensions.shadowRadius,
                x: 0,
                y: RankCardConstants.Dimensions.shadowOffset
            )
    }
    
    private var cardBackgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                rankColor.opacity(RankCardConstants.Colors.backgroundOpacity),
                rankColor.opacity(RankCardConstants.Colors.backgroundSecondaryOpacity)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var cardBorderOverlay: some View {
        RoundedRectangle(cornerRadius: RankCardConstants.Dimensions.cardCornerRadius)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        rankColor.opacity(RankCardConstants.Colors.borderOpacity),
                        rankColor.opacity(RankCardConstants.Colors.borderSecondaryOpacity)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: RankCardConstants.Dimensions.cardBorderWidth
            )
    }
}
