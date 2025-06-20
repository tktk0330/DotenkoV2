import SwiftUI

// MARK: - Layout Constants (レイアウト定数)
/// レイアウトで使用する固定値を定義
struct LayoutConstants {
    
    // MARK: - Screen Area Ratios (画面エリア比率)
    struct ScreenRatio {
        static let header: CGFloat = 0.1
        static let topArea: CGFloat = 0.18
        static let centerArea: CGFloat = 0.47
        static let bottomArea: CGFloat = 0.25
    }
    
    // MARK: - Padding Values (パディング値)
    struct Padding {
        static let headerHorizontal: CGFloat = 20
        static let headerVertical: CGFloat = 10
        static let topPlayersHorizontal: CGFloat = 40
        static let topPlayersTop: CGFloat = 50
        static let centerAreaHorizontal: CGFloat = 30
        static let bottomPlayerBottom: CGFloat = 0
        static let backButtonLeading: CGFloat = 20
        static let backButtonTop: CGFloat = 50
    }
    
    // MARK: - Spacing Values (スペース値)
    struct Spacing {
        static let headerItems: CGFloat = 10
    }
    
    // MARK: - Size Values (サイズ値)
    struct Size {
        static let sidePlayersAreaWidth: CGFloat = 60
        static let gameFieldWidth: CGFloat = 200
        static let gameFieldHeight: CGFloat = 150
    }
    
    // MARK: - Position Ratios (位置比率)
    struct Position {
        static let deckXRatio: CGFloat = 0.1
        static let deckYRatio: CGFloat = 0.60
    }
    
    // MARK: - Field Card Layout (フィールドカード配置)
    struct FieldCard {
        static let baseStackOffsetX: CGFloat = 25      // カードの基本重なり幅
        static let baseStackOffsetY: CGFloat = 5       // カードの基本縦重なり
        static let randomOffsetRangeX: CGFloat = 40    // X方向のランダムオフセット範囲
        static let randomOffsetRangeY: CGFloat = 30    // Y方向のランダムオフセット範囲
        static let additionalRotationRange: CGFloat = 15 // 手札角度への追加回転範囲
    }
    
    // MARK: - Player Count Based Adjustment (人数別位置調整)
    struct PlayerCountAdjustment {
        // 全人数：上部Botの下方向調整
        static let topBotDownwardOffset: CGFloat = 50
        
        // 4〜5人対戦：左右Botの中央寄せ調整
        static let sideBotCenterOffset: CGFloat = 50
    }
    
    // MARK: - Card Deal Animation (カード配布アニメーション)
    struct CardDealAnimation {
        // カード配布開始までの遅延時間
        static let initialDelay: Double = 0.8
        // カード配布間隔
        static let dealInterval: Double = 0.4
        // カード配布アニメーション時間
        static let dealDuration: Double = 0.6
        // 場札配布前の遅延時間
        static let fieldCardDelay: Double = 0.8
        // 場札配布アニメーション時間
        static let fieldCardDuration: Double = 0.8
        // 初期配布カード枚数
        static let initialCardsPerPlayer: Int = 2
    }
    
    // MARK: - Announcement Animation (アナウンスアニメーション)
    struct AnnouncementAnimation {
        // アニメーション開始遅延時間（初期化用）
        static let startDelay: Double = 0.1
        
        // フェーズ1: 右から中央への移動時間（高速化）
        static let enteringDuration: Double = 0.6
        
        // フェーズ2: 中央での停止時間（短縮）
        static let stayingDuration: Double = 1.0
        
        // フェーズ3: 中央から左への移動時間（高速化）
        static let exitingDuration: Double = 0.8
        
        // 総アニメーション時間（自動計算）
        static let totalDuration: Double = startDelay + enteringDuration + stayingDuration + exitingDuration
        
        // スパークルアニメーション開始タイミング（中央停止時）
        static let sparkleStartDelay: Double = startDelay + enteringDuration + 0.1
        
        // グローアニメーション開始タイミング（中央停止時）
        static let glowStartDelay: Double = startDelay + enteringDuration + 0.2
        
        // グローアニメーションの継続時間
        static let glowDuration: Double = 0.6
        
        // 画面外への追加オフセット値
        static let screenOffsetMargin: CGFloat = 200  // 右端外側への余裕
        static let textWidthMargin: CGFloat = 400     // テキスト幅を考慮した左端外側への余裕
    }
}

