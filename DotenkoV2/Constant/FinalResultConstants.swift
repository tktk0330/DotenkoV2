import SwiftUI

// MARK: - Final Result View Constants
struct FinalResultConstants {
    struct Layout {
        static let horizontalPadding: CGFloat = 20
        static let topPadding: CGFloat = 30
        static let bottomPadding: CGFloat = 120
        static let sectionSpacing: CGFloat = 25
        static let titleSpacing: CGFloat = 15
        static let rankingSpacing: CGFloat = 8
        static let rankingHorizontalPadding: CGFloat = 10
    }
    
    struct Typography {
        static let titleSize: CGFloat = 28
        static let homeButtonSize: CGFloat = 24
    }
    
    struct Colors {
        static let backgroundOpacity: Double = 0.95
        static let dividerOpacity: Double = 0.6
        static let goldOpacity: Double = 0.9
        static let goldSecondaryOpacity: Double = 0.7
        static let shadowOpacity: Double = 0.4
    }
    
    struct Dimensions {
        static let dividerHeight: CGFloat = 2
        static let dividerMaxWidth: CGFloat = 200
        static let homeButtonHeight: CGFloat = 70
        static let homeButtonCornerRadius: CGFloat = 20
        static let homeButtonHorizontalPadding: CGFloat = 30
        static let homeButtonTopPadding: CGFloat = 20
        static let homeButtonSpacing: CGFloat = 12
        static let shadowRadius: CGFloat = 8
        static let shadowOffset: CGFloat = 4
    }
    
    struct RankColors {
        static let colors: [Color] = [
            Appearance.Color.rankGold,      // 1位: ゴールド
            Appearance.Color.rankSilver,    // 2位: シルバー
            Appearance.Color.rankBronze,    // 3位: ブロンズ
            Appearance.Color.rankGray,      // 4位: グレー
            Appearance.Color.rankGray       // 5位: グレー
        ]
        static let fallbackColor: Color = Appearance.Color.rankGray
    }
}

// MARK: - Player Rank Card Constants
struct RankCardConstants {
    struct Layout {
        static let cardSpacing: CGFloat = 10
        static let headerSpacing: CGFloat = 15
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 12
    }
    
    struct Typography {
        static let rankSize: CGFloat = 28
        static let nameSize: CGFloat = 18
        static let scoreSize: CGFloat = 24
        static let iconTextSize: CGFloat = 18
    }
    
    struct Dimensions {
        static let rankWidth: CGFloat = 40
        static let iconSize: CGFloat = 50
        static let iconImageSize: CGFloat = 46  // アイコン画像を大きく（35→46）
        static let iconBorderWidth: CGFloat = 2
        static let cardCornerRadius: CGFloat = 12
        static let cardBorderWidth: CGFloat = 1.5
        static let shadowRadius: CGFloat = 4
        static let shadowOffset: CGFloat = 2
        static let firstPlaceScale: CGFloat = 1.02
        static let normalScale: CGFloat = 1.0
    }
    
    struct Colors {
        static let backgroundOpacity: Double = 0.15
        static let backgroundSecondaryOpacity: Double = 0.05
        static let borderOpacity: Double = 0.8
        static let borderSecondaryOpacity: Double = 0.4
        static let shadowOpacity: Double = 0.2
    }
    
    struct Animation {
        static let duration: Double = 0.3
    }
} 