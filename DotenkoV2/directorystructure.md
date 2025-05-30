# DotenkoV2 - ディレクトリ構成

以下のディレクトリ構造に従って実装を行ってください：

```
DotenkoV2/
├── DotenkoV2App.swift               # アプリケーションエントリーポイント
├── GoogleService-Info.plist        # Firebase設定ファイル
├── Info.plist                       # アプリケーション設定
├── directorystructure.md           # このファイル（ディレクトリ構成説明）
├── .cursor/                         # Cursor IDE設定
├── Preview Content/                 # SwiftUI プレビュー用コンテンツ
│
├── View/                           # UI層 - SwiftUIビュー
│   ├── ContentView.swift           # メインコンテンツビュー
│   ├── RootView.swift              # ルートビュー
│   ├── Game/                       # ゲーム関連UI
│   │   ├── PlayerIconView.swift    # プレイヤーアイコン表示
│   │   ├── DeckView.swift          # デッキ表示
│   │   ├── FanLayoytManager.swift  # カードファンレイアウト管理
│   │   ├── GameActionButton.swift  # ゲームアクションボタン
│   │   ├── GameHeaderView.swift    # ゲームヘッダー
│   │   ├── GameMainView.swift      # ゲームメイン画面
│   │   ├── GamePlayersAreaView.swift # プレイヤーエリア表示
│   │   ├── GameUIOverlayView.swift # ゲームUIオーバーレイ
│   │   ├── GameViewModel.swift     # ゲームビューモデル
│   │   └── PalyerLayoutConfig.swift # プレイヤーレイアウト設定
│   ├── Home/                       # ホーム画面関連
│   │   ├── HomeMainView.swift      # ホームメイン画面
│   │   ├── GameModeButtonsView.swift # ゲームモード選択ボタン
│   │   ├── SettingsButtonsView.swift # 設定ボタン群
│   │   └── ProfileSectionView.swift # プロフィールセクション
│   ├── Components/                 # 共通UIコンポーネント
│   │   └── ButtonView/
│   ├── Top/                        # トップ画面
│   ├── Splash/                     # スプラッシュ画面
│   ├── Matching/                   # マッチング画面
│   ├── Help/                       # ヘルプ画面
│   ├── GameRule/                   # ゲームルール画面
│   ├── SubView/                    # サブビュー群
│   └── Error/                      # エラー画面
│
├── Model/                          # データ層 - ビジネスロジック・データモデル
│   ├── Game/                       # ゲーム関連モデル
│   │   ├── CardModel.swift         # カードデータモデル
│   │   ├── GameType.swift          # ゲームタイプ定義
│   │   ├── PlayerModel.swift       # プレイヤーモデル
│   │   └── BotModel.swift          # ボットモデル
│   ├── Firestore/                  # Firestore関連モデル
│   │   ├── User.swift              # ユーザーモデル
│   │   └── AppStatus.swift         # アプリステータス
│   ├── GameRule/                   # ゲームルール関連
│   └── Realm/                      # ローカルDB関連
│
├── ViewModel/                      # プレゼンテーション層 - ビューモデル
│   ├── TaskViewModel.swift         # タスク管理
│   ├── UserProfileViewModel.swift  # ユーザープロフィール管理
│   └── UserViewModel.swift         # ユーザー情報管理
│
├── Utils/                          # ユーティリティ群
│   ├── BaseLayout.swift            # 基本レイアウト
│   ├── OverlayLayout.swift         # オーバーレイレイアウト
│   ├── FullScreenLayout.swift      # フルスクリーンレイアウト
│   ├── ErrorManager.swift          # エラー管理
│   ├── FireBaseManager.swift       # Firebase管理
│   ├── ModalManager.swift          # モーダル管理
│   ├── ModalView.swift            # モーダルビュー
│   ├── Navigation.swift           # ナビゲーション管理
│   └── NetworkMonitor.swift       # ネットワーク監視
│
├── Utility/                        # 特定機能ユーティリティ
│   └── ImageCacheManager.swift     # 画像キャッシュ管理
│
├── Constant/                       # 定数定義
│   ├── Constant.swift              # 基本定数
│   ├── GameSetting.swift           # ゲーム設定定数
│   └── ContentsString.swift        # 文字列定数
│
├── Config/                         # 設定管理
│   └── Config.swift                # アプリケーション設定
│
├── Resource/                       # リソース管理
│   ├── Appearance.swift            # 外観・テーマ設定
│   └── Assets.xcassets/            # 画像・色等のアセット
│
└── Libs/                          # 外部ライブラリ関連
    └── Admob/                     # AdMob広告ライブラリ
```

### 配置ルール（SwiftUI + MVVM アーキテクチャ）

#### View層
- SwiftUIビュー → `View/[機能名]/`
- 共通UIコンポーネント → `View/Components/`
- レイアウト関連 → `Utils/[レイアウト名]Layout.swift`

#### Model層
- ゲームロジック → `Model/Game/`
- データモデル → `Model/[データソース名]/`
- ビジネスロジック → `Model/`

#### ViewModel層
- プレゼンテーションロジック → `ViewModel/`
- 状態管理 → `ViewModel/`

#### その他
- 定数定義 → `Constant/`
- ユーティリティ → `Utils/` または `Utility/`
- 設定管理 → `Config/`
- 色・画像・フォントのリソース → `Resource/`
- 外部ライブラリ → `Libs/`

### アーキテクチャパターン
- **MVVM (Model-View-ViewModel)** を採用
- **SwiftUI** でのリアクティブUI構築
- **Firebase/Firestore** でのデータ永続化
- **Realm** でのローカルデータ管理