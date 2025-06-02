/**
 カードの設定
 */

import UIKit

// カードモデル
struct Card: Identifiable, Equatable, Hashable{
    let id = UUID()
    let card: PlayCard
    var location: CardLocation
    var handRotation: Double = 0.0 // 手札での回転角度を保存
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable conformance
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }
}

// カードの位置を表す列挙型
enum CardLocation: Equatable, Hashable{
    case hand(playerIndex: Int, cardIndex: Int)
    case deck
    case field
}

enum PlayCard: String, CaseIterable {
    
    case back = "back-1"
    case whiteJoker = "jorker-1"
    case blackJoker = "jorker-2"
    
    case spade1 = "s01", spade2 = "s02", spade3 = "s03", spade4 = "s04", spade5 = "s05"
    case spade6 = "s06", spade7 = "s07", spade8 = "s08", spade9 = "s09", spade10 = "s10"
    case spade11 = "s11", spade12 = "s12", spade13 = "s13"
    
    case club1 = "c01", club2 = "c02", club3 = "c03", club4 = "c04", club5 = "c05"
    case club6 = "c06", club7 = "c07", club8 = "c08", club9 = "c09", club10 = "c10"
    case club11 = "c11", club12 = "c12", club13 = "c13"
    
    case heart1 = "h01", heart2 = "h02", heart3 = "h03", heart4 = "h04", heart5 = "h05"
    case heart6 = "h06", heart7 = "h07", heart8 = "h08", heart9 = "h09", heart10 = "h10"
    case heart11 = "h11", heart12 = "h12", heart13 = "h13"
    
    case diamond1 = "d01", diamond2 = "d02", diamond3 = "d03", diamond4 = "d04", diamond5 = "d05"
    case diamond6 = "d06", diamond7 = "d07", diamond8 = "d08", diamond9 = "d09", diamond10 = "d10"
    case diamond11 = "d11", diamond12 = "d12", diamond13 = "d13"

    func name() -> String {
        return self.rawValue
    }
    
    func suit() -> Suit {
        switch self {
        case .back:
            return .other
        case .whiteJoker, .blackJoker:
            return .joker
        case .spade1, .spade2, .spade3, .spade4, .spade5, .spade6, .spade7, .spade8, .spade9, .spade10, .spade11, .spade12, .spade13:
            return .spade
        case .club1, .club2, .club3, .club4, .club5, .club6, .club7, .club8, .club9, .club10, .club11, .club12, .club13:
            return .club
        case .heart1, .heart2, .heart3, .heart4, .heart5, .heart6, .heart7, .heart8, .heart9, .heart10, .heart11, .heart12, .heart13:
            return .heart
        case .diamond1, .diamond2, .diamond3, .diamond4, .diamond5, .diamond6, .diamond7, .diamond8, .diamond9, .diamond10, .diamond11, .diamond12, .diamond13:
            return .diamond
        }
    }
    
    //　手札で取りうる値
    func handValue() -> [Int] {
        switch self {
        case .spade1, .heart1, .diamond1, .club1:
            return [1]
        case .spade2, .heart2, .diamond2, .club2:
            return [2]
        case .spade3, .heart3, .diamond3, .club3:
            return [3]
        case .spade4, .heart4, .diamond4, .club4:
            return [4]
        case .spade5, .heart5, .diamond5, .club5:
            return [5]
        case .spade6, .heart6, .diamond6, .club6:
            return [6]
        case .spade7, .heart7, .diamond7, .club7:
            return [7]
        case .spade8, .heart8, .diamond8, .club8:
            return [8]
        case .spade9, .heart9, .diamond9, .club9:
            return [9]
        case .spade10, .heart10, .diamond10, .club10:
            return [10]
        case .spade11, .heart11, .diamond11, .club11:
            return [11]
        case .spade12, .heart12, .diamond12, .club12:
            return [12]
        case .spade13, .heart13, .diamond13, .club13:
            return [13]
        case .blackJoker, .whiteJoker:
            return [-1,0,1]
        case .back:
            return [900]
        }
    }
    
    //　最初にめくった時のレート値[開始時, 終了時]([0,1])　倍：５０　逆転：２０　ダイ３：３０
    func rateValue() -> [Int] {
        switch self {
        case .spade1, .heart1, .diamond1, .club1, .spade2, .heart2, .diamond2, .club2, .whiteJoker, .blackJoker:
            return [50,50]
        case .spade3, .club3:
            return [3,20]
        case .diamond3:
            return [3,30]
        case .heart3:
            return [3,3]
        case .spade4, .heart4, .diamond4, .club4:
            return [4,4]
        case .spade5, .heart5, .diamond5, .club5:
            return [5,5]
        case .spade6, .heart6, .diamond6, .club6:
            return [6,6]
        case .spade7, .heart7, .diamond7, .club7:
            return [7,7]
        case .spade8, .heart8, .diamond8, .club8:
            return [8,8]
        case .spade9, .heart9, .diamond9, .club9:
            return [9,9]
        case .spade10, .heart10, .diamond10, .club10:
            return [10,10]
        case .spade11, .heart11, .diamond11, .club11:
            return [11,11]
        case .spade12, .heart12, .diamond12, .club12:
            return [12,12]
        case .spade13, .heart13, .diamond13, .club13:
            return [13,13]
        case .back:
            return [900]
        }
    }

    func image() -> UIImage? {
        return UIImage(named: self.rawValue)
    }
}

enum Suit: String {
    case spade = "s"
    case heart = "h"
    case diamond = "d"
    case club = "c"
    case joker = "j"
    case other = "o"
}
