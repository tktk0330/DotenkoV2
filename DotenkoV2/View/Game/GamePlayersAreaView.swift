import SwiftUI

// MARK: - Game Players Area View
/// ゲームプレイヤーエリア表示View
struct GamePlayersAreaView: View {
    let players: [Player]
    let maxPlayers: Int
    let onPassAction: () -> Void
    let onPlayAction: () -> Void
    @ObservedObject var viewModel: GameViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 上部プレイヤーエリア
                TopPlayersAreaView(players: viewModel.getTopPlayers(), geometry: geometry, viewModel: viewModel, namespace: namespace)
                
                // 中央エリア（左右プレイヤー + ゲームフィールド）
                CenterGameAreaView(
                    leftPlayers: viewModel.getLeftPlayers(),
                    rightPlayers: viewModel.getRightPlayers(),
                    geometry: geometry,
                    viewModel: viewModel,
                    namespace: namespace
                )
                
                // 下部プレイヤーエリア（自分）
                BottomPlayerAreaView(
                    player: viewModel.getCurrentPlayer(),
                    onPassAction: onPassAction,
                    onPlayAction: onPlayAction,
                    geometry: geometry,
                    viewModel: viewModel,
                    namespace: namespace
                )
            }
            
            // チャレンジゾーン参加モーダル
            if viewModel.showChallengeParticipationModal {
                ChallengeZoneParticipationModal(
                    players: viewModel.players,
                    revengeEligiblePlayers: viewModel.revengeEligiblePlayers,
                    dotenkoWinnerId: viewModel.dotenkoWinnerId,
                    fieldCardValue: viewModel.fieldCards.last?.card.handValue().first ?? 0,
                    calculateHandTotals: { cards in
                        viewModel.calculateHandTotals(cards: cards)
                    },
                    onPlayerChoice: { playerId, choice in
                        viewModel.handlePlayerParticipationChoice(playerId: playerId, choice: choice)
                    },
                    onTimeout: {
                        viewModel.handleParticipationModalTimeout()
                    }
                )
                .zIndex(3000)
            }
            

        }
    }
}

// MARK: - Top Players Area View
/// 上部プレイヤーエリア表示View
struct TopPlayersAreaView: View {
    let players: [Player]
    let geometry: GeometryProxy
    @ObservedObject var viewModel: GameViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        VStack {
            if !players.isEmpty {
                HStack {
                    ForEach(Array(players.enumerated()), id: \.offset) { index, player in
                        PlayerIconView(player: player, position: .top, viewModel: viewModel, namespace: namespace)
                        if index < players.count - 1 {
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, GameLayoutConfig.topPlayersHorizontalPadding)
                .padding(.top, GameLayoutConfig.topPlayersTopPadding)
            }
        }
        .frame(height: geometry.size.height * GameLayoutConfig.topAreaHeightRatio)
    }
}

// MARK: - Center Game Area View
/// 中央ゲームエリア表示View
struct CenterGameAreaView: View {
    let leftPlayers: [Player]
    let rightPlayers: [Player]
    let geometry: GeometryProxy
    @ObservedObject var viewModel: GameViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        HStack {
            // 左側プレイヤーエリア
            LeftSidePlayersAreaView(players: leftPlayers, viewModel: viewModel, namespace: namespace)
            
            Spacer()
            
            // 中央ゲームフィールド
            GameFieldView(viewModel: viewModel, namespace: namespace)
            
            Spacer()
            
            // 右側プレイヤーエリア
            RightSidePlayersAreaView(players: rightPlayers, viewModel: viewModel, namespace: namespace)
        }
        .frame(height: geometry.size.height * GameLayoutConfig.centerAreaHeightRatio)
        .padding(.horizontal, GameLayoutConfig.centerAreaHorizontalPadding)
    }
}

// MARK: - Left Side Players Area View
/// 左側プレイヤーエリア表示View
struct LeftSidePlayersAreaView: View {
    let players: [Player]
    @ObservedObject var viewModel: GameViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            // 上部に寄せるためのSpacer
            Spacer().frame(height: 20)
            
            ForEach(players, id: \.id) { player in
                PlayerIconView(player: player, position: .left, viewModel: viewModel, namespace: namespace)
                if players.count > 1 {
                    Spacer().frame(height: 20)
                }
            }
            
            // 下部の余白
            Spacer()
        }
        .frame(width: GameLayoutConfig.sidePlayersAreaWidth)
    }
}

// MARK: - Right Side Players Area View
/// 右側プレイヤーエリア表示View
struct RightSidePlayersAreaView: View {
    let players: [Player]
    @ObservedObject var viewModel: GameViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            // 上部に寄せるためのSpacer
            Spacer().frame(height: 20)
            
