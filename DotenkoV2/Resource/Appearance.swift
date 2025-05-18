import SwiftUI

enum Appearance {
    struct Color {
        static let autoBlack = UIColor(named: "AutoBlack")
        static let blueBerryBlue = UIColor(named: "BlueBerryBlue")
        static let candyAppleRed = UIColor(named: "CandyAppleRed")
        static let lemonYellow = UIColor(named: "LemonYellow")
        static let chocolateBlack = UIColor(named: "ChocolateBlack")
        static let darkGreen = UIColor(named: "DarkGreen")
        static let lightGreen = UIColor(named: "LightGreen")
        /// 深い森のような緑色 (R: 0.0, G: 0.25, B: 0.15) - 自然や環境関連の要素に使用
        static let forestGreen = UIColor(red: 0.0, green: 0.25, blue: 0.15, alpha: 1.0)
        /// 深いモスグリーン (R: 0.0, G: 0.2, B: 0.12) - 背景やナビゲーションの基調色として使用
        static let mossGreen = UIColor(red: 0.0, green: 0.2, blue: 0.12, alpha: 1.0)
        /// 明るい黄金色 (R: 1.0, G: 0.85, B: 0.4) - 選択状態やハイライトとして使用
        static let goldenYellow = UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0)
    }
    
    struct Font {
        /// メインタイトル用の太く大きなフォント - アプリ名やメインの見出しに使用
        static let title: UIFont = .systemFont(ofSize: 32, weight: .heavy)
        
        /// カジノスタイルの装飾的な大見出し - 勝利画面や重要な通知に使用
        static let casinoDisplay: UIFont = .systemFont(ofSize: 36, weight: .black)
        
        /// カジノスタイルの中見出し - セクションタイトルやメニュー項目に使用
        static let casinoHeading: UIFont = .systemFont(ofSize: 24, weight: .bold)
        
        /// 数字表示用の等幅フォント - スコアやポイント表示に使用
        static let score: UIFont = .monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        
        /// メニュー項目用の中サイズフォント - ナビゲーションやボタンに使用
        static let menuItem: UIFont = .systemFont(ofSize: 16, weight: .medium)
        
        /// 説明文用の標準フォント - 通常のテキストに使用
        static let body: UIFont = .systemFont(ofSize: 14, weight: .regular)
        
        /// 小さな注釈用フォント - 補足情報やキャプションに使用
        static let caption: UIFont = .systemFont(ofSize: 12, weight: .regular)
        
        /// ナビゲーション用の小さめフォント - タブバーなどに使用
        static let navigation: UIFont = .systemFont(ofSize: 10, weight: .medium)
    }
    
    struct Image {
        /// アプリ共通のアイコンやロゴ
        struct Common {
            /// アプリのメインロゴ
            static let logo = UIImage(named: "DOTENKO")
            /// プロフィールアイコン
            static let profileIcon = UIImage(named: "ProfileIcon")
        }

        /// ゲームモード関連の画像
        struct GameMode {
            /// 個人戦ボタンの背景
            static let singlePlayButton = UIImage(named: "SinglePlayButton")
            /// 友人戦ボタンの背景
            static let friendPlayButton = UIImage(named: "FriendPlayButton")
        }

        /// カードゲーム関連の画像
        struct Cards {
            /// スペードのエース
            static let aceSpade = UIImage(systemName: "suit.spade.fill")
            /// キングのカード
            static let kingCard = UIImage(named: "KingCard")
            /// カードの装飾
            static let cardDecoration = UIImage(named: "CardDecoration")
        }
    }
}

