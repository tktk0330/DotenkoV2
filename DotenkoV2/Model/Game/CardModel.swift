/**
 カードの設定
 */

import UIKit

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

    func state() -> String {
        switch self {
        case .back:
            return "裏"
        default:
            return "表"
        }
    }

    func image() -> UIImage? {
        return UIImage(named: self.rawValue)
    }
}
