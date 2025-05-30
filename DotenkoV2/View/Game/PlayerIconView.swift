import SwiftUI

// MARK: - Test Data Provider
private struct TestDataProvider {
    static let testCards: [Card] = [
        Card(card: .spade1, location: .hand(playerIndex: 0, cardIndex: 0)),
        Card(card: .heart5, location: .hand(playerIndex: 0, cardIndex: 1)),
        Card(card: .diamond10, location: .hand(playerIndex: 0, cardIndex: 2)),
        Card(card: .club7, location: .hand(playerIndex: 0, cardIndex: 3)),
        Card(card: .spade13, location: .hand(playerIndex: 0, cardIndex: 4)),
        Card(card: .heart2, location: .hand(playerIndex: 0, cardIndex: 5)),
        Card(card: .diamond8, location: .hand(playerIndex: 0, cardIndex: 6))
    ]
}

// MARK: - Player Image Component
private struct PlayerImageView: View {
    let player: Player
    let size: CGFloat
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        Group {
            if let imageUrl = player.image, !imageUrl.isEmpty {
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
    let position: PlayerPosition
    let config: PlayerLayoutConfig.HandConfiguration
    @ObservedObject var viewModel: GameViewModel
    @Binding var cardAnimationStates: [Bool]
    
    private let cards = TestDataProvider.testCards
    
    var body: some View {
        ZStack {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                CardView(card: card, size: config.cardSize)
                    .rotationEffect(.degrees(FanLayoutManager.cardRotation(for: index, position: position, totalCards: cards.count, config: config)))
                    .offset(FanLayoutManager.cardOffset(for: index, position: position, totalCards: cards.count, config: config))
                    .offset(y: cardSelectionOffset(for: index))
                    .onTapGesture {
                        handleCardTap(at: index)
                    }
                    .onAppear {
                        cardAnimationStates[index] = viewModel.isCardSelected(at: index)
                    }
                    .onChange(of: viewModel.selectedCardIndices) { _, _ in
                        syncAnimationState(for: index)
                    }
            }
        }
        .frame(width: config.handAreaSize.width, height: config.handAreaSize.height)
    }
    
    private func cardSelectionOffset(for index: Int) -> CGFloat {
        position == .bottom && cardAnimationStates[index] ? PlayerIconConstants.Animation.cardSelectionOffset : 0
    }
    
    private func handleCardTap(at index: Int) {
        guard position == .bottom else { return }
        
        viewModel.toggleCardSelection(at: index)
        withAnimation(.easeInOut(duration: PlayerIconConstants.Animation.duration)) {
            cardAnimationStates[index] = viewModel.isCardSelected(at: index)
        }
    }
    
    private func syncAnimationState(for index: Int) {
        let newState = viewModel.isCardSelected(at: index)
        guard cardAnimationStates[index] != newState else { return }
        
        withAnimation(.easeInOut(duration: PlayerIconConstants.Animation.duration)) {
            cardAnimationStates[index] = newState
        }
    }
}

// MARK: - Main Player Icon View
struct PlayerIconView: View {
    let player: Player
    let position: PlayerPosition
    @ObservedObject var viewModel: GameViewModel
    
    @State private var cardAnimationStates: [Bool] = Array(repeating: false, count: 7)
    
    private var config: (icon: PlayerLayoutConfig.IconPosition, hand: PlayerLayoutConfig.HandConfiguration) {
        PlayerLayoutConfig.configuration(for: position)
    }
    
    var body: some View {
        ZStack {
            HandCardsView(
                position: position,
                config: config.hand,
                viewModel: viewModel,
                cardAnimationStates: $cardAnimationStates
            )
            .offset(config.hand.globalOffset)
            .rotationEffect(.degrees(config.hand.globalRotation))
            
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
        }
    }
}

