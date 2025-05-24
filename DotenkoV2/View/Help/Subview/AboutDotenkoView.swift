import SwiftUI

//case roundCount
//case jokerCount
//case gameRate
//case upRate
//case maxScore
//case deckCycle
//
//case contact
//
//case review
//
//case privacyPoricy
//case poricy
// カード
struct RuleCardView: View {
    let cardName: String
    var body: some View {
        Image(cardName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50)
    }
}

struct GameDetailRuleCommonView: View {
    let type: GameSetting
    var body: some View {
        VStack() {
            Text(type.detail)
                .font(.system(size: 15))
            
            Text(type.example)
                .font(.system(size: 15))
            
        }
    }
}

struct CardExplanationView: View {
    var body: some View {
        VStack() {
            
            Text("Joker")
            // TODO: 説明のカードを並べる
            
            Text(
            """
                手札 ： -1 0 1のいずれかとして扱うことができる
            """)
            
            HStack(spacing: 20) {
                HStack(spacing: -10) {
                    RuleCardView(cardName: PlayCard.blackJoker.rawValue)
                    RuleCardView(cardName: PlayCard.club1.rawValue)
                    RuleCardView(cardName: PlayCard.heart7.rawValue)
                }
                VStack() {
                    Text("例）7, 8, 9のいずれかとして扱える")
                        .font(.system(size: 15))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(.yellow)
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 100)
            )
            .padding(20)
            
            Text(
            """
                ゲーム開始フェーズ ： レートを✖︎２する
                点数計算フェーズ ： レートを✖︎２する
            """)
            
            Text("１・２")
            // TODO: 説明のカードを並べる
            Text(
            """
                手札 ： その数字として扱う
                ゲーム開始フェーズ ： レートを✖︎２する
                点数計算フェーズ ： レートを✖︎２する
            """)
            Text("♠️３・♣️３")
            // TODO: 説明のカードを並べる
            Text(
            """
                手札 ： 3として扱う
                ゲーム開始フェーズ ： 3として扱う
                点数計算フェーズ ： 勝敗を無条件で逆転させる
            """)
            Text("♦️３")
            // TODO: 説明のカードを並べる
            Text(
            """
                手札 ： 3として扱う
                ゲーム開始フェーズ ： 3として扱う
                点数計算フェーズ ： 数字を30として扱う
                    
                その他のカードはそのカードの意味のまま利用する。
            """)
            
            
            
            
            
        }
    }
}


//
struct GameEventView: View {
    private let items: [GameRuleExplanation] = [
        .init(
            title: "どてんこ / DOTENKO",
            description: "誰かが出した場のカードの数字と、自分の手札全ての合計数字が一致した時「どてんこ/DOTENKO」と宣言できる。\n勝者：どてんこした人\n敗者：どてんこされたカードを出した人"
        ),
        .init(
            title: "しょてんこ / SHOTENKO",
            description: "１番はじめに山札から捲られたカードの数字と、自分の手札全ての合計数字が一致した時「しょてんこ/SHOTENKO」と宣言できる。\n勝者：しょてんこした人\n敗者：その他全員"
        ),
        .init(
            title: "どてんこ返し / REVENGE",
            description: "誰かが「どてんこ/DOTENKO」を宣言した際、別のプレイヤーも「どてんこ/DOTENKO」できる状態であった場合、「どてんこ返し/REVENGE」と宣言し、勝者を上書きすることができる。\n勝者：最後に「どてんこ返し/REVENGE」した人\n敗者：１つ前に「どてんこ/DOTENKO」した人"
        ),
        .init(
            title: "チャレンジゾーン / Challenge Zone",
            description: "どてんこが確定した時、チャレンジゾーンに移る。手札の合計が場の数字より小さい場合参加可能。チャレンジは時計回りで実施し、山札から引いて新たに一致すれば「REVENGE」。誰もチャンスがなくなるまで続行。終了後点数計算へ。"
        ),
        .init(
            title: "バースト / Burst",
            description: "手札が７枚の時パスをするとバーストとなり自分の１人負けとなる。\n勝者：その他全員\n敗者：自分"
        ),
        .init(
            title: "ラウンドスコアの決定",
            description: "ラウンドスコアは「初期レート × 上昇レート × 山札裏のカード数字」で算出。特殊カードでレート上昇イベントがある。例：100 × 4 × 10 = 4000"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(items) { item in
                    ExplanationRow(item: item)
                }
            }
            .padding()
        }
        .navigationTitle("ゲームルール説明")
    }
}

/// ゲームの各ルール説明を表すモデル
struct GameRuleExplanation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

