import SwiftUI

// MARK: - Game Layout Configuration
/// ゲーム画面全体のレイアウト設定
struct GameLayoutConfig {
    // MARK: - Screen Area Ratios (画面エリアの比率)
    /// ヘッダーエリアの高さ比率（ゲーム情報表示エリア）
    static let headerAreaHeightRatio: CGFloat = 0.1
    /// 上部エリアの高さ比率（相手プレイヤー配置エリア）
    static let topAreaHeightRatio: CGFloat = 0.18
    /// 中央エリアの高さ比率（ゲームフィールド）
    static let centerAreaHeightRatio: CGFloat = 0.47
    /// 下部エリアの高さ比率（自分のプレイヤー配置エリア）
    static let bottomAreaHeightRatio: CGFloat = 0.25
    
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
    /// 上部プレイヤーの上パディング
    static let topPlayersTopPadding: CGFloat = 10
    
    /// 左右サイドプレイヤーエリアの幅
    static let sidePlayersAreaWidth: CGFloat = 60
    /// 中央ゲームエリアの左右パディング
    static let centerAreaHorizontalPadding: CGFloat = 30
    
    /// 下部プレイヤーの下パディング（広告エリアからの距離）
    static let bottomPlayerBottomPadding: CGFloat = 10
    
    // MARK: - Game Field (ゲームフィールド設定)
    /// 中央カード配置エリアの幅
    static let gameFieldWidth: CGFloat = 200
    /// 中央カード配置エリアの高さ
    static let gameFieldHeight: CGFloat = 150
    
    // MARK: - Back Button (戻るボタン設定)
    /// 戻るボタンの左パディング
    static let backButtonLeadingPadding: CGFloat = 20
    /// 戻るボタンの上パディング
    static let backButtonTopPadding: CGFloat = 50
    
    // MARK: - Deck Position (デッキ位置設定)
    /// デッキのX位置比率
    static let deckPositionXRatio: CGFloat = 0.1
    /// デッキのY位置比率
    static let deckPositionYRatio: CGFloat = 0.65
}

// MARK: - Player Layout Configuration
/// プレイヤーアイコンと手札の配置設定
struct PlayerLayoutConfig {
    // MARK: - Icon Position Configuration
    struct IconPosition {
        /// アイコンのオフセット位置
        let offset: CGSize
        /// アイコンのサイズ
        let size: CGFloat
        /// 名前テキストのサイズ
        let nameTextSize: CGFloat
        
        init(offset: CGSize = .zero, size: CGFloat = 50, nameTextSize: CGFloat = 12) {
            self.offset = offset
            self.size = size
            self.nameTextSize = nameTextSize
        }
    }
    
    // MARK: - Hand Cards Configuration
    struct HandConfiguration {
        /// 手札全体のオフセット位置
        let globalOffset: CGSize
        /// 手札全体の回転角度（度）
        let globalRotation: Double
        /// 扇形の最大角度（度）
        let fanMaxAngle: Double
        /// 扇形の半径
        let fanRadius: CGFloat
        /// カードサイズ
        let cardSize: CGFloat
        /// 手札エリアのサイズ
        let handAreaSize: CGSize
        
        init(
            globalOffset: CGSize = .zero,
            globalRotation: Double = 0,
            fanMaxAngle: Double = 60,
            fanRadius: CGFloat = 50,
            cardSize: CGFloat = 60,
            handAreaSize: CGSize = CGSize(width: 120, height: 80)
        ) {
            self.globalOffset = globalOffset
            self.globalRotation = globalRotation
            self.fanMaxAngle = fanMaxAngle
            self.fanRadius = fanRadius
            self.cardSize = cardSize
            self.handAreaSize = handAreaSize
        }
    }
    
    // MARK: - Position-specific Configurations
    /// 上部プレイヤーの設定
    static let topPlayer = (
        icon: IconPosition(
            offset: CGSize(width: 0, height: 0),
            size: 45,
            nameTextSize: 11
        ),
        hand: HandConfiguration(
            globalOffset: CGSize(width: 0, height: -30),
            globalRotation: 0,
            fanMaxAngle: 60,
            fanRadius: 45,
            cardSize: 45,
            handAreaSize: CGSize(width: 160, height: 45)
        )
    )
    
    /// 左側プレイヤーの設定
    static let leftPlayer = (
        icon: IconPosition(
            offset: CGSize(width: 0, height: 0),
            size: 45,
            nameTextSize: 11
        ),
        hand: HandConfiguration(
            globalOffset: CGSize(width: -30, height: 0),
            globalRotation: 0,
            fanMaxAngle: 60,
            fanRadius: 35,
            cardSize: 40,
            handAreaSize: CGSize(width: 100, height: 45)
        )
    )
    
    /// 右側プレイヤーの設定
    static let rightPlayer = (
        icon: IconPosition(
            offset: CGSize(width: 0, height: 0),
            size: 45,
            nameTextSize: 11
        ),
        hand: HandConfiguration(
            globalOffset: CGSize(width: 30, height: 0),
            globalRotation: 0,
            fanMaxAngle: 60,
            fanRadius: 35,
            cardSize: 40,
            handAreaSize: CGSize(width: 100, height: 45)
        )
    )
    
    /// 下部プレイヤー（自分）の設定
    static let bottomPlayer = (
        icon: IconPosition(
            offset: CGSize(width: 0, height: 25),
            size: 75,
            nameTextSize: 15
        ),
        hand: HandConfiguration(
            globalOffset: CGSize(width: 0, height: 5),
            globalRotation: 0,
            fanMaxAngle: 90,
            fanRadius: 55,
            cardSize: 70,
            handAreaSize: CGSize(width: 220, height: 85)
        )
    )
    
    /// 位置に応じた設定を取得
    static func configuration(for position: PlayerPosition) -> (icon: IconPosition, hand: HandConfiguration) {
        switch position {
        case .top:
            return topPlayer
        case .left:
            return leftPlayer
        case .right:
            return rightPlayer
        case .bottom:
            return bottomPlayer
        }
    }
} 