// MARK: - Player Layout Constants (プレイヤーレイアウト定数)
/// プレイヤーアイコンと手札レイアウトで使用する固定値を定義
struct PlayerLayoutConstants {
    
    // MARK: - Icon Sizes (アイコンサイズ)
    struct IconSize {
        static let bot: CGFloat = 45
        static let player: CGFloat = 75
    }
    
    // MARK: - Text Sizes (テキストサイズ)
    struct TextSize {
        static let botName: CGFloat = 11
        static let playerName: CGFloat = 15
    }
    
    // MARK: - Card Sizes (カードサイズ)
    struct CardSize {
        static let bot: CGFloat = 80
        static let player: CGFloat = 150
    }
    
    // MARK: - Offset Values (オフセット値)
    struct Offset {
        // Icon Offsets
        /// ⭐ プレイヤーアイコンの縦位置調整ポイント
        /// この値を変更することで、下部プレイヤー（自分）のアイコン位置を調整できます
        /// - 正の値：アイコンが下に移動
        /// - 負の値：アイコンが上に移動
        /// - 現在値: 60pt（下に60pt移動）
        static let playerIconVertical: CGFloat = 60
        
        // Hand Offsets
        /// ⭐ 手札位置の調整ポイント
        /// 各プレイヤー位置の手札オフセット値
        /// 上部プレイヤーの手札縦位置（負の値で上に移動）
        static let topHandVertical: CGFloat = -30
        /// 左側プレイヤーの手札横位置（負の値で左に移動）
        static let leftHandHorizontal: CGFloat = -30
        /// 右側プレイヤーの手札横位置（正の値で右に移動）
        static let rightHandHorizontal: CGFloat = 30
        /// 下部プレイヤー（自分）の手札縦位置（正の値で下に移動）
        static let playerHandVertical: CGFloat = 20
    }
    
    // MARK: - Radius Values (半径値)
    struct Radius {
        static let botFan: CGFloat = 35
        static let topBotFan: CGFloat = 45
        static let playerFan: CGFloat = 55
    }
    
    // MARK: - Angle Values (角度値)
    struct Angle {
        static let botFan: Double = 60
        static let playerFan: Double = 90
        static let rotation: Double = 0
        
        // 扇形配置用の角度設定
        static let playerCardSpacing: Double = 30.0      // 自分の手札のカード間隔角度
        static let playerCardTilt: Double = 10.0         // 自分の手札のカード傾き角度
        static let botCardSpacing: Double = 15.0         // Botの手札のカード間隔角度
        static let botCardTilt: Double = 6.0             // Botの手札のカード傾き角度
    }
    
    // MARK: - Fan Layout Values (扇形配置値)
    struct FanLayout {
        static let playerCurveCoefficient: Double = 0.15   // 自分の手札の放物線係数（端のカードほど下に）
        static let botCurveCoefficient: Double = 0.08      // Botの手札の放物線係数（控えめな扇形）
    }
    
    // MARK: - Hand Area Sizes (手札エリアサイズ)
    struct HandAreaSize {
        static let topBot = CGSize(width: 160, height: 45)
        static let sideBot = CGSize(width: 100, height: 45)
        static let player = CGSize(width: 220, height: 85)
    }
}

// MARK: - Game Layout Configuration
/// ゲーム画面全体のレイアウト設定
struct GameLayoutConfig {
    // MARK: - Screen Area Ratios (画面エリアの比率)
    /// ヘッダーエリアの高さ比率（ゲーム情報表示エリア）
    static let headerAreaHeightRatio: CGFloat = LayoutConstants.ScreenRatio.header
    /// 上部エリアの高さ比率（相手プレイヤー配置エリア）
    static let topAreaHeightRatio: CGFloat = LayoutConstants.ScreenRatio.topArea
    /// 中央エリアの高さ比率（ゲームフィールド）
    static let centerAreaHeightRatio: CGFloat = LayoutConstants.ScreenRatio.centerArea
    /// 下部エリアの高さ比率（自分のプレイヤー配置エリア）
    static let bottomAreaHeightRatio: CGFloat = LayoutConstants.ScreenRatio.bottomArea
    
    // MARK: - Header Area (ヘッダーエリア設定)
    /// ヘッダーエリアの左右パディング
    static let headerHorizontalPadding: CGFloat = LayoutConstants.Padding.headerHorizontal
    /// ヘッダーエリアの上下パディング
    static let headerVerticalPadding: CGFloat = LayoutConstants.Padding.headerVertical
    /// ヘッダー内要素間のスペース
    static let headerItemSpacing: CGFloat = LayoutConstants.Spacing.headerItems
    