            ForEach(players, id: \.id) { player in
                PlayerIconView(player: player, position: .right, viewModel: viewModel, namespace: namespace)
                if players.count > 1 {
                    Spacer().frame(height: 20)
                }
            }
            
            // 下部の余白
            Spacer()
        }
        .frame(width: GameLayoutConfig.sidePlayersAreaWidth)
    }
}

// MARK: - Game Field View
/// 中央ゲームフィールド表示View
struct GameFieldView: View {
    @ObservedObject var viewModel: GameViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        ZStack {
            // バックグラウンド（カード配置エリア）
            Rectangle()
                .fill(Appearance.Color.commonBlack.opacity(0.3))
                .frame(
                    width: GameLayoutConfig.gameFieldWidth,
                    height: GameLayoutConfig.gameFieldHeight
                )
                .cornerRadius(12)
                .overlay(
                    Text(viewModel.fieldCards.isEmpty ? "カード配置エリア" : "")
                        .foregroundColor(Appearance.Color.commonWhite)
                        .font(.caption)
                )
            
            // 実際のフィールドカード表示（乱雑配置）
            ForEach(Array(viewModel.fieldCards.enumerated()), id: \.element.id) { index, card in
                CardView(card: card, size: 100)
                    .matchedGeometryEffect(id: card.id, in: namespace)
                    .rotationEffect(.degrees(card.handRotation)) // 手札の角度を保持
                    .zIndex(Double(index)) // 重なり順を設定
            }
        }
    }
    
    // フィールドカードの乱雑な配置用オフセットを計算
    private func calculateFieldCardOffset(for index: Int) -> CGSize {
        // 各カードに対して一意で再現可能なランダムオフセットを生成
        let seed = index + 1
        let random = seededRandom(seed: seed)
        
        // カードの重なりを作るための基本オフセット
        let baseX = CGFloat(index) * LayoutConstants.FieldCard.baseStackOffsetX
        let baseY = CGFloat(index) * LayoutConstants.FieldCard.baseStackOffsetY
        
        // 乱雑さを加えるランダムオフセット
        let randomX = CGFloat(random() * Double(LayoutConstants.FieldCard.randomOffsetRangeX) - Double(LayoutConstants.FieldCard.randomOffsetRangeX / 2))
        let randomY = CGFloat(random() * Double(LayoutConstants.FieldCard.randomOffsetRangeY) - Double(LayoutConstants.FieldCard.randomOffsetRangeY / 2))
        
        return CGSize(
            width: baseX + randomX,
            height: baseY + randomY
        )
    }
    
    // シード値に基づく再現可能な疑似乱数生成器
    private func seededRandom(seed: Int) -> () -> Double {
        var rng = seed
        return {
            rng = (rng &* 16807) % 2147483647
            return Double(rng) / 2147483647.0
        }
    }
}

// MARK: - Bottom Player Area View
/// 下部プレイヤーエリア表示View
struct BottomPlayerAreaView: View {
    let player: Player?
    let onPassAction: () -> Void
    let onPlayAction: () -> Void
    let geometry: GeometryProxy
    @ObservedObject var viewModel: GameViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // フレーム全体を使用
            Rectangle()
                .fill(Appearance.Color.commonClear)
                .frame(height: geometry.size.height * GameLayoutConfig.bottomAreaHeightRatio)
            
