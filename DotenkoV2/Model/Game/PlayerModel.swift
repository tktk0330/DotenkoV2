import SwiftUI

/// プレイヤーモデル
/// - Parameters:
///   - id: ユーザーID
///   - side: ユーザーサイド
///   - name: ユーザー名
///   - iconUrl: プロフィール画像のURL（オプション）
///   - hand: 手札
///   - selectedCards: 選択中カード
///   - score: ゲームスコア
///   - rank: 順位
///   - dtnk: どてんこ可能フラグ
///   - hasDrawnCardThisTurn: このターンでカードを引いたかどうか
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
    var hasDrawnCardThisTurn: Bool = false
}

