import SwiftUI

// MARK: - Player Position Manager
/// プレイヤー位置管理クラス
struct PlayerPositionManager {
    
    /// 現在のプレイヤー（自分）を取得
    static func getCurrentPlayer(from players: [Player]) -> Player? {
        return players.first { !$0.id.hasPrefix("bot-") }
    }
    
    /// 上部に配置するプレイヤーを取得
    static func getTopPlayers(from players: [Player], maxPlayers: Int) -> [Player] {
        let botPlayers = players.filter { $0.id.hasPrefix("bot-") }
        
        switch maxPlayers {
        case 2:
            return Array(botPlayers.prefix(1)) // 2人戦：上に1人
        case 3:
            return Array(botPlayers.prefix(2)) // 3人戦：上に2人
        case 4:
            return Array(botPlayers.prefix(1)) // 4人戦：上に1人
        case 5:
            return Array(botPlayers.prefix(2)) // 5人戦：上に2人
        default:
            return Array(botPlayers.prefix(1))
        }
    }
    
    /// 左側に配置するプレイヤーを取得
    static func getSidePlayersLeft(from players: [Player], maxPlayers: Int) -> [Player] {
        let botPlayers = players.filter { $0.id.hasPrefix("bot-") }
        
        switch maxPlayers {
        case 4:
            return Array(botPlayers.dropFirst(1).prefix(1)) // 4人戦：左に1人
        case 5:
            return Array(botPlayers.dropFirst(2).prefix(1)) // 5人戦：左に1人
        default:
            return []
        }
    }
    
    /// 右側に配置するプレイヤーを取得
    static func getSidePlayersRight(from players: [Player], maxPlayers: Int) -> [Player] {
        let botPlayers = players.filter { $0.id.hasPrefix("bot-") }
        
        switch maxPlayers {
        case 4:
            return Array(botPlayers.dropFirst(2).prefix(1)) // 4人戦：右に1人
        case 5:
            return Array(botPlayers.dropFirst(3).prefix(1)) // 5人戦：右に1人
        default:
            return []
        }
    }
}
