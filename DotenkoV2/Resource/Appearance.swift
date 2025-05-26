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
        
        // カジノ風グラデーション
        static let casinoGradient = CasinoGradient()
        
        struct CasinoGradient {
            let background = [
                UIColor(red: 0/255, green: 29/255, blue: 11/255, alpha: 1),    // 深緑
                UIColor(red: 0/255, green: 45/255, blue: 20/255, alpha: 1),    // 中間の緑
                UIColor(red: 0/255, green: 35/255, blue: 15/255, alpha: 1)     // やや明るい緑
            ]
            
            let button = ButtonGradient()
            
            struct ButtonGradient {
                let main = [
                    UIColor(red: 0/255, green: 100/255, blue: 0/255, alpha: 1),
                    UIColor(red: 0/255, green: 70/255, blue: 0/255, alpha: 1)
                ]
                
                let accent = [
                    UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 0.3),
                    UIColor(red: 218/255, green: 165/255, blue: 32/255, alpha: 0.1)
                ]
                
                let border = [
                    UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1),
                    UIColor(red: 218/255, green: 165/255, blue: 32/255, alpha: 1)
                ]
            }
        }
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
        
        struct Splash {
            static let splashLogo = "image_card_back_red"
        }
        
        struct Top {
            static let topLogo = "image_logo"
            static let topIcon = "image_icon"
        }
        
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
        
        struct BotIcon {
            static let bot1 = "botIcon01"
            static let bot2 = "botIcon02"
            static let bot3 = "botIcon03"
            static let bot4 = "botIcon04"
            static let bot5 = "botIcon05"
            static let bot6 = "botIcon06"
            static let bot7 = "botIcon07"
            static let bot8 = "botIcon08"
            static let bot9 = "botIcon09"
        }
    }
}

