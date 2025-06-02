import SwiftUI

// MARK: - Player Image Component
private struct PlayerImageView: View {
    let player: Player
    let size: CGFloat
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        Group {
            if let imageUrl = player.icon_url, !imageUrl.isEmpty {
                if player.id.hasPrefix("bot-") {
                    localImageView(imageUrl: imageUrl)
                } else if imageUrl.hasPrefix("http") {
                    remoteImageView(imageUrl: imageUrl)
                } else {
                    localImageView(imageUrl: imageUrl)
                }
            } else {
                defaultImageView
            }
        }
    }
    
    @ViewBuilder
    private func localImageView(imageUrl: String) -> some View {
        if let image = UIImage(named: imageUrl) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            defaultImageView
        }
    }
    
    @ViewBuilder
    private func remoteImageView(imageUrl: String) -> some View {
        if let uiImage = imageLoader.image {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if imageLoader.isLoading {
            ProgressView()
                .onAppear {
                    imageLoader.loadImage(from: imageUrl)
                }
        } else {
            defaultImageView
                .onAppear {
                    if imageLoader.image == nil && !imageLoader.isLoading {
                        imageLoader.loadImage(from: imageUrl)
                    }
                }
        }
    }
    
    private var defaultImageView: some View {
        Image(systemName: Appearance.Icon.personFill)
            .resizable()
            .scaledToFit()
            .padding(8)
            .foregroundColor(Appearance.Color.commonWhite)
    }
}

// MARK: - Player Score Component
private struct PlayerScoreView: View {
    let score: String
    let isMainPlayer: Bool
    
    var body: some View {
        if isMainPlayer {
            mainPlayerScore
        } else {
            botPlayerScore
        }
    }
    
