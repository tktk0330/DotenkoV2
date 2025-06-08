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
    
    // MARK: - Hand Count Badge Constants
    /// 手札枚数バッジ関連の定数
    struct HandCountBadge {
        /// プレイヤーバッジのサイズ
        static let playerBadgeSize: CGFloat = 24
        /// ボットバッジのサイズ
        static let botBadgeSize: CGFloat = 20
        /// プレイヤーバッジのテキストサイズ
        static let playerTextSize: CGFloat = 12
        /// ボットバッジのテキストサイズ
        static let botTextSize: CGFloat = 10
        
        /// ⭐ バッジとアイコンの間隔調整ポイント
        /// この値を変更することで、手札数字バッジとプレイヤーアイコンの距離を調整できます
        /// - 正の値：バッジがアイコンから離れる（上に移動）
        /// - 負の値：バッジがアイコンに近づく（下に移動）
        /// - 現在値: 2pt（アイコンから少し離れた位置）
        static let iconSpacing: CGFloat = 2
        
        // MARK: - Casino Colors
        /// カジノ風バッジ色
        struct CasinoColors {
            static let redTop = Color.red.opacity(0.9)
            static let redMiddle = Color(red: 0.8, green: 0.0, blue: 0.2)
            static let redBottom = Color(red: 0.6, green: 0.0, blue: 0.1)
            static let goldBorder = Color(red: 1.0, green: 0.8, blue: 0.0)
        }
    }
} 
