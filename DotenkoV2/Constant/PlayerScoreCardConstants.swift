import Foundation
import SwiftUI

/// プレイヤースコアカードの定数定義
struct PlayerScoreCardConstants {
    
    // MARK: - Layout Constants
    struct Layout {
        /// カード内水平スペーシング
        static let cardHorizontalSpacing: CGFloat = 12
        /// カード内垂直スペーシング
        static let cardVerticalSpacing: CGFloat = 1
        /// カード水平パディング
        static let cardHorizontalPadding: CGFloat = 14
        /// カード垂直パディング
        static let cardVerticalPadding: CGFloat = 3
    }
    
    // MARK: - Icon Constants
    struct Icon {
        /// アイコンサイズ比率（カード高さに対する）
        static let sizeRatio: CGFloat = 0.7
        /// アイコン最大サイズ
        static let maxSize: CGFloat = 40
        /// イニシャル文字サイズ比率
        static let initialTextRatio: CGFloat = 0.35
        /// イニシャル文字最大サイズ
        static let maxInitialTextSize: CGFloat = 14
    }
    
    // MARK: - Typography Constants
    struct Typography {
        /// プレイヤー名フォントサイズ比率
        static let nameRatio: CGFloat = 0.3
        /// プレイヤー名最大フォントサイズ
        static let maxNameSize: CGFloat = 14
        /// スコア変動フォントサイズ比率
        static let scoreChangeRatio: CGFloat = 0.25
        /// スコア変動最大フォントサイズ
        static let maxScoreChangeSize: CGFloat = 11
        /// 現在スコアフォントサイズ比率
        static let currentScoreRatio: CGFloat = 0.4
        /// 現在スコア最大フォントサイズ
        static let maxCurrentScoreSize: CGFloat = 16
    }
    
    // MARK: - Dimensions Constants
    struct Dimensions {
        /// カード角丸
        static let cardCornerRadius: CGFloat = 10
        /// 境界線幅（プレイヤー）
        static let playerBorderWidth: CGFloat = 2
        /// 境界線幅（その他）
        static let otherBorderWidth: CGFloat = 1
        /// シャドウ半径
        static let shadowRadius: CGFloat = 4
        /// シャドウオフセット
        static let shadowOffset: CGFloat = 2
    }
    
    // MARK: - Colors
    struct Colors {
        /// プレイヤーゴールド透明度
        static let playerGoldOpacity: Double = 0.3
        /// グレー透明度
        static let grayOpacity: Double = 0.4
        /// 緑透明度
        static let greenOpacity: Double = 0.8
        /// 赤透明度
        static let redOpacity: Double = 0.8
        /// 黒透明度（背景1）
        static let blackOpacity1: Double = 0.8
        /// 黒透明度（背景2）
        static let blackOpacity2: Double = 0.6
        /// モスグリーン透明度1
        static let mossGreenOpacity1: Double = 0.3
        /// モスグリーン透明度2
        static let mossGreenOpacity2: Double = 0.2
        /// プレイヤーゴールド境界線透明度
        static let playerGoldBorderOpacity: Double = 0.8
        /// カジノゴールドグロー境界線透明度
        static let casinoGoldBorderOpacity: Double = 0.4
        /// カジノゴールドグロー境界線透明度2
        static let casinoGoldBorder2Opacity: Double = 0.6
        /// 白境界線透明度
        static let whiteBorderOpacity: Double = 0.2
        /// プレイヤーゴールドシャドウ透明度
        static let playerGoldShadowOpacity: Double = 0.3
        /// 黒シャドウ透明度
        static let blackShadowOpacity: Double = 0.4
        /// カジノゴールドグロー透明度
        static let casinoGoldGlowOpacity: Double = 0.8
        /// カジノゴールドグロー2透明度
        static let casinoGoldGlow2Opacity: Double = 0.5
    }
} 