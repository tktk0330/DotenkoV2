import SwiftUI
import Combine

// MARK: - Layout Configuration
/// ゲーム画面のレイアウト設定
struct GameLayoutConfig {
    // MARK: - Screen Area Ratios (画面エリアの比率)
    /// ヘッダーエリアの高さ比率（ゲーム情報表示エリア）
    static let headerAreaHeightRatio: CGFloat = 0.1
    /// 上部エリアの高さ比率（相手プレイヤー配置エリア）
    static let topAreaHeightRatio: CGFloat = 0.18
    /// 中央エリアの高さ比率（ゲームフィールド）
    static let centerAreaHeightRatio: CGFloat = 0.54
    /// 下部エリアの高さ比率（自分のプレイヤー配置エリア）
    static let bottomAreaHeightRatio: CGFloat = 0.18
    
    // MARK: - Header Area (ヘッダーエリア設定)
    /// ヘッダーエリアの左右パディング
    static let headerHorizontalPadding: CGFloat = 20
    /// ヘッダーエリアの上下パディング
    static let headerVerticalPadding: CGFloat = 10
    /// ヘッダー内要素間のスペース
    static let headerItemSpacing: CGFloat = 10
    
    // MARK: - Player Icon Positioning (プレイヤーアイコンの位置調整)
    /// 上部プレイヤーの左右パディング
    static let topPlayersHorizontalPadding: CGFloat = 40
    /// 上部プレイヤーの上パディング（もっと上に配置）
    static let topPlayersTopPadding: CGFloat = 10
    
    /// 左右サイドプレイヤーエリアの幅（幅を狭める）
    static let sidePlayersAreaWidth: CGFloat = 60
    /// 中央ゲームエリアの左右パディング（中央プレイヤーを上部プレイヤーに近づける）
    static let centerAreaHorizontalPadding: CGFloat = 30
    
    /// 下部プレイヤーの下パディング（広告エリアからの距離）
    static let bottomPlayerBottomPadding: CGFloat = 20
    
    // MARK: - Game Field (ゲームフィールド設定)
    /// 中央カード配置エリアの幅
    static let gameFieldWidth: CGFloat = 200
    /// 中央カード配置エリアの高さ
    static let gameFieldHeight: CGFloat = 120
    
    // MARK: - Back Button (戻るボタン設定)
    /// 戻るボタンの左パディング
    static let backButtonLeadingPadding: CGFloat = 20
    /// 戻るボタンの上パディング
    static let backButtonTopPadding: CGFloat = 50
}

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
                
                // UI オーバーレイ（戻るボタンなど）
                uiOverlay
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
            Text("ゲームエリア")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
            
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
                PlayerIconView(player: player, position: .bottom)
                    .padding(.bottom, CGFloat(Constant.BANNER_HEIGHT) + GameLayoutConfig.bottomPlayerBottomPadding)
            }
        }
        .frame(height: geometry.size.height * GameLayoutConfig.bottomAreaHeightRatio)
    }
}

// MARK: - Player Position Manager
/// プレイヤー位置管理クラス
struct PlayerPositionManager {
    
    /// 現在のプレイヤー（自分）を取得
    static func getCurrentPlayer(from players: [Player]) -> Player? {
        return players.first { !$0.id.hasPrefix("bot-") }
    }
    
    /// 上部に配置するプレイヤーを取得
    static func getTopPlayers(from players: [Player], maxPlayers: Int) -> [Player] {
        let botPlayers = players.filter { $0.id.hasPrefix("bot-") }
        
        switch maxPlayers {
        case 2:
            return Array(botPlayers.prefix(1)) // 2人戦：上に1人
        case 3:
            return Array(botPlayers.prefix(2)) // 3人戦：上に2人
        case 4:
            return Array(botPlayers.prefix(1)) // 4人戦：上に1人
        case 5:
            return Array(botPlayers.prefix(2)) // 5人戦：上に2人
        default:
            return Array(botPlayers.prefix(1))
        }
    }
    
