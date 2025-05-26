import SwiftUI




class GamePlayer: Identifiable {
    let id: String
    var side: Int
    var name: String
    var icon_url: String
//    var hand: [Card] = []
    var score = 0
    var rank = 0
    var dtnk: Bool
//    var selectedCards: [Card] = []
    
    init(id: String, side: Int, name: String, icon_url: String) {
        self.id = id
        self.side = side
        self.name = name
        self.icon_url = icon_url
        self.score = 0
        self.rank = 0
        self.dtnk = false

    }
}