    // MARK: - Player Icon Positioning (プレイヤーアイコンの位置調整)
    /// 上部プレイヤーの左右パディング
    static let topPlayersHorizontalPadding: CGFloat = LayoutConstants.Padding.topPlayersHorizontal
    /// 上部プレイヤーの上パディング
    static let topPlayersTopPadding: CGFloat = LayoutConstants.Padding.topPlayersTop
    
    /// 左右サイドプレイヤーエリアの幅
    static let sidePlayersAreaWidth: CGFloat = LayoutConstants.Size.sidePlayersAreaWidth
    /// 中央ゲームエリアの左右パディング
    static let centerAreaHorizontalPadding: CGFloat = LayoutConstants.Padding.centerAreaHorizontal
    
    /// 下部プレイヤーの下パディング（広告エリアからの距離）
    static let bottomPlayerBottomPadding: CGFloat = LayoutConstants.Padding.bottomPlayerBottom
    
    // MARK: - Game Field (ゲームフィールド設定)
    /// 中央カード配置エリアの幅
    static let gameFieldWidth: CGFloat = LayoutConstants.Size.gameFieldWidth
    /// 中央カード配置エリアの高さ
    static let gameFieldHeight: CGFloat = LayoutConstants.Size.gameFieldHeight
    
    // MARK: - Back Button (戻るボタン設定)
    // ⭐ 戻るボタンは削除されたため、以下の設定は使用されません
    // /// 戻るボタンの左パディング
    // static let backButtonLeadingPadding: CGFloat = LayoutConstants.Padding.backButtonLeading
    // /// 戻るボタンの上パディング
    // static let backButtonTopPadding: CGFloat = LayoutConstants.Padding.backButtonTop
    
    // MARK: - Deck Position (デッキ位置設定)
    /// デッキのX位置比率
    static let deckPositionXRatio: CGFloat = LayoutConstants.Position.deckXRatio
    /// デッキのY位置比率
    static let deckPositionYRatio: CGFloat = LayoutConstants.Position.deckYRatio
}

// MARK: - Player Layout Configuration
/// プレイヤーアイコンと手札の配置設定
/// 
/// ⭐ 参加人数による自動調整について：
/// PlayerIconView.swift の adaptiveCardSize と adaptiveSpacing で、
/// viewModel.maxPlayers の値に応じてBotのカードサイズとスペーシングが自動調整されます
/// プレイヤー自身（bottom）のカードは参加人数に関係なく固定サイズです
/// 
/// Botの調整倍率：
/// - 2人：カードサイズ 1.2倍、スペーシング 0.8倍
/// - 3人：カードサイズ 1.0倍、スペーシング 1.0倍（基準）
/// - 4人：カードサイズ 0.85倍、スペーシング 1.2倍
/// - 5人：カードサイズ 0.7倍、スペーシング 1.4倍
/// - 6人以上：カードサイズ 0.6倍、スペーシング 1.6倍
/// 
/// プレイヤー自身（bottom）：
/// - カードサイズ：常に config.cardSize（現在70）
/// - スペーシング：手札数による固定値（-10〜-30）
struct PlayerLayoutConfig {
    // MARK: - Icon Position Configuration
    struct IconPosition {
        /// アイコンのオフセット位置
        let offset: CGSize
        /// アイコンのサイズ
        let size: CGFloat
        /// 名前テキストのサイズ
        let nameTextSize: CGFloat
        
