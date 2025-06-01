import SwiftUI

// プレイヤーモデル
struct Player: Identifiable {
    let id: String
    let side: Int
    let name: String
    let icon_url: String?
    var hand: [Card] = []
    var selectedCards: [Card] = []
    var score = 0
    var rank = 0
    var dtnk: Bool
}

