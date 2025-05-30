import SwiftUI

// MARK: - Player Icon View
struct PlayerIconView: View {
    let player: Player
    let position: PlayerPosition
    @StateObject private var imageLoader = ImageLoader()
    @ObservedObject var viewModel: GameViewModel
    
    // アニメーション制御用の状態
    @State private var cardAnimationStates: [Bool] = Array(repeating: false, count: 7)
    
    // 試験的に7枚の手札を表示
    private let testCards: [Card] = [
        Card(card: .spade1, location: .hand(playerIndex: 0, cardIndex: 0)),
        Card(card: .heart5, location: .hand(playerIndex: 0, cardIndex: 1)),
        Card(card: .diamond10, location: .hand(playerIndex: 0, cardIndex: 2)),
        Card(card: .club7, location: .hand(playerIndex: 0, cardIndex: 3)),
        Card(card: .spade13, location: .hand(playerIndex: 0, cardIndex: 4)),
        Card(card: .heart2, location: .hand(playerIndex: 0, cardIndex: 5)),
        Card(card: .diamond8, location: .hand(playerIndex: 0, cardIndex: 6))
    ]
    
    // 設定を取得
    private var config: (icon: PlayerLayoutConfig.IconPosition, hand: PlayerLayoutConfig.HandConfiguration) {
        PlayerLayoutConfig.configuration(for: position)
    }
    
    var body: some View {
        ZStack {
            // 手札表示（下に配置）
            handCardsView
                .offset(config.hand.globalOffset)
                .rotationEffect(.degrees(config.hand.globalRotation))
            
            // プレイヤーアイコン（上に配置）
            VStack(spacing: 1) {
                playerIcon
                
                // プレイヤー名
                if position != .bottom {
                    Text(player.name)
                        .font(.system(size: config.icon.nameTextSize, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(maxWidth: config.icon.size + 20)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                
                // スコア表示（自分とBotで異なるデザイン）
                if position == .bottom {
                    playerScoreDisplay
                } else {
                    botScoreDisplay
                }
            }
            .offset(config.icon.offset)
        }
    }
    
    private var playerIcon: some View {
        ZStack {
            if let imageUrl = player.image {
                if player.id.hasPrefix("bot-") {
                    // Botの場合は内部の画像を使用
                    if let image = UIImage(named: imageUrl) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                } else {
                    // ユーザーの場合はURLから読み込み
                    if let uiImage = imageLoader.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ProgressView()
                            .onAppear {
                                imageLoader.loadImage(from: imageUrl)
                            }
                    }
                }
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: config.icon.size, height: config.icon.size)
        .background(Color.black.opacity(0.3))
        .clipShape(Circle())
        .overlay(
            // 自分のアイコンの場合は特別な装飾を追加
            Group {
                if position == .bottom {
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.84, blue: 0.0), // ゴールド
                                    Color(red: 0.8, green: 0.6, blue: 0.0),
                                    Color(red: 1.0, green: 0.84, blue: 0.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.5), radius: 6, x: 0, y: 3)
                } else {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                }
            }
        )
        .shadow(
            color: position == .bottom ? Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.3) : .black.opacity(0.3),
            radius: position == .bottom ? 8 : 4,
            x: 0,
            y: position == .bottom ? 4 : 2
        )
    }
    
    private var handCardsView: some View {
        ZStack {
            ForEach(Array(testCards.enumerated()), id: \.element.id) { index, card in
                let isSelected = viewModel.isCardSelected(at: index)
                
                CardView(card: card, size: config.hand.cardSize)
                    .rotationEffect(.degrees(FanLayoutManager.cardRotation(for: index, position: position, totalCards: testCards.count, config: config.hand)))
                    .offset(FanLayoutManager.cardOffset(for: index, position: position, totalCards: testCards.count, config: config.hand))
                    // 選択時のy軸移動とスケール変更
                    .offset(y: position == .bottom && cardAnimationStates[index] ? -30 : 0)
                    .scaleEffect(position == .bottom && cardAnimationStates[index] ? 1.15 : 1.0)
                    .shadow(
                        color: position == .bottom && cardAnimationStates[index] ? .yellow.opacity(0.6) : .clear,
                        radius: position == .bottom && cardAnimationStates[index] ? 8 : 0,
                        x: 0,
                        y: position == .bottom && cardAnimationStates[index] ? 4 : 0
                    )
                    .onTapGesture {
                        if position == .bottom {
                            // ViewModelの状態を更新
                            viewModel.toggleCardSelection(at: index)
                            
                            // アニメーション状態を更新
                            withAnimation(.easeInOut(duration: 0.8)) {
                                cardAnimationStates[index] = viewModel.isCardSelected(at: index)
                            }
                        }
                    }
                    .onAppear {
                        // 初期状態を同期
                        cardAnimationStates[index] = viewModel.isCardSelected(at: index)
                    }
                    .onChange(of: viewModel.selectedCardIndices) { _ in
                        // ViewModelの変更を監視してアニメーション状態を同期
                        let newState = viewModel.isCardSelected(at: index)
                        if cardAnimationStates[index] != newState {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                cardAnimationStates[index] = newState
                            }
                        }
                    }
            }
        }
        .frame(width: config.hand.handAreaSize.width, height: config.hand.handAreaSize.height)
    }
    
    private var playerScoreDisplay: some View {
        VStack(spacing: 4) {
            Text("100,000")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.white)
                .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.1),
                            Color(red: 0.2, green: 0.2, blue: 0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.84, blue: 0.0),
                                    Color(red: 0.8, green: 0.6, blue: 0.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
        )
    }
    
    private var botScoreDisplay: some View {
        Text("50,000")
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.gray)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            )
    }
}