    /// 左側に配置するプレイヤーを取得
    static func getSidePlayersLeft(from players: [Player], maxPlayers: Int) -> [Player] {
        let botPlayers = players.filter { $0.id.hasPrefix("bot-") }
        
        switch maxPlayers {
        case 4:
            return Array(botPlayers.dropFirst(1).prefix(1)) // 4人戦：左に1人
        case 5:
            return Array(botPlayers.dropFirst(2).prefix(1)) // 5人戦：左に1人
        default:
            return []
        }
    }
    
    /// 右側に配置するプレイヤーを取得
    static func getSidePlayersRight(from players: [Player], maxPlayers: Int) -> [Player] {
        let botPlayers = players.filter { $0.id.hasPrefix("bot-") }
        
        switch maxPlayers {
        case 4:
            return Array(botPlayers.dropFirst(2).prefix(1)) // 4人戦：右に1人
        case 5:
            return Array(botPlayers.dropFirst(3).prefix(1)) // 5人戦：右に1人
        default:
            return []
        }
    }
}

// MARK: - Player Icon View
struct PlayerIconView: View {
    let player: Player
    let position: PlayerPosition
    @StateObject private var imageLoader = ImageLoader()
    
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
    
    var body: some View {
        ZStack {
            // 手札表示（下に配置）
            handCardsView
                .offset(handOffset)
            
            // プレイヤーアイコン（上に配置）
            VStack(spacing: 8) {
                playerIcon
                
                // プレイヤー名
                Text(player.name)
                    .font(.system(size: nameTextSize, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(maxWidth: iconSize + 20)
            }
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
        .frame(width: iconSize, height: iconSize)
        .background(Color.black.opacity(0.3))
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white, lineWidth: 2)
        )
    }
    
    private var handCardsView: some View {
        ZStack {
            ForEach(Array(testCards.enumerated()), id: \.element.id) { index, card in
                CardView(card: card, size: cardSize)
                    .rotationEffect(.degrees(cardRotation(for: index)))
                    .offset(cardOffset(for: index))
            }
        }
        .frame(width: handAreaWidth, height: handAreaHeight)
    }
    
    // カードの回転角度を計算
    private func cardRotation(for index: Int) -> Double {
        let totalCards = testCards.count
        let maxAngle: Double = 60 // 最大扇角度
        let angleStep = maxAngle / Double(max(totalCards - 1, 1))
        let startAngle = -maxAngle / 2
        let baseRotation = startAngle + (Double(index) * angleStep)
        
        // 位置に応じて基本回転を調整
        switch position {
        case .bottom:
            return baseRotation // 下部は上向きの扇（回転なし）
        case .top:
            return -baseRotation // 上部は下向きの扇（逆回転）
        case .left:
            return baseRotation + 90 // 左側は右向きの扇（90度回転）
        case .right:
            return baseRotation - 90 // 右側は左向きの扇（-90度回転）
        }
    }
    
    // カードのオフセット位置を計算
    private func cardOffset(for index: Int) -> CGSize {
        let totalCards = testCards.count
        let radius: CGFloat = fanRadius // 扇の半径
        let maxAngle: Double = 60 // 最大扇角度
        let angleStep = maxAngle / Double(max(totalCards - 1, 1))
        let startAngle = -maxAngle / 2
        let currentAngle = startAngle + (Double(index) * angleStep)
        
        let radians = currentAngle * .pi / 180
        let x = radius * sin(radians)
        let y = radius * cos(radians)
        
        // 位置に応じてオフセットを調整
        switch position {
        case .bottom:
            return CGSize(width: x, height: -y) // 下部は上向きの扇
        case .top:
            return CGSize(width: x, height: y) // 上部は下向きの扇（元に戻す）
        case .left:
            return CGSize(width: -y, height: x) // 左側は内側向きの扇
        case .right:
            return CGSize(width: y, height: -x) // 右側は内側向きの扇（修正）
        }
    }
    
    // 扇の半径（位置とカードサイズに応じて調整）
    private var fanRadius: CGFloat {
        switch position {
        case .bottom:
            return 60 // 自分の手札は大きな扇
        case .top, .left, .right:
            return 50 // 相手の手札は中サイズの扇
        }
    }
    
    private var iconSize: CGFloat {
        switch position {
        case .bottom:
            return 60 // 自分は少し大きく
        case .top, .left, .right:
            return 50 // 相手は標準サイズ
        }
    }
    
    private var nameTextSize: CGFloat {
        switch position {
        case .bottom:
            return 14
        case .top, .left, .right:
            return 12
        }
    }
    
    private var cardSize: CGFloat {
        switch position {
        case .bottom:
            return 80 // 自分の手札は大きく（40pt × 2）
        case .top, .left, .right:
            return 60 // 相手の手札は中サイズ（30pt × 2）
        }
    }
    
    private var handAreaWidth: CGFloat {
        switch position {
        case .bottom, .top:
            return 120
        case .left, .right:
            return 80
        }
    }
    
    private var handAreaHeight: CGFloat {
        switch position {
        case .bottom, .top:
            return 80
        case .left, .right:
            return 120
        }
    }
    
    // 手札の位置オフセット
    private var handOffset: CGSize {
        switch position {
        case .bottom:
            return CGSize(width: 0, height: 30) // 自分の手札は下に
        case .top:
            return CGSize(width: 0, height: -30) // 相手の手札は上に
        case .left:
            return CGSize(width: -30, height: 0) // 左側の手札は左に
        case .right:
            return CGSize(width: 30, height: 0) // 右側の手札は右に
        }
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

// MARK: - Game Info Manager
/// ゲーム情報管理クラス
class GameInfoManager: ObservableObject {
    // MARK: - Published Properties
    @Published var currentRound: Int = 1
    @Published var totalRounds: Int = 10
    @Published var currentRate: Int = 10
    @Published var upRate: Int = 3
    @Published var currentPot: Int = 0
    @Published var gamePhase: GamePhase = .waiting
    
    // MARK: - Private Properties
    private let userProfileRepository = UserProfileRepository.shared
    
    // MARK: - Initialization
    func initializeGameInfo(maxPlayers: Int, gameType: GameType) {
        // ユーザー設定からゲーム情報を取得
        if case .success(let profile) = userProfileRepository.getOrCreateProfile() {
            totalRounds = Int(profile.rmRoundCount) ?? 10
            currentRate = Int(profile.rmGameRate) ?? 10
            upRate = Int(profile.rmUpRate) ?? 3
        }
        
        // 初期ポット計算（プレイヤー数 × 基本レート）
        currentPot = maxPlayers * currentRate
        
        // ゲーム開始
        gamePhase = .playing
    }
    
    // MARK: - Game Control Methods
    
    /// 次のラウンドに進む
    func nextRound() {
        if currentRound < totalRounds {
            currentRound += 1
            resetRoundInfo()
        } else {
            gamePhase = .finished
        }
    }
    
    /// レートを更新
    func updateRate(_ newRate: Int) {
        currentRate = newRate
    }
    
    /// アップレートを更新
    func updateUpRate(_ newUpRate: Int) {
        upRate = newUpRate
    }
    
    /// ポットを更新
    func updatePot(_ newPot: Int) {
        currentPot = newPot
    }
    
    /// ラウンド情報をリセット
    private func resetRoundInfo() {
        // 新しいラウンドの初期設定
        // 必要に応じてレートやポットをリセット
    }
}

// MARK: - Game Phase Enum
/// ゲームフェーズ
enum GamePhase {
    case waiting    // 待機中
    case playing    // プレイ中
    case finished   // 終了
}
