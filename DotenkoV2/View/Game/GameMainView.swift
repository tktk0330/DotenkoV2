import SwiftUI
import Combine

struct GameMainView: View {
    let players: [Player]
    let maxPlayers: Int
    let gameType: GameType
    
    @EnvironmentObject private var allViewNavigator: NavigationAllViewStateManager
    @StateObject private var gameInfo = GameInfoManager()
    
    init(players: [Player] = [], maxPlayers: Int = 5, gameType: GameType = .vsBot) {
        self.players = players
        self.maxPlayers = maxPlayers
        self.gameType = gameType
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // メインゲーム画面レイアウト
                gameMainLayout(geometry: geometry)
                
                // Deck(座標を直接指定)
                DeckView()
                    .position(x: geometry.size.width * 0.0, y: geometry.size.height * 0.65)
                
                // UI オーバーレイ（戻るボタンなど）
                uiOverlay
                
                // 設定ボタン
                settingsButton
                    .position(x: geometry.size.width * 0.05, y: geometry.size.height * 0.85)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
            gameInfo.initializeGameInfo(maxPlayers: maxPlayers, gameType: gameType)
        }
    }
    
    // MARK: - Main Layout Components
    
    /// メインゲーム画面のレイアウト
    private func gameMainLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // ヘッダーエリア（ゲーム情報表示）
            headerArea(geometry: geometry)
            
            // 上部エリア（相手プレイヤー配置）
            topPlayersArea(geometry: geometry)
            
            // 中央エリア（ゲームフィールド）
            centerGameArea(geometry: geometry)
            
            // 下部エリア（自分のプレイヤー配置）
            bottomPlayerArea(geometry: geometry)
        }
    }
    
    /// UIオーバーレイ（戻るボタンなど）
    private var uiOverlay: some View {
        VStack {
            HStack {
                backButton
                Spacer()
            }
            Spacer()
        }
    }
    
    /// 戻るボタン
    private var backButton: some View {
        Button(action: { allViewNavigator.pop() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.3))
                .clipShape(Circle())
        }
        .padding(.leading, GameLayoutConfig.backButtonLeadingPadding)
        .padding(.top, GameLayoutConfig.backButtonTopPadding)
    }
    
    /// 設定ボタン
    private var settingsButton: some View {
        Button(action: { print("Press") }) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(12)
                .background(Color.black.opacity(0.3))
                .clipShape(Circle())
        }
    }
    
    // MARK: - Player Areas (プレイヤー配置エリア)
    
    /// ヘッダーエリア（ゲーム情報表示）
    private func headerArea(geometry: GeometryProxy) -> some View {
        HStack(spacing: GameLayoutConfig.headerItemSpacing) {
            // 左側：ラウンド情報
            casinoInfoCard(
                icon: "chart.bar.fill",
                label: "ROUND",
                value: "\(gameInfo.currentRound)/\(gameInfo.totalRounds)",
                valueColor: .white,
                accentColor: Color(red: 1.0, green: 0.84, blue: 0.0), // ゴールド
                fixedWidth: 100
            )
            
            Spacer()
            
            // 中央：UP（メイン表示）
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                    
                    Text("UP")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(1.5)
                }
                
                Text("×\(gameInfo.upRate)")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0), radius: 3, x: 0, y: 0)
                    .overlay(
                        Text("×\(gameInfo.upRate)")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.3))
                            .blur(radius: 1)
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.1, blue: 0.0),
                                Color(red: 0.4, green: 0.2, blue: 0.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.84, blue: 0.0),
                                        Color(red: 0.8, green: 0.6, blue: 0.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.3), radius: 8, x: 0, y: 4)
            )
            
            Spacer()
            
            // 右側：レート
            casinoInfoCard(
                icon: "multiply.circle.fill",
                label: "RATE",
                value: "×\(gameInfo.currentRate)",
                valueColor: Color(red: 0.0, green: 0.8, blue: 0.4), // エメラルドグリーン
                accentColor: Color(red: 0.0, green: 0.8, blue: 0.4),
                fixedWidth: 100
            )
        }
        .padding(.horizontal, GameLayoutConfig.headerHorizontalPadding)
        .padding(.vertical, GameLayoutConfig.headerVerticalPadding)
        .frame(height: geometry.size.height * GameLayoutConfig.headerAreaHeightRatio)
        .background(
            // カジノ風グラデーション背景
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.05, green: 0.15, blue: 0.05), location: 0.0),
                    .init(color: Color(red: 0.1, green: 0.25, blue: 0.1), location: 0.5),
                    .init(color: Color(red: 0.05, green: 0.15, blue: 0.05), location: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                // 上部のゴールドライン
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.84, blue: 0.0),
                                    Color(red: 0.8, green: 0.6, blue: 0.0),
                                    Color(red: 1.0, green: 0.84, blue: 0.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 3)
                    Spacer()
                    // 下部のゴールドライン
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.84, blue: 0.0),
                                    Color(red: 0.8, green: 0.6, blue: 0.0),
                                    Color(red: 1.0, green: 0.84, blue: 0.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 2)
                }
            )
            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
        )
    }
    
    /// カジノ風情報カード
    private func casinoInfoCard(
        icon: String,
        label: String,
        value: String,
        valueColor: Color,
        accentColor: Color,
        fixedWidth: CGFloat? = nil
    ) -> some View {
        VStack(alignment: .center, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(accentColor)
                
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(1.0)
            }
            
            Text(value)
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(valueColor)
                .shadow(color: accentColor.opacity(0.5), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(width: fixedWidth)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(accentColor.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        )
    }
    
    /// 上部プレイヤー配置エリア
    private func topPlayersArea(geometry: GeometryProxy) -> some View {
        let topPlayers = PlayerPositionManager.getTopPlayers(from: players, maxPlayers: maxPlayers)
        
        return VStack {
            if !topPlayers.isEmpty {
                HStack {
                    ForEach(Array(topPlayers.enumerated()), id: \.offset) { index, player in
                        PlayerIconView(player: player, position: .top)
                        if index < topPlayers.count - 1 {
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
    
    /// 中央ゲームエリア
    private func centerGameArea(geometry: GeometryProxy) -> some View {
        let sidePlayersLeft = PlayerPositionManager.getSidePlayersLeft(from: players, maxPlayers: maxPlayers)
        let sidePlayersRight = PlayerPositionManager.getSidePlayersRight(from: players, maxPlayers: maxPlayers)
        
        return HStack {
            // 左側プレイヤーエリア
            leftSidePlayersArea(players: sidePlayersLeft)
            
            Spacer()
            
            // 中央ゲームフィールド
            gameField
            
            Spacer()
            
            // 右側プレイヤーエリア
            rightSidePlayersArea(players: sidePlayersRight)
        }
        .frame(height: geometry.size.height * GameLayoutConfig.centerAreaHeightRatio)
        .padding(.horizontal, GameLayoutConfig.centerAreaHorizontalPadding)
    }
    
    /// 左側プレイヤーエリア
    private func leftSidePlayersArea(players: [Player]) -> some View {
        VStack(alignment: .center, spacing: 10) {
            // 上部に寄せるためのSpacer
            Spacer().frame(height: 20)
            
            ForEach(players, id: \.id) { player in
                PlayerIconView(player: player, position: .left)
                if players.count > 1 {
                    Spacer().frame(height: 20)
                }
            }
            
            // 下部の余白
            Spacer()
        }
        .frame(width: GameLayoutConfig.sidePlayersAreaWidth)
    }
    
    /// 右側プレイヤーエリア
    private func rightSidePlayersArea(players: [Player]) -> some View {
        VStack(alignment: .center, spacing: 10) {
            // 上部に寄せるためのSpacer
            Spacer().frame(height: 20)
            
            ForEach(players, id: \.id) { player in
                PlayerIconView(player: player, position: .right)
                if players.count > 1 {
                    Spacer().frame(height: 20)
                }
            }
            
            // 下部の余白
            Spacer()
        }
        .frame(width: GameLayoutConfig.sidePlayersAreaWidth)
    }
    
    /// 中央ゲームフィールド
    private var gameField: some View {
        VStack {
            // カード配置エリア（後で実際のゲーム要素に置き換え）
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .frame(width: GameLayoutConfig.gameFieldWidth, height: GameLayoutConfig.gameFieldHeight)
                .cornerRadius(12)
                .overlay(
                    Text("カード配置エリア")
                        .foregroundColor(.white)
                        .font(.caption)
                )
        }
    }
    
    /// 下部プレイヤー配置エリア（自分）
    private func bottomPlayerArea(geometry: GeometryProxy) -> some View {
        let currentPlayer = PlayerPositionManager.getCurrentPlayer(from: players)
        
        return VStack {
            if let player = currentPlayer {
                HStack(spacing: 15) {
                    // 左側：パス/引くボタン
                    GameActionButton(
                        icon: "arrow.down.circle.fill",
                        label: "パス",
                        action: { handlePassAction() },
                        backgroundColor: Color(red: 0.8, green: 0.2, blue: 0.2),
                        size: 75
                    )
                    
                    // 中央：プレイヤーアイコン
                    PlayerIconView(player: player, position: .bottom)
                        .scaleEffect(1.0) // アイコンの相対サイズ調整
                    
                    // 右側：出すボタン
                    GameActionButton(
                        icon: "arrow.up.circle.fill",
                        label: "出す",
                        action: { handlePlayAction() },
                        backgroundColor: Color(red: 0.2, green: 0.6, blue: 0.2),
                        size: 75
                    )
                }
                .zIndex(1001) // ボタンエリア全体を最前面に
                .padding(.bottom, CGFloat(Constant.BANNER_HEIGHT) + GameLayoutConfig.bottomPlayerBottomPadding)
            }
        }
        .frame(height: geometry.size.height * GameLayoutConfig.bottomAreaHeightRatio)
    }
    
    // MARK: - Game Action Methods
    
    /// パス/引くアクションを処理
    private func handlePassAction() {
        // TODO: パス/引くロジックを実装
        print("パス/引くアクションが実行されました")
    }
    
    /// 出すアクションを処理
    private func handlePlayAction() {
        // TODO: 出すロジックを実装
        print("出すアクションが実行されました")
    }
}

// MARK: - Card View
struct CardView: View {
    let card: Card
    let size: CGFloat
    
    var body: some View {
        ZStack {
//            // カード背景
//            RoundedRectangle(cornerRadius: 4)
//                .fill(Color.white)
//                .frame(width: size, height: size * 1.4)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 4)
//                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
//                )
            
            // カード画像
            if let cardImage = card.card.image() {
                Image(uiImage: cardImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.9, height: size * 1.26)
                    .clipped()
            } else {
                // フォールバック表示
                Text(card.card.rawValue)
                    .font(.system(size: size * 0.2, weight: .bold))
                    .foregroundColor(.black)
            }
        }
//        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
    }
}

// MARK: - Player Position Enum
enum PlayerPosition {
    case top
    case bottom
    case left
    case right
}


// MARK: - Game Phase Enum
/// ゲームフェーズ
enum GamePhase {
    case waiting    // 待機中
    case playing    // プレイ中
    case finished   // 終了
}
