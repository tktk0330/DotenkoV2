import SwiftUI

struct HelpItem: Hashable {
    let type: RuleDetail
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
                HelpItem(type: .aboutDotenko),
                HelpItem(type: .flow),
                HelpItem(type: .operation),
                HelpItem(type: .event),
                HelpItem(type: .card),
            ]
        case .customRule:
            return [
                HelpItem(type: .roundCount),
                HelpItem(type: .jokerCount),
                HelpItem(type: .gameRate),
                HelpItem(type: .maxScore),
                HelpItem(type: .upRate),
                HelpItem(type: .deckCycle),
            ]
        case .contact:
            return [
                HelpItem(type: .contact),
            ]
        case .review:
            return [
                HelpItem(type: .review),
            ]
        case .privacy:
            return [
                HelpItem(type: .privacyPoricy),
                HelpItem(type: .poricy),
            ]
        }
    }
}

enum RuleDetail {
    case aboutDotenko
    case flow
    case operation
    case event
    case card
    
    case roundCount
    case jokerCount
    case gameRate
    case upRate
    case maxScore
    case deckCycle
    
    case contact
    
    case review
    
    case privacyPoricy
    case poricy
    
    var title: String {
        switch self {
        case .aboutDotenko:
            "どてんことは"
        case .flow:
            "ゲームの流れ"
        case .operation:
            "カードの出し方"
        case .event:
            "イベント"
        case .card:
            "カードについて"
        case .roundCount:
            GameSetting.roundCount.title
        case .jokerCount:
            GameSetting.jokerCount.title
        case .gameRate:
            GameSetting.gameRate.title
        case .upRate:
            GameSetting.upRate.title
        case .maxScore:
            GameSetting.maxScore.title
        case .deckCycle:
            GameSetting.deckCycle.title
        case .contact:
            "お問い合わせ"
        case .review:
            "レビュー"
        case .privacyPoricy:
            "プライバシーポリシー"
        case .poricy:
            "利用規約"
        }
    }
    
    var icon: String {
        switch self {
        case .aboutDotenko:
            "hand.tap"
        case .flow:
            "hand.tap"
        case .operation:
            "hand.tap"
        case .event:
            "hand.tap"
        case .card:
            "hand.tap"
        case .roundCount:
            GameSetting.roundCount.icon
        case .jokerCount:
            GameSetting.jokerCount.icon
        case .gameRate:
            GameSetting.gameRate.icon
        case .upRate:
            GameSetting.upRate.icon
        case .maxScore:
            GameSetting.maxScore.icon
        case .deckCycle:
            GameSetting.deckCycle.icon
        case .contact:
            "hand.tap"
        case .review:
            "hand.tap"
        case .privacyPoricy:
            "hand.tap"
        case .poricy:
            "hand.tap"
        }
    }
}
