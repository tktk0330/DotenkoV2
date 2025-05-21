import SwiftUI

struct HelpMainView: View {
    @EnvironmentObject private var navigator: NavigationStateManager
    
    var body: some View {
        ZStack {
            BaseLayout {
                VStack(spacing: 20) {
                    Spacer().frame(height: 24)
                    
                    // ヘルプセクション
                    ForEach(HelpSection.allCases, id: \.self) { section in
                        AccordionView(title: section.title) {
                            VStack(alignment: .leading, spacing: 15) {
                                Text(section.description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                ForEach(section.items, id: \.self) { item in
                                    HStack(spacing: 15) {
                                        Image(systemName: item.icon)
                                            .foregroundColor(.blue)
                                            .frame(width: 20)
                                        
                                        Text(item.title)
                                            .font(.body)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white)
                                            .font(.system(size: 14))
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                            .padding(.leading, 10)
                        }
                    }
                    
                    // MENU1への遷移ボタン
                    Button(action: {
                        navigator.push(Menu1View())
                    }) {
                        Text("MENU 1を開く")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // MENU2のモーダル表示ボタン
                    Button(action: {
                        ModalManager.shared.show {
                            Menu2View()
                        }
                    }) {
                        Text("MENU 2を開く")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// ヘルプセクション
enum HelpSection: CaseIterable {
    case basicRule
    case customRule
    case contact
    case review
    case privacy
    
    var title: String {
        switch self {
        case .basicRule: return "基本ルール"
        case .customRule: return "カスタムルール"
        case .contact: return "お問い合わせ"
        case .review: return "アプリレビュー"
        case .privacy: return "プライバシーポリシー・利用規約"
        }
    }
    
    var description: String {
        switch self {
        case .basicRule: return "アプリの基本的な使い方や機能の説明を確認できます。"
        case .customRule: return "ユーザーからよく寄せられる質問とその回答を確認できます。"
        case .contact: return "サポートチームへの問い合わせ方法を確認できます。"
        case .review: return "よろしければ評価・ご意見・感想等をお願いいたします。"
        case .privacy: return "本アプリのプライバシーポリシー・利用規約を確認できます。"
        }
    }
    
    var items: [HelpItem] {
        switch self {
        case .basicRule:
            return [
                HelpItem(title: "概要", icon: "hand.tap"),
                HelpItem(title: "ゲームイベント", icon: "gear"),
                HelpItem(title: "カードの効果", icon: "star")
            ]
        case .customRule:
            return [
                HelpItem(title: "ゲーム数 / Game", icon: "person"),
                HelpItem(title: "ジョーカー枚数 / Joker", icon: "creditcard"),
                HelpItem(title: "レート / Rate", icon: "person"),
                HelpItem(title: "重ねレートアップ / UpRate", icon: "person"),
                HelpItem(title: "スコア上限 / Max", icon: "creditcard"),
                HelpItem(title: "デッキサイクル / Deck", icon: "wrench")
            ]
        case .contact:
            return [
                HelpItem(title: "お問い合わせ", icon: "phone")
            ]
        case .review:
            return [
                HelpItem(title: "レビュー", icon: "doc")
            ]
        case .privacy:
            return [
                HelpItem(title: "プライバシーポリシー", icon: "lock.shield"),
                HelpItem(title: "利用規約", icon: "person.badge.shield.checkmark"),
            ]
        }
    }
}

struct HelpItem: Hashable {
    let title: String
    let icon: String
}
