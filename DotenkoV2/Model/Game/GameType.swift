import Foundation

/// ゲームタイプ
enum GameType {
    case vsBot
    case online
}

// MARK: - Player Position Enum
/// プレイヤーの画面上での配置位置
enum PlayerPosition {
    case top
    case bottom
    case left
    case right
}

// MARK: - Game Phase Enum
/// ゲームフェーズ
enum GamePhase {
    case waiting    // 待機中
    case playing    // プレイ中
    case finished   // 終了
}
