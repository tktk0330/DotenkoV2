import SwiftUI

// MARK: - Player Image Component
private struct PlayerImageView: View {
    let player: Player
    let size: CGFloat
    
    var body: some View {
        CachedImageView(
            imageUrl: player.icon_url,
            size: size,
            isBot: player.id.hasPrefix("bot-")
        )
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
            .foregroundColor(Appearance.Color.commonWhite)
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
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        PlayerImageView(player: player, size: config.size)
            .frame(width: config.size, height: config.size)
            .background(backgroundForTurn)
            .clipShape(Circle())
            .overlay(borderOverlay)
            .overlay(handCountBadgeOverlay, alignment: .top)
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowOffset
            )
    }
    
    /// ターン状態に応じた背景色
    @ViewBuilder
    private var backgroundForTurn: some View {
        let isCurrentTurn = viewModel.isPlayerTurn(playerId: player.id)
        
        if isCurrentTurn {
            // 現在のターンの場合：明るい背景
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.playerGold.opacity(0.6),
                            Appearance.Color.playerDarkGold.opacity(0.4)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .animation(.easeInOut(duration: 0.3), value: isCurrentTurn)
        } else {
            // 通常時：暗い背景
            Circle()
                .fill(Appearance.Color.commonBlack.opacity(0.3))
                .animation(.easeInOut(duration: 0.3), value: isCurrentTurn)
        }
    }
    
    @ViewBuilder
    private var borderOverlay: some View {
        let isCurrentTurn = viewModel.isPlayerTurn(playerId: player.id)
        
        if position == .bottom {
            Circle()
                .stroke(goldGradient, lineWidth: PlayerIconConstants.Decoration.playerBorderWidth)
                .shadow(color: Appearance.Color.playerGold.opacity(0.5), radius: 6, x: 0, y: 3)
        } else {
            Circle()
                .stroke(
                    isCurrentTurn ? Appearance.Color.playerGold : Appearance.Color.commonWhite,
                    lineWidth: isCurrentTurn ? 3 : PlayerIconConstants.Decoration.botBorderWidth
                )
                .animation(.easeInOut(duration: 0.3), value: isCurrentTurn)
        }
    }
    
    @ViewBuilder
    private var handCountBadgeOverlay: some View {
        // ⭐ 手札数字バッジの配置調整ポイント
        // - badgeTopOffsetで縦位置を調整
        // - .offset(x: 0, y: badgeTopOffset) のx値を変更すると横位置が調整可能
        // - 例: .offset(x: 10, y: badgeTopOffset) で右に10pt移動
        HandCountBadgeView(handCount: player.hand.count, position: position)
            .offset(x: 0, y: badgeTopOffset) // ← ここで位置調整
    }
    
    // ⭐ 手札数字バッジの縦位置計算
    // この関数を修正することで、バッジとアイコンの距離を調整できます
    private var badgeTopOffset: CGFloat {
        let badgeSize: CGFloat = position == .bottom ? PlayerIconConstants.HandCountBadge.playerBadgeSize : PlayerIconConstants.HandCountBadge.botBadgeSize
        let iconRadius = config.size / 2
        
        // ⭐ バッジ位置の調整ポイント
        // PlayerIconConstants.HandCountBadge.iconSpacing の値を変更すると
        // バッジとアイコンの間隔を調整できます
        // 正の値：バッジがアイコンから離れる
        // 負の値：バッジがアイコンに近づく
        return -iconRadius - badgeSize / 2 + PlayerIconConstants.HandCountBadge.iconSpacing
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

// MARK: - Hand Count Badge Component
private struct HandCountBadgeView: View {
    let handCount: Int
    let position: PlayerPosition
    
    var body: some View {
        Text("\(handCount)")
            .font(.system(size: badgeTextSize, weight: .bold))
            .foregroundColor(Appearance.Color.commonWhite)
            .frame(width: badgeSize, height: badgeSize)
            .background(casinoBadgeBackground)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(casinoBorderColor, lineWidth: 2)
            )
            .shadow(color: Appearance.Color.commonBlack.opacity(0.4), radius: 3, x: 0, y: 2)
    }
    
    private var badgeSize: CGFloat {
        position == .bottom ? PlayerIconConstants.HandCountBadge.playerBadgeSize : PlayerIconConstants.HandCountBadge.botBadgeSize
    }
    
    private var badgeTextSize: CGFloat {
        position == .bottom ? PlayerIconConstants.HandCountBadge.playerTextSize : PlayerIconConstants.HandCountBadge.botTextSize
    }
    
    private var casinoBadgeBackground: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        PlayerIconConstants.HandCountBadge.CasinoColors.redTop,
                        PlayerIconConstants.HandCountBadge.CasinoColors.redMiddle,
                        PlayerIconConstants.HandCountBadge.CasinoColors.redBottom
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    private var casinoBorderColor: Color {
        PlayerIconConstants.HandCountBadge.CasinoColors.goldBorder
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
        // すべてのプレイヤーに扇形配置を適用
        fanLayoutHandCards
            .offset(handOffset) // 位置に応じた適切なオフセットを適用
    }
    
    // MARK: - Card Display Control
    /// カードの表面を表示するかどうかを判定
    private var shouldShowCardFront: Bool {
        // 自分（bottom）の手札は常に表面を表示
        if position == .bottom {
            return true
        }
        
        // チャレンジゾーン中は全プレイヤーの手札を表面表示
        if viewModel.showHandReveal {
            return true
        }
        
        // 他のプレイヤーの手札は設定に応じて表示
        // DEBUG時またはisCardOpenがtrueの場合は表面を表示
        return Config.GameConfig.isCardOpen
    }
    
    // MARK: - Fan Layout (扇形配置)
    /// 手札を扇形に配置（全プレイヤー対応）
    private var fanLayoutHandCards: some View {
        ZStack {
            ForEach(Array(player.hand.enumerated()), id: \.element.id) { index, card in
                let isSelected = player.selectedCards.contains(card)
                let total = player.hand.count
                let cardPosition = calculateFanPosition(index: index, total: total)
                let cardAngle = calculateFanAngle(index: index, total: total)
                
                CardView(
                    card: card, 
                    size: adaptiveCardSize,
                    showFront: shouldShowCardFront
                )
                    .matchedGeometryEffect(id: card.id, in: namespace)
                    .rotationEffect(.degrees(cardAngle))
                    .offset(cardPosition)
                    .offset(y: cardSelectionOffset(for: card))
                    .onTapGesture {
                        handleCardTap(card: card)
                    }
                    .onAppear {
                        // カードの角度をモデルに記録
                        viewModel.updateCardHandRotation(playerId: player.id, cardId: card.id, rotation: cardAngle)
                    }
                    .onChange(of: cardAngle) { newAngle in
                        // 角度が変更された際にも記録を更新
                        viewModel.updateCardHandRotation(playerId: player.id, cardId: card.id, rotation: newAngle)
                    }
                    .animation(.easeInOut(duration: PlayerIconConstants.Animation.duration), value: isSelected)
            }
        }
        .frame(width: fixedHandAreaWidth, height: fixedHandAreaHeight)
        // ⭐ 中心対称配置は calculateFanPosition と calculateFanAngle で実現
    }
    
    // MARK: - Fan Layout Calculations
    
    /// 扇形配置での位置を計算（位置別対応）
    private func calculateFanPosition(index: Int, total: Int) -> CGSize {
        guard total > 0 else { return .zero }
        
        // 位置に応じて設定値を変更
        let cardSpacingDegrees: Double
        let curveCoefficient: Double
        
        switch position {
        case .bottom:
            // 自分の手札：より大きな間隔
            cardSpacingDegrees = PlayerLayoutConstants.Angle.playerCardSpacing
            curveCoefficient = PlayerLayoutConstants.FanLayout.playerCurveCoefficient
        case .top, .left, .right:
            // Bot手札：コンパクトな間隔
            cardSpacingDegrees = PlayerLayoutConstants.Angle.botCardSpacing
            curveCoefficient = PlayerLayoutConstants.FanLayout.botCurveCoefficient
        }
        
        // ⭐ 完全中心対称配置のための精密計算
        // 中心インデックスを小数点精度で計算
        let centerIndex = Double(total - 1) / 2.0
        let centerOffset = Double(index) - centerIndex
        
        // X座標：中心からの距離に基づく横方向の位置（完全対称）
        let x = CGFloat(cardSpacingDegrees * centerOffset)
        
        // Y座標：放物線的な配置（中心からの距離の二乗に比例）
        let y = CGFloat(pow(abs(centerOffset), 2) * cardSpacingDegrees * curveCoefficient)
        
        return CGSize(width: x, height: y)
    }
    
    /// 扇形配置での角度を計算（位置別対応）
    private func calculateFanAngle(index: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        
        // 位置に応じて傾き角度を調整
        let cardTiltDegrees: Double
        
        switch position {
        case .bottom:
            // 自分の手札：より大きな傾き
            cardTiltDegrees = PlayerLayoutConstants.Angle.playerCardTilt
        case .top, .left, .right:
            // Bot手札：控えめな傾き
            cardTiltDegrees = PlayerLayoutConstants.Angle.botCardTilt
        }
        
        // ⭐ 中心対称角度計算のための精密計算
        // 完全に中心を基準とした対称角度を実現
        let centerIndex = Double(total - 1) / 2.0  // 中心インデックス（小数点対応）
        let centerOffset = Double(index) - centerIndex  // 中心からの距離
        
        return cardTiltDegrees * centerOffset
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
    
    /// カードサイズ（参加人数による自動調整）
    // ⭐ 参加人数によるカードサイズ調整：
    // Botのカードは参加人数が多いほど小さくして、画面レイアウトに収まるように調整します
    // プレイヤー自身（bottom）のカードは参加人数に関係なく固定サイズです
    // viewModel.maxPlayers の値に応じて基本サイズを倍率調整します
    private var adaptiveCardSize: CGFloat {
        let baseSize = config.cardSize // ← この値がGameLayoutConfig.swiftから取得される基本カードサイズ
        
        // プレイヤー自身（bottom）は参加人数に関係なく固定サイズ
        if position == .bottom {
            return baseSize
        }
        
        // Botプレイヤーのみ参加人数による調整を適用
        let playerCount = viewModel.maxPlayers // ← 参加人数を取得
        
        // 参加人数による調整倍率を計算
        let sizeMultiplier: CGFloat = {
            switch playerCount {
            case 2:
                return 1.2  // 2人：20%拡大
            case 3:
                return 1.0  // 3人：基本サイズ
            case 4:
                return 0.85 // 4人：15%縮小
            case 5:
                return 0.7  // 5人：30%縮小
            default:
                return 0.6  // 6人以上：40%縮小
            }
        }()
        
        // 基本サイズに倍率を適用（Botのみ）
        return baseSize * sizeMultiplier
    }
    
    /// スペーシング（参加人数による自動調整）
    // ⭐ 参加人数によるスペーシング調整：
    // Botプレイヤーは参加人数が多いほどスペーシングを調整して、画面レイアウトに適切に配置します
    // プレイヤー自身（bottom）のスペーシングは参加人数に関係なく固定値です
    private var adaptiveSpacing: CGFloat {
        let handCount = player.hand.count
        
        if handCount <= 1 {
            return 0
        }
        
        // プレイヤー自身（bottom）は参加人数に関係なく固定スペーシング
        if position == .bottom {
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
        }
        
        // Botプレイヤーのみ参加人数による調整を適用
        let playerCount = viewModel.maxPlayers // ← 参加人数を取得
        
        // 参加人数による基本スペーシング調整
        let spacingMultiplier: CGFloat = {
            switch playerCount {
            case 2:
                return 0.8  // 2人：スペーシング縮小
            case 3:
                return 1.0  // 3人：基本スペーシング
            case 4:
                return 1.2  // 4人：スペーシング拡大
            case 5:
                return 1.4  // 5人：スペーシング大幅拡大
            default:
                return 1.6  // 6人以上：最大スペーシング拡大
            }
        }()
        
        switch position {
        case .top:
            switch handCount {
            case 2...4:
                return -5 * spacingMultiplier
            case 5...6:
                return -8 * spacingMultiplier
            case 7...8:
                return -12 * spacingMultiplier
            case 9...10:
                return -15 * spacingMultiplier
            default:
                return -15 * spacingMultiplier
            }
        case .left, .right:
            switch handCount {
            case 2...4:
                return -3 * spacingMultiplier
            case 5...6:
                return -5 * spacingMultiplier
            case 7...8:
                return -8 * spacingMultiplier
            case 9...10:
                return -10 * spacingMultiplier
            default:
                return -10 * spacingMultiplier
            }
        default:
            return 0
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
    
    // MARK: - Dynamic Position Adjustment
    /// 参加人数に応じて手札の位置を動的調整
    private var adjustedGlobalOffset: CGSize {
        let baseOffset = config.globalOffset
        let playerCount = viewModel.maxPlayers
        
        switch position {
        case .top:
            // 全ての人数で上部Botを下に移動
            return CGSize(
                width: baseOffset.width, 
                height: baseOffset.height + LayoutConstants.PlayerCountAdjustment.topBotDownwardOffset
            )
            
        case .left:
            // 4人・5人対戦：左側Botを中央に寄せる
            if playerCount >= 4 {
                return CGSize(
                    width: baseOffset.width + LayoutConstants.PlayerCountAdjustment.sideBotCenterOffset, 
                    height: baseOffset.height
                )
            }
            return baseOffset
            
        case .right:
            // 4人・5人対戦：右側Botを中央に寄せる
            if playerCount >= 4 {
                return CGSize(
                    width: baseOffset.width - LayoutConstants.PlayerCountAdjustment.sideBotCenterOffset, 
                    height: baseOffset.height
                )
            }
            return baseOffset
            
        case .bottom:
            // プレイヤー自身は調整なし
            return baseOffset
        }
    }
    
    // MARK: - Hand Offset Calculation
    /// 手札の位置オフセットを計算（中心対称配置を保証）
    private var handOffset: CGSize {
        // 下部プレイヤー（自分）の場合は中心対称配置を保証するため、
        // 動的調整を行わず基本オフセットのみを使用
        if position == .bottom {
            return config.globalOffset
        }
        
        // 他のプレイヤーは人数に応じた動的調整を適用
        return adjustedGlobalOffset
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
    
    /// スコアをカンマ区切りでフォーマット
    private func formatScore(_ score: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: score)) ?? "\(score)"
    }
    
    var body: some View {
        ZStack {
            // スポットライト効果（最背面）- 自分以外のプレイヤーのみ表示
            if position != .bottom {
                WaterRippleSpotlightView(
                    isActive: viewModel.isPlayerTurn(playerId: player.id),
                    size: spotlightSize
                )
                .offset(config.icon.offset) // アイコンと同じ位置に配置
                .zIndex(-1) // 最背面に配置
            }
            
            // 手札を配置（アイコンの後ろに来るようにzIndex調整）
            HandCardsView(
                player: player,
                position: position,
                config: config.hand,
                viewModel: viewModel,
                namespace: namespace
            )
            // ⭐ 手札全体の位置調整ポイント
            // config.hand.globalOffset で手札の位置を調整
            // GameLayoutConfig.swift の PlayerLayoutConfig で設定値を変更可能
            .offset(config.hand.globalOffset) // ← 手札の位置調整
            .zIndex(position == .bottom ? 1 : 0)
            
            // プレイヤーアイコンとUI要素
            VStack(spacing: PlayerIconConstants.Spacing.nameVertical) {
                PlayerIconContainer(player: player, position: position, config: config.icon, viewModel: viewModel)
                
                if position != .bottom {
                    PlayerNameView(playerName: player.name, config: config.icon)
                }
                
                PlayerScoreView(
                    score: formatScore(player.score),
                    isMainPlayer: position == .bottom
                )
            }
            // ⭐ プレイヤーアイコン全体の位置調整ポイント
            // config.icon.offset でアイコン全体の位置を調整
            // GameLayoutConfig.swift の PlayerLayoutConfig で設定値を変更可能
            .offset(config.icon.offset) // ← アイコン全体の位置調整
            .zIndex(position == .bottom ? 2 : 1)
        }
    }
    
    /// スポットライトのサイズを計算
    private var spotlightSize: CGFloat {
        let baseSize = config.icon.size
        
        switch position {
        case .bottom:
            // プレイヤー自身：スポットライト非表示のため0
            return 0
        case .top, .left, .right:
            // Bot：適度なサイズのスポットライト
            return baseSize * 3.2
        }
    }
}

