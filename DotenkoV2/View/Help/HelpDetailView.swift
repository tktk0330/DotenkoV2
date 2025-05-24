import SwiftUI

// ヘルプ詳細ビュー
struct HelpDetailView: View {
    let detailType: RuleDetail
    
    var body: some View {
        BaseLayout {
            VStack(spacing: 16) {
                // アイコンとタイトル
                HStack(spacing: 12) {
                    Image(systemName: detailType.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    
                    Text(detailType.title)
                        .font(.headline)
                }
                .padding(.top, 24)
                
                // 説明文（仮のテキスト）
                switch detailType {
                case .aboutDotenko:
                    AboutDotenkoView()
                case .flow:
                    GameFlowView()
                case .operation:
                    GameOperationView()
                case .event:
                    GameEventView()
                case .card:
                    CardExplanationView()
                case .roundCount:
                    GameDetailRuleCommonView(type: .roundCount)
                case .jokerCount:
                    GameDetailRuleCommonView(type: .jokerCount)
                case .gameRate:
                    GameDetailRuleCommonView(type: .gameRate)
                case .upRate:
                    GameDetailRuleCommonView(type: .upRate)
                case .maxScore:
                    GameDetailRuleCommonView(type: .maxScore)
                case .deckCycle:
                    GameDetailRuleCommonView(type: .deckCycle)
                case .contact:
                    ContactView()
                case .review:
                    ReviewView()
                case .privacyPoricy:
                    PolicyView()
                case .poricy:
                    PolicyView()
                }
                
                Spacer()
                
                // 閉じるボタン
                Button(action: {
                    ModalManager.shared.dismiss()
                }) {
                    Text("閉じる")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.7)
    }
}
