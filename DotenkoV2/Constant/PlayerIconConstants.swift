/**
 プレイヤーアイコン関連の定数定義
 */

import SwiftUI

struct PlayerIconConstants {
    
    // MARK: - Animation Constants
    /// アニメーション関連の定数
    struct Animation {
        /// カード選択時のオフセット値
        static let cardSelectionOffset: CGFloat = -30
        /// アニメーションの基本継続時間
        static let duration: Double = 0.3
    }
    
    // MARK: - Spacing Constants
    /// スペーシング関連の定数
    struct Spacing {
        /// プレイヤー名の垂直スペース
        static let nameVertical: CGFloat = 1
        /// スコア表示の垂直スペース
        static let scoreVertical: CGFloat = 4
    }
    
    // MARK: - Decoration Constants
    /// 装飾関連の定数
    struct Decoration {
        /// メインプレイヤーのボーダー幅
        static let playerBorderWidth: CGFloat = 3
        /// ボットプレイヤーのボーダー幅
        static let botBorderWidth: CGFloat = 2
        /// プレイヤー名表示の角丸半径
        static let nameCornerRadius: CGFloat = 6
        /// メインプレイヤーのスコア表示の角丸半径
        static let scoreCornerRadius: CGFloat = 8
        /// ボットプレイヤーのスコア表示の角丸半径
        static let botScoreCornerRadius: CGFloat = 4
    }
} 