/// ルール説明の行を表示するサブビュー
struct ExplanationRow: View {
    let item: GameRuleExplanation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(item.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

struct AboutDotenkoView: View {
    var body: some View {
        VStack() {
            Text("""
            ・ プレイ推奨人数は4人（2〜8人でも可能）
            ・ 使用カードは52〜56(Jokerは４枚まで追加可能)
            ・ 自分のターンになったら条件に合うカードを出したり、パスをする。（詳しくはこちら）
            ・ 場の数字と手札の合計数字が一致した時「どてんこ/DOTENKO」と宣言し、勝者となることができる。「どてんこ/DOTENKO」を宣言された時に、場の一番上のカードを出していた人が負けになる。
            ・ ルールのカスタマイズが可能。（詳細ルールへ）
            """)
            .font(.system(size: 15))
        }
        .padding(10)
    }
}

struct GameFlowView: View {
    var body: some View {
        VStack() {
            Text("""
            １　各プレイヤーに手札を２枚ずつ配布する。
            ２　山札の一番上のカードをめくり、場の初めのカードを決める。
            ３　出せるカードがある場合は、早いもの順でカードを出す。1番はじめにカードを出した人から時計回りにゲームを開始する。
            　※ 1番初めの山札からめくったカードに対して「どてんこ/DOTENKO」（この場合は「しょてんこ/SHOTENKO」という）した場合、その人以外全員が敗者となる。
            ４　ターンが回ってきたプレイヤーは以下の行動ができる。
            　①　出せるカードがあるので出す
            　②　出せるカードがあるけど、カードを引き、出す
            　③　出せるカードがあるけど、カードを引き、パス
            　④　出せるカードがないので、カードを引き、出せるようになったので出す
            　⑤　出せるカードがないので、カードを引き、出せるようになったけどパス
            　⑥　出せるカードがないので、カードを引き、出せるようにならなかったのでパス
            　※ カードを出せるパターンについてはこちら。
            　※ カードを引けるのは１ターン１枚です。
            　※ カードを引かずにパスはできません。
            ５　山札がなくなったら、場の1番上のカードだけを残し、他を山札に加えて再生成する。
            ６　誰かが「どてんこ/DOTENKO」をしたらチャレンジゾーンへ移動する。
            　※ 「バースト」場合は得点計算フェーズへ移動する。
            ７　チャレンジゾーンではどてんこのチャンスがある人が、山札からカードを１枚ずつ引いていく。全てのプレイヤーのチャンスがなくなったら、点数計算フェーズへ移動する。
            ８　点数計算フェーズではそのラウンドでのスコアを確定させる。山札の１番下のカードを確認する。特殊カードが出た場合レート上昇や勝敗の逆転が発生し、特殊カード以外のカードになるまでめくる。カード確定後、スコアを計算し次のゲームへ。
            """)
            .font(.system(size: 15))
        }
        .padding(10)
    }
}

struct GameOperationView: View {
    var body: some View {
        VStack() {
            Text("""
            自分のターンでは場のカードに対し以下の条件でカードを出すことができる。
                    
            < 1枚で出す場合 >
            ・ 場のカードと同じ数字である。
            ・ 場のカードと同じスートである。
                    
            <Joker>
            ・ 希望する任意のカードとして扱うことができる。

            < 複数枚で出す場合 >
            ・ 場のカードの数字と出すカードの数字の合計が同じ。
            """)
            .font(.system(size: 15))
            
            HStack() {
                Spacer()
                RuleCardView(cardName: PlayCard.diamond13.rawValue)
                Spacer()
                HStack() {
                    HStack(spacing: -15) {
                        RuleCardView(cardName: PlayCard.diamond6.rawValue)
                        RuleCardView(cardName: PlayCard.spade7.rawValue)
                    }
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red, lineWidth: 3)
                    )
                    RuleCardView(cardName: PlayCard.club1.rawValue)
                    RuleCardView(cardName: PlayCard.heart10.rawValue)
                }
                Spacer()
            }
            
            
            Text("""
            ・ 場のカードと出すカードの数字が全て同じ。
            """)
            .font(.system(size: 15))
            
            HStack() {
                Spacer()
                RuleCardView(cardName: PlayCard.diamond13.rawValue)
                Spacer()
                HStack() {
                    HStack(spacing: -15) {
                        RuleCardView(cardName: PlayCard.spade13.rawValue)
                        RuleCardView(cardName: PlayCard.club13.rawValue)
                        RuleCardView(cardName: PlayCard.heart13.rawValue)
                    }
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red, lineWidth: 3)
                    )
                    RuleCardView(cardName: PlayCard.club1.rawValue)
                }
                Spacer()
            }
            
            Text("""
            ・ 場のカードと出す一番下のカードのスートが同じ　＋　出すカードの数字が全て同じ。
            """)
            .font(.system(size: 15))
            
            HStack() {
                Spacer()
                RuleCardView(cardName: PlayCard.diamond13.rawValue)
                Spacer()
                HStack() {
                    HStack(spacing: -15) {
                        RuleCardView(cardName: PlayCard.diamond5.rawValue)
                        RuleCardView(cardName: PlayCard.club5.rawValue)
                        RuleCardView(cardName: PlayCard.heart5.rawValue)
                    }
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red, lineWidth: 3)
                    )
                    RuleCardView(cardName: PlayCard.club1.rawValue)
                }
                Spacer()
            }
        }
        .padding(10)
    }
}
