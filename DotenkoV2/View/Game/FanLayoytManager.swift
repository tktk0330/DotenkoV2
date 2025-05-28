import SwiftUI

// MARK: - Fan Layout Manager
/// 扇形レイアウト管理クラス
struct FanLayoutManager {
    
    /// カードの回転角度を計算
    static func cardRotation(for index: Int, position: PlayerPosition, totalCards: Int, config: PlayerLayoutConfig.HandConfiguration) -> Double {
        let maxAngle: Double = config.fanMaxAngle
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
            return -baseRotation // 左側も下向きの扇（上部と同じ）
        case .right:
            return -baseRotation // 右側も下向きの扇（上部と同じ）
        }
    }
    
    /// カードのオフセット位置を計算
    static func cardOffset(for index: Int, position: PlayerPosition, totalCards: Int, config: PlayerLayoutConfig.HandConfiguration) -> CGSize {
        // カード間の直線的な間隔を計算
        let cardSpacing: CGFloat = config.cardSize * 0.18 // より密集させたい場合は小さくする
        let totalWidth = cardSpacing * CGFloat(totalCards - 1)
        let startX = -totalWidth / 2
        let x = startX + (cardSpacing * CGFloat(index))
        
        // Y方向は扇形の曲線に沿って配置
        let maxAngle: Double = config.fanMaxAngle
        let angleStep = maxAngle / Double(max(totalCards - 1, 1))
        let startAngle = -maxAngle / 2
        let currentAngle = startAngle + (Double(index) * angleStep)
        let radians = currentAngle * .pi / 180
        let y = config.fanRadius * cos(radians)
        
        // 位置に応じてオフセットを調整
        switch position {
        case .bottom:
            return CGSize(width: x, height: -abs(y)) // 下部は上向きの扇
        case .top:
            return CGSize(width: x, height: abs(y)) // 上部は下向きの扇
        case .left:
            return CGSize(width: x, height: abs(y)) // 左側も下向きの扇（上部と同じ）
        case .right:
            return CGSize(width: x, height: abs(y)) // 右側も下向きの扇（上部と同じ）
        }
    }
}
