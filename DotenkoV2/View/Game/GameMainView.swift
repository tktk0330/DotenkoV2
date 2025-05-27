import SwiftUI
import Combine

// MARK: - Layout Configuration
/// ゲーム画面のレイアウト設定
struct GameLayoutConfig {
    // MARK: - Screen Area Ratios (画面エリアの比率)
    /// 上部エリアの高さ比率（相手プレイヤー配置エリア）
    static let topAreaHeightRatio: CGFloat = 0.2
    /// 中央エリアの高さ比率（ゲームフィールド）
    static let centerAreaHeightRatio: CGFloat = 0.6
    /// 下部エリアの高さ比率（自分のプレイヤー配置エリア）
    static let bottomAreaHeightRatio: CGFloat = 0.2
    
    // MARK: - Player Icon Positioning (プレイヤーアイコンの位置調整)
    /// 上部プレイヤーの左右パディング
    static let topPlayersHorizontalPadding: CGFloat = 40
    /// 上部プレイヤーの上パディング（もっと上に配置）
    static let topPlayersTopPadding: CGFloat = 20
    
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
    static let backButtonTopPadding: CGFloat = 20
}

struct GameMainView: View {
    let players: [Player]
    let maxPlayers: Int
    let gameType: GameType
    
    @EnvironmentObject private var allViewNavigator: NavigationAllViewStateManager
    
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
    }
    
    // MARK: - Main Layout Components
    
    /// メインゲーム画面のレイアウト
    private func gameMainLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
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
    
    var body: some View {
        VStack(spacing: 8) {
            // プレイヤーアイコン
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
            
            // プレイヤー名
            Text(player.name)
                .font(.system(size: nameTextSize, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(maxWidth: iconSize + 20)
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
}

// MARK: - Player Position Enum
enum PlayerPosition {
    case top
    case bottom
    case left
    case right
}
