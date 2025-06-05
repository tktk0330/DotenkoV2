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
        
        // PlayerIcon関連の色定義
        /// プレイヤーアイコンの金色 (R: 1.0, G: 0.84, B: 0.0) - メインプレイヤーのハイライトに使用
        static let playerGold = SwiftUI.Color(red: 1.0, green: 0.84, blue: 0.0)
        /// プレイヤーアイコンの暗い金色 (R: 0.8, G: 0.6, B: 0.0) - グラデーション効果に使用
        static let playerDarkGold = SwiftUI.Color(red: 0.8, green: 0.6, blue: 0.0)
        /// プレイヤーアイコンの暗い背景色 (R: 0.1, G: 0.1, B: 0.1) - スコア表示の背景に使用
        static let playerDarkBackground = SwiftUI.Color(red: 0.1, green: 0.1, blue: 0.1)
        /// プレイヤーアイコンの中間背景色 (R: 0.2, G: 0.2, B: 0.2) - グラデーション効果に使用
        static let playerMediumBackground = SwiftUI.Color(red: 0.2, green: 0.2, blue: 0.2)
        
        // 共通で使用される基本色
        /// 汎用白色 - テキストや境界線に使用
        static let commonWhite = SwiftUI.Color.white
        /// 汎用黒色 - 背景や影に使用
        static let commonBlack = SwiftUI.Color.black
        /// 汎用グレー - セカンダリテキストや無効状態に使用
        static let commonGray = SwiftUI.Color.gray
        /// 汎用赤色 - エラーや警告に使用
        static let commonRed = SwiftUI.Color.red
        /// 汎用青色 - リンクやアクセントに使用
        static let commonBlue = SwiftUI.Color.blue
        /// 汎用緑色 - 成功や承認に使用
        static let commonGreen = SwiftUI.Color.green
        /// 汎用黄色 - 注意や強調に使用
        static let commonYellow = SwiftUI.Color.yellow
        /// 汎用オレンジ色 - 警告やアクセントに使用
        static let commonOrange = SwiftUI.Color.orange
        /// 汎用透明色 - 透明背景に使用
        static let commonClear = SwiftUI.Color.clear
        
        // UI特殊色
        /// 設定ボタンの有効状態色 - 深い緑色
        static let settingActiveGreen = SwiftUI.Color(red: 32/255, green: 64/255, blue: 32/255)
        
        // ゲームアクションボタン色
        /// パスボタンの背景色 - 赤色
        static let passButtonBackground = SwiftUI.Color(red: 0.8, green: 0.2, blue: 0.2)
        /// プレイボタンの背景色 - 緑色
        static let playButtonBackground = SwiftUI.Color(red: 0.2, green: 0.6, blue: 0.2)
        
        // どてんこ宣言ボタン色
        /// どてんこボタンの背景色 - 鮮やかな紫色
        static let dotenkoButtonBackground = SwiftUI.Color(red: 0.6, green: 0.2, blue: 0.8)
        /// どてんこボタンのアクセント色 - 明るい紫色
        static let dotenkoButtonAccent = SwiftUI.Color(red: 0.8, green: 0.4, blue: 1.0)
        
        // GameHeader専用色
        /// エメラルドグリーン - レート表示に使用
        static let emeraldGreen = SwiftUI.Color(red: 0.0, green: 0.8, blue: 0.4)
        /// ヘッダー背景の暗い緑
        static let headerDarkGreen = SwiftUI.Color(red: 0.05, green: 0.15, blue: 0.05)
        /// ヘッダー背景の中間緑
        static let headerMediumGreen = SwiftUI.Color(red: 0.1, green: 0.25, blue: 0.1)
        /// UP表示の暗い茶色背景
        static let upDisplayDarkBrown = SwiftUI.Color(red: 0.2, green: 0.1, blue: 0.0)
        /// UP表示の明るい茶色背景
        static let upDisplayLightBrown = SwiftUI.Color(red: 0.4, green: 0.2, blue: 0.0)
        
        // FinalResult専用色
        /// 1位ゴールド色
        static let rankGold = SwiftUI.Color(red: 1.0, green: 0.84, blue: 0.0)
        /// 2位シルバー色
        static let rankSilver = SwiftUI.Color(red: 0.75, green: 0.75, blue: 0.75)
        /// 3位ブロンズ色
        static let rankBronze = SwiftUI.Color(red: 0.8, green: 0.5, blue: 0.2)
        /// 4位以下グレー色
        static let rankGray = SwiftUI.Color(red: 0.5, green: 0.5, blue: 0.5)
        /// 背景の黒色（透明度付き）
        static let finalResultBackground = SwiftUI.Color.black
        /// タイトル区切り線の金色
        static let finalResultDivider = SwiftUI.Color(red: 1.0, green: 0.84, blue: 0.0)
        /// ホームボタンの金色グラデーション
        static let homeButtonGold = SwiftUI.Color(red: 1.0, green: 0.84, blue: 0.0)
        /// ホームボタンの暗い金色
        static let homeButtonDarkGold = SwiftUI.Color(red: 0.8, green: 0.6, blue: 0.0)
        /// 影の色
        static let finalResultShadow = SwiftUI.Color.black
        
        // 背景色グラデーション
        /// メイン背景グラデーション - カジノ風の深緑グラデーション
        static let mainBackgroundGradient = [
            SwiftUI.Color(red: 0/255, green: 29/255, blue: 11/255),    // 深緑
            SwiftUI.Color(red: 0/255, green: 45/255, blue: 20/255),    // 中間の緑
            SwiftUI.Color(red: 0/255, green: 35/255, blue: 15/255)     // やや明るい緑
        ]
        
        /// オーバーレイ用白色グラデーション
        static let overlayWhiteGradient = [
            SwiftUI.Color.white.opacity(0.1),
            SwiftUI.Color.clear
        ]
        
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
    
    struct Icon {
        // ナビゲーション関連
        /// 戻るボタン用シェブロン
        static let chevronLeft = "chevron.left"
        /// 右向きシェブロン
        static let chevronRight = "chevron.right"
        /// 上向きシェブロン
        static let chevronUp = "chevron.up"
        /// 下向きシェブロン
        static let chevronDown = "chevron.down"
        /// 閉じるボタン用X印
        static let xmark = "xmark"
        
        // ユーザー関連
        /// デフォルトプロフィールアイコン
        static let personFill = "person.fill"
        /// 編集用鉛筆アイコン
        static let pencilCircleFill = "pencil.circle.fill"
        /// 確認用チェックマーク
        static let checkmarkCircleFill = "checkmark.circle.fill"
        /// キャンセル用Xマーク
        static let xmarkCircleFill = "xmark.circle.fill"
        
        // ゲーム関連
        /// パスボタン用下向き矢印
        static let arrowDownCircleFill = "arrow.down.circle.fill"
        /// プレイボタン用上向き矢印
        static let arrowUpCircleFill = "arrow.up.circle.fill"
        /// 設定用ギアアイコン
        static let gearshapeFill = "gearshape.fill"
        
        // エラー・警告関連
        /// エラー用三角警告アイコン
        static let exclamationmarkTriangleFill = "exclamationmark.triangle.fill"
    }
}

