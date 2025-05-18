import SwiftUI

struct ProfileMainView: View {
    var body: some View {
        BaseLayout {
            VStack(spacing: 20) {
                Text("マイページ")
                    .font(.title)
                    .padding(.top, 20)
                
                // プロフィール情報
                ForEach(ProfileSection.allCases, id: \.self) { section in
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
                
                NavigationLink(destination: ProfileDetailView()) {
                    Text("プロフィール詳細")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical)
            }
            .padding(.horizontal)
        }
    }
}

// プロフィールセクション
enum ProfileSection: CaseIterable {
    case basic
    case settings
    case notification
    case security
    case help
    
    var title: String {
        switch self {
        case .basic: return "基本情報"
        case .settings: return "設定"
        case .notification: return "通知"
        case .security: return "セキュリティ"
        case .help: return "ヘルプ"
        }
    }
    
    var description: String {
        switch self {
        case .basic: return "ユーザー名、メールアドレス、プロフィール画像などの基本的な情報を管理します。"
        case .settings: return "アプリの基本設定、表示設定、言語設定などをカスタマイズできます。"
        case .notification: return "プッシュ通知、メール通知などの設定を管理します。"
        case .security: return "パスワード、二段階認証などのセキュリティ設定を行います。"
        case .help: return "よくある質問、お問い合わせ、利用規約などのサポート情報を確認できます。"
        }
    }
    
    var items: [ProfileItem] {
        switch self {
        case .basic:
            return [
                ProfileItem(title: "プロフィール編集", icon: "person.circle"),
                ProfileItem(title: "アカウント情報", icon: "person.text.rectangle"),
                ProfileItem(title: "メールアドレス変更", icon: "envelope")
            ]
        case .settings:
            return [
                ProfileItem(title: "一般設定", icon: "gearshape"),
                ProfileItem(title: "表示設定", icon: "display"),
                ProfileItem(title: "言語設定", icon: "globe")
            ]
        case .notification:
            return [
                ProfileItem(title: "プッシュ通知", icon: "bell"),
                ProfileItem(title: "メール通知", icon: "envelope"),
                ProfileItem(title: "通知履歴", icon: "clock")
            ]
        case .security:
            return [
                ProfileItem(title: "パスワード変更", icon: "lock"),
                ProfileItem(title: "二段階認証", icon: "shield"),
                ProfileItem(title: "セキュリティ履歴", icon: "list.bullet.clipboard")
            ]
        case .help:
            return [
                ProfileItem(title: "よくある質問", icon: "questionmark.circle"),
                ProfileItem(title: "お問い合わせ", icon: "envelope"),
                ProfileItem(title: "利用規約", icon: "doc.text")
            ]
        }
    }
}

struct ProfileItem: Hashable {
    let title: String
    let icon: String
}

// 詳細画面
struct ProfileDetailView: View {
    var body: some View {
        VStack {
            Text("Profile Detail")
                .font(.title)
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

