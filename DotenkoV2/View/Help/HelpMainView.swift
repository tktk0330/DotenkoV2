import SwiftUI

struct HelpMainView: View {
    @EnvironmentObject private var navigator: NavigationStateManager
    @StateObject private var modalManager = ModalManager.shared
    
    var body: some View {
        ZStack {
            BaseLayout {
                VStack(spacing: 20) {
                    Text("Help")
                        .font(.title)
                        .padding(.top, 20)
                    
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
                                            .foregroundColor(.gray)
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
                        modalManager.show {
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
        .modalOverlay()
    }
}

// ヘルプセクション
enum HelpSection: CaseIterable {
    case howTo
    case faq
    case contact
    case terms
    case privacy
    
    var title: String {
        switch self {
        case .howTo: return "使い方ガイド"
        case .faq: return "よくある質問"
        case .contact: return "お問い合わせ"
        case .terms: return "利用規約"
        case .privacy: return "プライバシーポリシー"
        }
    }
    
    var description: String {
        switch self {
        case .howTo: return "アプリの基本的な使い方や機能の説明を確認できます。"
        case .faq: return "ユーザーからよく寄せられる質問とその回答を確認できます。"
        case .contact: return "サポートチームへの問い合わせ方法を確認できます。"
        case .terms: return "本アプリの利用規約を確認できます。"
        case .privacy: return "個人情報の取り扱いについて確認できます。"
        }
    }
    
    var items: [HelpItem] {
        switch self {
        case .howTo:
            return [
                HelpItem(title: "基本操作について", icon: "hand.tap"),
                HelpItem(title: "機能の使い方", icon: "gear"),
                HelpItem(title: "便利な使い方", icon: "star")
            ]
        case .faq:
            return [
                HelpItem(title: "アカウントについて", icon: "person"),
                HelpItem(title: "支払いについて", icon: "creditcard"),
                HelpItem(title: "技術的な問題", icon: "wrench")
            ]
        case .contact:
            return [
                HelpItem(title: "メールでのお問い合わせ", icon: "envelope"),
                HelpItem(title: "チャットサポート", icon: "message"),
                HelpItem(title: "電話でのお問い合わせ", icon: "phone")
            ]
        case .terms:
            return [
                HelpItem(title: "利用規約", icon: "doc.text"),
                HelpItem(title: "特定商取引法", icon: "cart"),
                HelpItem(title: "その他の規約", icon: "doc")
            ]
        case .privacy:
            return [
                HelpItem(title: "プライバシーポリシー", icon: "lock.shield"),
                HelpItem(title: "個人情報の取り扱い", icon: "person.badge.shield.checkmark"),
                HelpItem(title: "Cookie設定", icon: "gearshape")
            ]
        }
    }
}

struct HelpItem: Hashable {
    let title: String
    let icon: String
}
