import Foundation
import SwiftUI

/// 中間結果画面の定数定義
struct InterimResultConstants {
    
    // MARK: - Layout Constants
    struct Layout {
        /// タイトル上部パディング
        static let titleTopPadding: CGFloat = 40
        /// カード開始パディング
        static let cardStartPadding: CGFloat = 30
        /// ボタン下部パディング（固定位置用・広告分含む）
        static let buttonBottomPadding: CGFloat = 110
        /// 水平パディング
        static let horizontalPadding: CGFloat = 20
        /// 下部予約高さ
        static let bottomReservedHeight: CGFloat = 50
    }
    
    // MARK: - Typography Constants
    struct Typography {
        /// タイトルフォントサイズ
        static let titleSize: CGFloat = 22
        /// 待機メッセージフォントサイズ
        static let waitingMessageSize: CGFloat = 14
        /// ボタンフォントサイズ
        static let buttonFontSize: CGFloat = 18
    }
    
    // MARK: - Dimensions Constants
    struct Dimensions {
        /// ボタン高さ
        static let buttonHeight: CGFloat = 45
        /// 最小カード高さ
        static let minCardHeight: CGFloat = 45
        /// 最大カード高さ
        static let maxCardHeight: CGFloat = 80
        /// ボタン角丸
        static let buttonCornerRadius: CGFloat = 12
    }
    
    // MARK: - Spacing Constants
    struct Spacing {
        /// タイトルスペーシング
        static let titleSpacing: CGFloat = 5
        /// ボタンスペーシング
        static let buttonSpacing: CGFloat = 8
    }
    
    // MARK: - Card Spacing by Player Count
    struct CardSpacing {
        /// プレイヤー数別カード間スペーシング
        static func spacing(for playerCount: Int) -> CGFloat {
            switch playerCount {
            case 2: return 25
            case 3: return 20
            case 4: return 15
            case 5: return 10
            default: return 5
            }
        }
    }
    
    // MARK: - Messages
    struct Messages {
        /// 待機メッセージ
        static let waitingMessage = "他のプレイヤーを待機中..."
        /// ログメッセージ
        static let logDisplayMessage = "中間結果画面表示"
        static let logOKButtonMessage = "中間結果画面 - OKボタンタップ"
    }
    
    // MARK: - Colors
    struct Colors {
        /// 背景透明度
        static let backgroundOpacity: Double = 0.7
        /// 緑ボタン透明度（上）
        static let greenButtonTopOpacity: Double = 0.9
        /// 緑ボタン透明度（下）
        static let greenButtonBottomOpacity: Double = 0.7
        /// シャドウ透明度
        static let shadowOpacity: Double = 0.4
    }
    
    // MARK: - Animation Constants
    struct Animation {
        /// カード表示アニメーション遅延（基本）
        static let cardBaseDelay: Double = 0.1
        /// カード表示アニメーション間隔
        static let cardDelayInterval: Double = 0.15
        /// カード表示アニメーション時間
        static let cardDuration: Double = 0.6
        /// スコアカウントアニメーション時間
        static let scoreCountDuration: Double = 1.2
        /// スコアカウントアニメーション遅延
        static let scoreCountDelay: Double = 0.8
        /// スコア変動表示遅延
        static let scoreChangeDelay: Double = 0.3
        /// 順位ソートアニメーション遅延
        static let rankSortDelay: Double = 2.5
        /// 順位ソートアニメーション時間
        static let rankSortDuration: Double = 1.0
        /// 順位ソート間隔
        static let rankSortInterval: Double = 0.1
        /// スプリングアニメーション設定
        static let springResponse: Double = 0.8
        static let springDampingFraction: Double = 0.7
        static let springBlendDuration: Double = 0.3
        /// 順位ソート用スプリング設定
        static let sortSpringResponse: Double = 1.0
        static let sortSpringDampingFraction: Double = 0.8
        static let sortSpringBlendDuration: Double = 0.4
    }
} 