        init(offset: CGSize = .zero, size: CGFloat = PlayerLayoutConstants.IconSize.bot, nameTextSize: CGFloat = PlayerLayoutConstants.TextSize.botName) {
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
        
        // ⭐ Botのカードサイズ統一ポイント：
        // この値を変更することで、各位置のBotの基本カードサイズを統一できます
        // 実際のサイズは、PlayerIconView.swift の adaptiveCardSize で手札数に応じて自動調整されます
        /// カードサイズ（基本サイズ - 手札数によって動的調整される）
        let cardSize: CGFloat
        
        /// 手札エリアのサイズ
        let handAreaSize: CGSize
        
        init(
            globalOffset: CGSize = .zero,
            globalRotation: Double = PlayerLayoutConstants.Angle.rotation,
            fanMaxAngle: Double = PlayerLayoutConstants.Angle.botFan,
            fanRadius: CGFloat = PlayerLayoutConstants.Radius.botFan,
            cardSize: CGFloat = PlayerLayoutConstants.CardSize.bot,
            handAreaSize: CGSize = PlayerLayoutConstants.HandAreaSize.sideBot
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
    /// ⭐ 上部プレイヤー（Bot）の配置設定
    /// アイコンと手札の位置を調整したい場合は、以下の値を変更してください
    static let topPlayer = (
        icon: IconPosition(
            // アイコンの位置オフセット（x: 横位置, y: 縦位置）
            offset: .zero,
            // アイコンのサイズ
            size: PlayerLayoutConstants.IconSize.bot,
            // 名前テキストのサイズ
            nameTextSize: PlayerLayoutConstants.TextSize.botName
        ),
        hand: HandConfiguration(
            // 手札全体の位置オフセット（topHandVerticalで縦位置調整）
            globalOffset: CGSize(width: 0, height: PlayerLayoutConstants.Offset.topHandVertical),
            globalRotation: PlayerLayoutConstants.Angle.rotation,
            fanMaxAngle: PlayerLayoutConstants.Angle.botFan,
            fanRadius: PlayerLayoutConstants.Radius.topBotFan,
            cardSize: PlayerLayoutConstants.CardSize.bot,
            handAreaSize: PlayerLayoutConstants.HandAreaSize.topBot
        )
    )
    
    /// ⭐ 左側プレイヤー（Bot）の配置設定
    static let leftPlayer = (
        icon: IconPosition(
            offset: .zero,
            size: PlayerLayoutConstants.IconSize.bot,
            nameTextSize: PlayerLayoutConstants.TextSize.botName
        ),
        hand: HandConfiguration(
            // 手札全体の位置オフセット（leftHandHorizontalで横位置調整）
            globalOffset: CGSize(width: PlayerLayoutConstants.Offset.leftHandHorizontal, height: 0),
            globalRotation: PlayerLayoutConstants.Angle.rotation,
            fanMaxAngle: PlayerLayoutConstants.Angle.botFan,
            fanRadius: PlayerLayoutConstants.Radius.botFan,
            cardSize: PlayerLayoutConstants.CardSize.bot,
            handAreaSize: PlayerLayoutConstants.HandAreaSize.sideBot
        )
    )
    
    /// ⭐ 右側プレイヤー（Bot）の配置設定
    static let rightPlayer = (
        icon: IconPosition(
            offset: .zero,
            size: PlayerLayoutConstants.IconSize.bot,
            nameTextSize: PlayerLayoutConstants.TextSize.botName
        ),
        hand: HandConfiguration(
            // 手札全体の位置オフセット（rightHandHorizontalで横位置調整）
            globalOffset: CGSize(width: PlayerLayoutConstants.Offset.rightHandHorizontal, height: 0),
            globalRotation: PlayerLayoutConstants.Angle.rotation,
            fanMaxAngle: PlayerLayoutConstants.Angle.botFan,
            fanRadius: PlayerLayoutConstants.Radius.botFan,
            cardSize: PlayerLayoutConstants.CardSize.bot,
            handAreaSize: PlayerLayoutConstants.HandAreaSize.sideBot
        )
    )
    
    /// ⭐ 下部プレイヤー（自分）の配置設定
    static let bottomPlayer = (
        icon: IconPosition(
            // アイコンの位置オフセット（playerIconVerticalで縦位置調整）
            offset: CGSize(width: 0, height: PlayerLayoutConstants.Offset.playerIconVertical),
            size: PlayerLayoutConstants.IconSize.player,
            nameTextSize: PlayerLayoutConstants.TextSize.playerName
        ),
        hand: HandConfiguration(
            // 手札全体の位置オフセット（playerHandVerticalで縦位置調整）
            globalOffset: CGSize(width: 0.0, height: PlayerLayoutConstants.Offset.playerHandVertical),
            globalRotation: PlayerLayoutConstants.Angle.rotation,
            fanMaxAngle: PlayerLayoutConstants.Angle.playerFan,
            fanRadius: PlayerLayoutConstants.Radius.playerFan,
            cardSize: PlayerLayoutConstants.CardSize.player,
            handAreaSize: PlayerLayoutConstants.HandAreaSize.player
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
