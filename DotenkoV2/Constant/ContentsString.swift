/**
 表示テキストの管理
 */

enum ContentsString: String {
    
    case roundCount = "ラウンド数"
    case jokerCount = "ジョーカー枚数"
    case gameRate = "ゲームレート"
    case upRate = "重ねレートアップ"
    case maxScore = "スコア上限"
    case deckCycle = "デッキサイクル"
    
    case gameCountDetail = "１ゲームのラウンド数を決めます"
    case jokerCountDetail  = "利用するジョーカーの枚数を決めます"
    case gameRateDetail  = "ゲームのレートを決めます"
    case upRateDetail  = "同じカードが何枚重なった時、レートが上がるかを決めます"
    case maxScoreDetail  = "１ラウンドのスコア上限を決めます"
    case deckCycleDetail  = "１ラウンドでデッキを何周させるかを決めます"
    
    case gameCountExample = "例：１０ラウンドで１ゲーム終了"
    case jokerCountExample  = "例：ジョーカー１枚利用"
    case gameRateExample  = "例：レート１０なら、最後の数字に✖︎１０をする"
    case upRateExample  = "例：３の場合、同じ数字が３枚連続で出た時にレートが✖︎２される"
    case maxScoreExample  = "例：１０００点の場合、ラウンドスコアで算出された数字が１５００点でも１０００点がやり取りされる"
    case deckCycleExample  = "例：３の場合、デッキサイクルが３周すると勝敗がつかず、ラウンドが終了となる"
    
}