    private var mainPlayerScore: some View {
        VStack(spacing: PlayerIconConstants.Spacing.scoreVertical) {
            Text(score)
                .font(.system(size: 14, weight: .black))
                .foregroundColor(Appearance.Color.commonWhite)
                .shadow(color: Appearance.Color.playerGold, radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(mainPlayerScoreBackground)
    }
    
    private var mainPlayerScoreBackground: some View {
        RoundedRectangle(cornerRadius: PlayerIconConstants.Decoration.scoreCornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.playerDarkBackground,
                        Appearance.Color.playerMediumBackground
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: PlayerIconConstants.Decoration.scoreCornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Appearance.Color.playerGold,
                                Appearance.Color.playerDarkGold
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Appearance.Color.commonBlack.opacity(0.5), radius: 4, x: 0, y: 2)
    }
    
    private var botPlayerScore: some View {
        Text(score)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(Appearance.Color.commonGray)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: PlayerIconConstants.Decoration.botScoreCornerRadius)
                    .fill(Appearance.Color.commonBlack.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: PlayerIconConstants.Decoration.botScoreCornerRadius)
                            .stroke(Appearance.Color.commonGray.opacity(0.5), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Player Icon Container
private struct PlayerIconContainer: View {
    let player: Player
    let position: PlayerPosition
    let config: PlayerLayoutConfig.IconPosition
    
    var body: some View {
        PlayerImageView(player: player, size: config.size)
            .frame(width: config.size, height: config.size)
            .background(Appearance.Color.commonBlack.opacity(0.3))
            .clipShape(Circle())
            .overlay(borderOverlay)
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowOffset
            )
    }
    
    @ViewBuilder
    private var borderOverlay: some View {
        if position == .bottom {
            Circle()
                .stroke(goldGradient, lineWidth: PlayerIconConstants.Decoration.playerBorderWidth)
                .shadow(color: Appearance.Color.playerGold.opacity(0.5), radius: 6, x: 0, y: 3)
        } else {
            Circle()
                .stroke(Appearance.Color.commonWhite, lineWidth: PlayerIconConstants.Decoration.botBorderWidth)
        }
    }
    
    private var goldGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Appearance.Color.playerGold,
                Appearance.Color.playerDarkGold,
                Appearance.Color.playerGold
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var shadowColor: Color {
        position == .bottom ? Appearance.Color.playerGold.opacity(0.3) : Appearance.Color.commonBlack.opacity(0.3)
    }
    
    private var shadowRadius: CGFloat {
        position == .bottom ? 8 : 4
    }
    
    private var shadowOffset: CGFloat {
        position == .bottom ? 4 : 2
    }
}

// MARK: - Player Name Component
private struct PlayerNameView: View {
    let playerName: String
    let config: PlayerLayoutConfig.IconPosition
    
    var body: some View {
        Text(playerName)
            .font(.system(size: config.nameTextSize, weight: .medium))
            .foregroundColor(Appearance.Color.commonWhite)
            .lineLimit(1)
            .frame(maxWidth: config.size + 20)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(nameBackground)
    }
    
    private var nameBackground: some View {
        RoundedRectangle(cornerRadius: PlayerIconConstants.Decoration.nameCornerRadius)
            .fill(Appearance.Color.commonBlack.opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: PlayerIconConstants.Decoration.nameCornerRadius)
                    .stroke(Appearance.Color.commonWhite.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Hand Cards Component  
private struct HandCardsView: View {
    let player: Player
    let position: PlayerPosition
    let config: PlayerLayoutConfig.HandConfiguration
    @ObservedObject var viewModel: GameViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        // 固定幅のコンテナ内で手札を中央配置
        HStack {
            Spacer()
            
            HStack(spacing: adaptiveSpacing) {
                ForEach(Array(player.hand.enumerated()), id: \.element.id) { index, card in
                    let isSelected = player.selectedCards.contains(card)
                    
                    CardView(card: card, size: adaptiveCardSize)
                        .matchedGeometryEffect(id: card.id, in: namespace)
                        .offset(y: cardSelectionOffset(for: card))
                        .onTapGesture {
                            handleCardTap(card: card)
                        }
                        .animation(.easeInOut(duration: PlayerIconConstants.Animation.duration), value: isSelected)
                }
            }
            
            Spacer()
        }
        .frame(width: fixedHandAreaWidth, height: fixedHandAreaHeight)
    }
    
    // MARK: - Fixed Layout Settings
    
    /// 固定された手札エリア幅（カード数に関係なく固定）
    private var fixedHandAreaWidth: CGFloat {
        switch position {
        case .bottom:
            return 220
        case .top:
            return 160
        case .left, .right:
            return 100
        }
    }
    
    /// 固定された手札エリア高さ
    private var fixedHandAreaHeight: CGFloat {
        switch position {
        case .bottom:
            return 85
        case .top:
            return 45
        case .left, .right:
            return 45
        }
    }
    
    /// 1-10枚に最適化されたカードサイズ
    private var adaptiveCardSize: CGFloat {
        let handCount = max(player.hand.count, 1)
        let baseSize = config.cardSize
        
        switch position {
        case .bottom:
            switch handCount {
            case 1...3:
                return baseSize
            case 4...6:
                return baseSize * 0.95
            case 7...8:
                return baseSize * 0.85
            case 9...10:
                return baseSize * 0.75
            default:
                return baseSize * 0.75
            }
        case .top:
            switch handCount {
            case 1...4:
                return baseSize * 0.8
            case 5...7:
                return baseSize * 0.7
            case 8...10:
                return baseSize * 0.6
            default:
                return baseSize * 0.6
            }
        case .left, .right:
            switch handCount {
            case 1...4:
                return baseSize * 0.7
            case 5...7:
                return baseSize * 0.6
            case 8...10:
                return baseSize * 0.5
            default:
                return baseSize * 0.5
            }
        }
    }
    
    /// 1-10枚に最適化されたスペーシング
    private var adaptiveSpacing: CGFloat {
        let handCount = player.hand.count
        
        if handCount <= 1 {
            return 0
        }
        
        switch position {
        case .bottom:
            switch handCount {
            case 2...3:
                return -10
            case 4...5:
                return -15
            case 6...7:
                return -20
            case 8...9:
                return -25
            case 10:
                return -30
            default:
                return -30
            }
        case .top:
            switch handCount {
            case 2...4:
                return -5
            case 5...6:
                return -8
            case 7...8:
                return -12
            case 9...10:
                return -15
            default:
                return -15
            }
        case .left, .right:
            switch handCount {
            case 2...4:
                return -3
            case 5...6:
                return -5
            case 7...8:
                return -8
            case 9...10:
                return -10
            default:
                return -10
            }
        }
    }
    
    private func cardSelectionOffset(for card: Card) -> CGFloat {
        let isSelected = player.selectedCards.contains(card)
        return position == .bottom && isSelected ? PlayerIconConstants.Animation.cardSelectionOffset : 0
    }
    
    private func handleCardTap(card: Card) {
        guard position == .bottom else { return }
        
        viewModel.togglePlayerCardSelection(playerId: player.id, card: card)
    }
}

// MARK: - Main Player Icon View
struct PlayerIconView: View {
    let player: Player
    let position: PlayerPosition
    @ObservedObject var viewModel: GameViewModel
    let namespace: Namespace.ID
    
    private var config: (icon: PlayerLayoutConfig.IconPosition, hand: PlayerLayoutConfig.HandConfiguration) {
        PlayerLayoutConfig.configuration(for: position)
    }
    
    var body: some View {
        ZStack {
            // 手札を配置（アイコンの後ろに来るようにzIndex調整）
            HandCardsView(
                player: player,
                position: position,
                config: config.hand,
                viewModel: viewModel,
                namespace: namespace
            )
            .offset(config.hand.globalOffset)
            .zIndex(position == .bottom ? 1 : 0)
            
            // プレイヤーアイコンとUI要素
            VStack(spacing: PlayerIconConstants.Spacing.nameVertical) {
                PlayerIconContainer(player: player, position: position, config: config.icon)
                
                if position != .bottom {
                    PlayerNameView(playerName: player.name, config: config.icon)
                }
                
                PlayerScoreView(
                    score: position == .bottom ? "100,000" : "50,000",
                    isMainPlayer: position == .bottom
                )
            }
            .offset(config.icon.offset)
            .zIndex(position == .bottom ? 2 : 1)
        }
    }
}

