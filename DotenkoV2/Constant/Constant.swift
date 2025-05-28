/**
 定数ファイル
 */

import SwiftUI

struct Constant {
            
    // MARK: - OKFlg
    static let FLAG_ON = "1"
    // MARK: - NGFlg
    static let FLAG_OFF = "0"
    // MARK: - Banner Height
    static let BANNER_HEIGHT = 80
    
}


// MARK: - Layout Configuration
/// ゲーム画面のレイアウト設定
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
    /// 上部プレイヤーの上パディング（もっと上に配置）
    static let topPlayersTopPadding: CGFloat = 10
    
    /// 左右サイドプレイヤーエリアの幅（幅を狭める）
    static let sidePlayersAreaWidth: CGFloat = 60
    /// 中央ゲームエリアの左右パディング（中央プレイヤーを上部プレイヤーに近づける）
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
}