            if let player = player {
                HStack(spacing: -20) {
                    // 左側：引く/パスボタン
                    GameActionButton(
                        icon: hasDrawnCard ? Appearance.Icon.arrowDownCircleFill : "plus.rectangle.on.rectangle",
                        label: hasDrawnCard ? "パス" : "引く",
                        action: onPassAction,
                        backgroundColor: hasDrawnCard ? Appearance.Color.passButtonBackground : Appearance.Color.drawButtonBackground,
                        size: 75,
                        isEnabled: canPlayerPerformActions
                    )
                    .offset(x: 20, y: 70)
                    
                    // 中央：プレイヤーアイコン
                    VStack(spacing: 10) {
                        // プレイヤーアイコン
                        PlayerIconView(player: player, position: .bottom, viewModel: viewModel, namespace: namespace)
                            .scaleEffect(1.0)
                    }
                    
                    // 右側：出すボタン
                    GameActionButton(
                        icon: Appearance.Icon.arrowUpCircleFill,
                        label: "出す",
                        action: onPlayAction,
                        backgroundColor: Appearance.Color.playButtonBackground,
                        size: 75,
                        isEnabled: canPlayCards
                    )
                    .offset(x: -20, y: 70)
                }
                .zIndex(1001)
                .offset(y: -CGFloat(Constant.BANNER_HEIGHT) - GameLayoutConfig.bottomPlayerBottomPadding)
            }
        }
        .overlay(
            // どてんこ宣言ボタン（完全独立オーバーレイ）
            dotenkoButtonOverlay,
            alignment: .bottomTrailing
        )
        .overlay(
            // しょてんこ宣言ボタン（完全独立オーバーレイ）
            shotenkoButtonOverlay,
            alignment: .bottomTrailing
        )
        .overlay(
            // リベンジ宣言ボタン（完全独立オーバーレイ）
            revengeButtonOverlay,
            alignment: .bottomLeading
        )


        .overlay(
            // バースト表示
            burstOverlay,
            alignment: .center
        )

    }
    
    // MARK: - Dotenko Button Overlay
    @ViewBuilder
    private var dotenkoButtonOverlay: some View {
        if let player = player {
            DotenkoDeclarationButton(
                action: { handleDotenkoDeclaration(for: player) },
                isEnabled: viewModel.shouldShowDotenkoButton()
            )
            .padding(.trailing, 20)
            .padding(.bottom, 120)
            .zIndex(2001)
        }
    }
    
    // MARK: - Shotenko Button Overlay
    @ViewBuilder
    private var shotenkoButtonOverlay: some View {
        if let player = player {
            ShotenkoDeclarationButton(
                action: { handleShotenkoDeclaration(for: player) },
                isEnabled: viewModel.shouldShowShotenkoButton()
            )
            .padding(.trailing, 20)
            .padding(.bottom, 120)
            .zIndex(2001)
        }
    }
    
    // MARK: - Revenge Button Overlay
    @ViewBuilder
    private var revengeButtonOverlay: some View {
        if let player = player {
            RevengeDeclarationButton(
                action: { handleRevengeDeclaration(for: player) },
                isEnabled: viewModel.shouldShowRevengeButton(for: player.id)
            )
            .padding(.leading, 20)
            .padding(.bottom, 120)
            .zIndex(2001)
        }
    }
    

    

    
    // MARK: - Burst Overlay
    @ViewBuilder
    private var burstOverlay: some View {
        if viewModel.isBurst {
            VStack(spacing: 10) {
                Text("バースト！")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Appearance.Color.commonWhite)
                    .shadow(color: Appearance.Color.commonBlack, radius: 2, x: 0, y: 1)
                
                Text("プレイヤーがバーストしました")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Appearance.Color.commonWhite.opacity(0.8))
                    .shadow(color: Appearance.Color.commonBlack, radius: 1, x: 0, y: 1)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Appearance.Color.commonBlack.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red, lineWidth: 2)
                    )
            )
            .zIndex(1500)
        }
    }
    

    
    // MARK: - Computed Properties
    
    /// プレイヤーがアクションを実行できるかチェック
    private var canPlayerPerformActions: Bool {
        guard let player = player else { return false }
        return viewModel.canPlayerPerformAction(playerId: player.id)
    }
    
    /// プレイヤーがこのターンでカードを引いたかチェック
    private var hasDrawnCard: Bool {
        guard let player = player else { return false }
        return viewModel.hasPlayerDrawnCardThisTurn(playerId: player.id)
    }
    
    /// カードを出せるかチェック
    private var canPlayCards: Bool {
        guard let player = player else { return false }
        
        // アクション実行権限がない場合は無効
        if !canPlayerPerformActions {
            return false
        }
        
        // カードが選択されていない場合は無効
        if player.selectedCards.isEmpty {
            return false
        }
        
        // カード出し判定
        let validation = viewModel.canPlaySelectedCards(playerId: player.id)
        return validation.canPlay
    }
    
    /// どてんこ宣言処理
    private func handleDotenkoDeclaration(for player: Player) {
        print("どてんこ宣言ボタンが押されました - プレイヤー: \(player.name)")
        viewModel.handleDotenkoDeclaration(playerId: player.id)
    }
    
    /// しょてんこ宣言処理
    private func handleShotenkoDeclaration(for player: Player) {
        print("しょてんこ宣言ボタンが押されました - プレイヤー: \(player.name)")
        viewModel.handlePlayerShotenkoDeclaration(playerId: player.id)
    }
    
    /// リベンジ宣言処理
    private func handleRevengeDeclaration(for player: Player) {
        print("リベンジ宣言ボタンが押されました - プレイヤー: \(player.name)")
        viewModel.handleRevengeDeclaration(playerId: player.id)
    }
} 
