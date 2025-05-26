import SwiftUI

class BotPlayer: Identifiable {
    let id: String
    var name: String
    var icon_url: String
    
    init(id: String, name: String, icon_url: String) {
        self.id = id
        self.name = name
        self.icon_url = icon_url
    }
}

struct BotPlayerList {
    func getBotPlayer() -> [BotPlayer] {
        return [
            .init(id: "bot-1", name: "Liam", icon_url: Appearance.Image.BotIcon.bot1),
            .init(id: "bot-2", name: "Olivia", icon_url: Appearance.Image.BotIcon.bot2),
            .init(id: "bot-3", name: "Lucas", icon_url: Appearance.Image.BotIcon.bot3),
            .init(id: "bot-4", name: "Emma", icon_url: Appearance.Image.BotIcon.bot4),
            .init(id: "bot-5", name: "Harry", icon_url: Appearance.Image.BotIcon.bot5),
            .init(id: "bot-6", name: "Alice", icon_url: Appearance.Image.BotIcon.bot6),
            .init(id: "bot-7", name: "Lily", icon_url: Appearance.Image.BotIcon.bot7),
            .init(id: "bot-8", name: "Jack", icon_url: Appearance.Image.BotIcon.bot8),
            .init(id: "bot-9", name: "Cris", icon_url: Appearance.Image.BotIcon.bot9),
        ]
    }
}
