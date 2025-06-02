import SwiftUI

// MARK: - Player Layout Configuration
/// プレイヤーアイコンと手札の配置設定
struct PlayerLayoutConfig {
    // MARK: - Bot Icon Positioning (Botアイコンの配置)
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
    
    // MARK: - Hand Cards Configuration (手札の配置設定)
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
