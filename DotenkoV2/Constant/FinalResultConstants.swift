import SwiftUI

// MARK: - Final Result View Constants
struct FinalResultConstants {
    struct Layout {
        static let horizontalPadding: CGFloat = 16
        static let topPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 100
        static let sectionSpacing: CGFloat = 16
        static let titleSpacing: CGFloat = 8
        static let rankingSpacing: CGFloat = 8
        static let rankingHorizontalPadding: CGFloat = 8
    }
    
    struct Typography {
        static let titleSize: CGFloat = 28
        static let homeButtonSize: CGFloat = 20
        static let casinoTitleSize: CGFloat = 28
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
        static let dividerMaxWidth: CGFloat = 180
        static let homeButtonHeight: CGFloat = 50
        static let homeButtonCornerRadius: CGFloat = 16
        static let homeButtonHorizontalPadding: CGFloat = 24
        static let homeButtonTopPadding: CGFloat = 12
        static let homeButtonSpacing: CGFloat = 8
        static let shadowRadius: CGFloat = 6
        static let shadowOffset: CGFloat = 3
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
        static let cardSpacing: CGFloat = 8
        static let headerSpacing: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let scoreRightPadding: CGFloat = 20  // スコアの右寄せ用
    }
    
    struct Typography {
        static let rankSize: CGFloat = 22
        static let nameSize: CGFloat = 16
        static let scoreSize: CGFloat = 24  // カジノ風に大きく
        static let iconTextSize: CGFloat = 14
        static let casinoScoreSize: CGFloat = 28  // さらに大きなスコア表示
    }
    
    struct Dimensions {
        static let rankWidth: CGFloat = 32
        static let iconSize: CGFloat = 40
        static let iconImageSize: CGFloat = 36  // アイコン画像を大きく（35→46）
        static let iconBorderWidth: CGFloat = 2
        static let cardCornerRadius: CGFloat = 10
        static let cardBorderWidth: CGFloat = 1.5
        static let shadowRadius: CGFloat = 3
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
