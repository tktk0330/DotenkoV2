import SwiftUI

// MARK: - Game Players Area View
/// ゲームプレイヤーエリア表示View
struct GamePlayersAreaView: View {
    let topPlayers: [Player]
    let leftPlayers: [Player]
    let rightPlayers: [Player]
    let currentPlayer: Player?
    let onPassAction: () -> Void
    let onPlayAction: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 上部プレイヤーエリア
                TopPlayersAreaView(players: topPlayers, geometry: geometry)
                
                // 中央エリア（左右プレイヤー + ゲームフィールド）
                CenterGameAreaView(
                    leftPlayers: leftPlayers,
                    rightPlayers: rightPlayers,
                    geometry: geometry
                )
                
                // 下部プレイヤーエリア（自分）
                BottomPlayerAreaView(
                    player: currentPlayer,
                    onPassAction: onPassAction,
                    onPlayAction: onPlayAction,
                    geometry: geometry
                )
            }
        }
    }
}

// MARK: - Top Players Area View
/// 上部プレイヤーエリア表示View
struct TopPlayersAreaView: View {
    let players: [Player]
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            if !players.isEmpty {
                HStack {
                    ForEach(Array(players.enumerated()), id: \.offset) { index, player in
                        PlayerIconView(player: player, position: .top)
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
    
    var body: some View {
        HStack {
            // 左側プレイヤーエリア
            LeftSidePlayersAreaView(players: leftPlayers)
            
            Spacer()
            
            // 中央ゲームフィールド
            GameFieldView()
            
            Spacer()
            
            // 右側プレイヤーエリア
            RightSidePlayersAreaView(players: rightPlayers)
        }
        .frame(height: geometry.size.height * GameLayoutConfig.centerAreaHeightRatio)
        .padding(.horizontal, GameLayoutConfig.centerAreaHorizontalPadding)
    }
}

// MARK: - Left Side Players Area View
/// 左側プレイヤーエリア表示View
struct LeftSidePlayersAreaView: View {
    let players: [Player]
    
    var body: some View {
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
}

// MARK: - Right Side Players Area View
/// 右側プレイヤーエリア表示View
struct RightSidePlayersAreaView: View {
    let players: [Player]
    
    var body: some View {
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
}

// MARK: - Game Field View
/// 中央ゲームフィールド表示View
struct GameFieldView: View {
    var body: some View {
        VStack {
            // カード配置エリア（後で実際のゲーム要素に置き換え）
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .frame(
                    width: GameLayoutConfig.gameFieldWidth,
                    height: GameLayoutConfig.gameFieldHeight
                )
                .cornerRadius(12)
                .overlay(
                    Text("カード配置エリア")
                        .foregroundColor(.white)
                        .font(.caption)
                )
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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // フレーム全体を使用
            Rectangle()
                .fill(Color.clear)
                .frame(height: geometry.size.height * GameLayoutConfig.bottomAreaHeightRatio)
            
            if let player = player {
                HStack(spacing: 15) {
                    // 左側：パス/引くボタン
                    GameActionButton(
                        icon: "arrow.down.circle.fill",
                        label: "パス",
                        action: onPassAction,
                        backgroundColor: Color(red: 0.8, green: 0.2, blue: 0.2),
                        size: 75
                    )
                    .offset(x: 0, y: 50)
                    
                    // 中央：プレイヤーアイコン
                    PlayerIconView(player: player, position: .bottom)
                        .scaleEffect(1.0)
                    
                    // 右側：出すボタン
                    GameActionButton(
                        icon: "arrow.up.circle.fill",
                        label: "出す",
                        action: onPlayAction,
                        backgroundColor: Color(red: 0.2, green: 0.6, blue: 0.2),
                        size: 75
                    )
                    .offset(x: 0, y: 50)
                }
                .zIndex(1001)
                .offset(y: -CGFloat(Constant.BANNER_HEIGHT) - GameLayoutConfig.bottomPlayerBottomPadding)
            }
        }
    }
} 
