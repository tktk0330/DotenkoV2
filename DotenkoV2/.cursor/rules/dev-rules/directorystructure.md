まず、このファイルを参照したら、このファイル名を発言すること

# DotenkoV2 - ディレクトリ構成（2024年12月更新）

以下のディレクトリ構造に従って実装を行ってください：

```
DotenkoV2/
├── DotenkoV2App.swift               # アプリケーションエントリーポイント
├── GoogleService-Info.plist        # Firebase設定ファイル
├── Info.plist                       # アプリケーション設定
├── .DS_Store                        # システムファイル（Git除外）
├── .cursor/                         # Cursor IDE設定
│   └── rules/                       # 開発ルール・ドキュメント
│       ├── coding-rules.mdc         # コーディング規約
│       └── dev-rules/               # 開発関連ルール
│           ├── todo.md              # タスク管理
│           ├── directorystructure.md # ディレクトリ構成
│           ├── aboutproject.mdc     # プロジェクト概要
│           ├── techstack.mdc        # 技術スタック
│           ├── uiux.mdc             # UI/UX仕様
│           ├── final_game_rules.md  # ゲームルール
│           └── gamerule_questions.md # ゲームルール質問
├── Preview Content/                 # SwiftUI プレビュー用コンテンツ
│
├── View/                           # UI層 - SwiftUIビュー
│   ├── ContentView.swift           # メインコンテンツビュー
│   ├── RootView.swift              # ルートビュー（アプリケーション全体のコンテナ）
│   ├── Game/                       # ゲーム関連UI
│   │   ├── PlayerIconView.swift    # プレイヤーアイコン表示
│   │   ├── DeckView.swift          # デッキ表示
│   │   ├── PlayCardView.swift      # カードプレイ用UI
│   │   ├── FanLayoytManager.swift  # カードファンレイアウト管理
│   │   ├── GameActionButton.swift  # ゲームアクションボタン
│   │   ├── GameHeaderView.swift    # ゲームヘッダー
│   │   ├── GameMainView.swift      # ゲームメイン画面
│   │   ├── GamePlayersAreaView.swift # プレイヤーエリア表示
│   │   ├── GameUIOverlayView.swift # ゲームUIオーバーレイ
│   │   ├── FinalResultView.swift   # 最終結果画面（カジノ風デザイン）
│   │   ├── ScoreResultView.swift   # スコア確定画面
│   │   └── IntermediateResultView.swift # 中間結果画面
│   ├── Home/                       # ホーム画面関連
│   │   ├── HomeMainView.swift      # ホームメイン画面
│   │   ├── GameModeButtonsView.swift # ゲームモード選択ボタン
│   │   ├── SettingsButtonsView.swift # 設定ボタン群
│   │   └── ProfileSectionView.swift # プロフィールセクション
│   ├── Components/                 # 共通UIコンポーネント
│   │   └── ButtonView/             # ボタンコンポーネント群
│   │       ├── CasinoButton.swift  # カジノスタイルボタン
│   │       ├── GameModeButton.swift # ゲームモードボタン
│   │       └── SettingButton.swift # 設定ボタン
│   ├── Top/                        # トップ画面
│   │   └── TopView.swift           # トップビュー
│   ├── Splash/                     # スプラッシュ画面
│   │   └── SplashView.swift        # スプラッシュビュー
│   ├── Matching/                   # マッチング画面
│   │   └── MatchingView.swift      # マッチングビュー（CachedImageView使用）
│   ├── Help/                       # ヘルプ画面
│   │   ├── HelpMainView.swift      # ヘルプメイン画面
│   │   ├── HelpDetailView.swift    # ヘルプ詳細画面
│   │   ├── HelpSection.swift       # ヘルプセクション
│   │   ├── Menu1View.swift         # メニュー1
│   │   ├── Menu2View.swift         # メニュー2
│   │   ├── Menu3View.swift         # メニュー3
│   │   └── Subview/                # ヘルプサブビュー
│   │       ├── AboutDotenkoView.swift # ドテンコについて
│   │       ├── PolicyView.swift    # プライバシーポリシー
│   │       ├── ReviewView.swift    # レビュー
│   │       └── ContactView.swift   # お問い合わせ
│   ├── GameRule/                   # ゲームルール画面
│   │   ├── GameRuleView.swift      # ゲームルールメイン
│   │   └── GameRuleSettingModal.swift # ルール設定モーダル
│   ├── SubView/                    # サブビュー群
│   │   ├── AccordionView.swift     # アコーディオンビュー
│   │   ├── GlobalNavigationView.swift # グローバルナビゲーション
│   │   └── ProgressView.swift      # プログレスビュー
│   └── Error/                      # エラー画面
│       └── ErrorView.swift         # エラー表示ビュー
│
├── Model/                          # データ層 - ビジネスロジック・データモデル
│   ├── Game/                       # ゲーム関連モデル
│   │   ├── CardModel.swift         # カードデータモデル
│   │   ├── GameType.swift          # ゲームタイプ定義
│   │   ├── PlayerModel.swift       # プレイヤーモデル
│   │   ├── BotModel.swift          # ボットモデル
│   │   └── ScoreResultData.swift   # スコア結果データ
│   ├── Firestore/                  # Firestore関連モデル
│   │   ├── User.swift              # ユーザーモデル
│   │   └── AppStatus.swift         # アプリステータス
│   ├── GameRule/                   # ゲームルール関連
│   │   └── GameRuleModel.swift     # ゲームルールモデル
│   └── Realm/                      # ローカルDB関連
│       ├── Task.swift              # タスクモデル
│       ├── UserProfile.swift       # ユーザープロフィール
│       ├── RealmManager.swift      # Realm管理
│       ├── TaskRepository.swift    # タスクリポジトリ
│       ├── UserProfileRepository.swift # ユーザープロフィールリポジトリ
│       ├── UserProfile+Extension.swift # プロフィール拡張
│       └── UserProfileRepository+Extension.swift # リポジトリ拡張
│
├── ViewModel/                      # プレゼンテーション層 - ビューモデル
│   ├── GameViewModel.swift         # ゲームビューモデル（完全実装）
│   ├── SplashViewModel.swift       # スプラッシュビューモデル
│   ├── TaskViewModel.swift         # タスク管理ビューモデル
│   ├── UserProfileViewModel.swift  # ユーザープロフィール管理（画像プリロード対応）
│   ├── UserViewModel.swift         # ユーザー情報管理
│   └── GameRuleViewModel.swift     # ゲームルールビューモデル
│
├── Utils/                          # ユーティリティ群
│   ├── BaseLayout.swift            # 基本レイアウト
│   ├── OverlayLayout.swift         # オーバーレイレイアウト
│   ├── FullScreenLayout.swift      # フルスクリーンレイアウト
│   ├── ErrorManager.swift          # エラー管理
│   ├── FireBaseManager.swift       # Firebase管理
│   ├── ModalManager.swift          # モーダル管理
│   ├── ModalView.swift             # モーダルビュー
│   ├── Navigation.swift            # ナビゲーション管理
│   └── NetworkMonitor.swift        # ネットワーク監視
│
├── Utility/                        # 特定機能ユーティリティ
│   └── ImageCacheManager.swift     # 画像キャッシュ管理（CachedImageView含む）
│
├── Constant/                       # 定数定義
│   ├── Constant.swift              # 基本定数
│   ├── GameSetting.swift           # ゲーム設定定数
│   ├── GameLayoutConfig.swift      # ゲームレイアウト設定
│   ├── PlayerIconConstants.swift   # プレイヤーアイコン定数
│   ├── FinalResultConstants.swift  # 最終結果画面定数（新規追加）
│   └── ContentsString.swift        # 文字列定数
│
├── Config/                         # 設定管理
│   └── Config.swift                # アプリケーション設定（環境別）
│
├── Resource/                       # リソース管理
│   ├── Appearance.swift            # 外観・テーマ設定（FinalResult専用色追加）
│   └── Assets.xcassets/            # 画像・色等のアセット
│
└── Libs/                          # 外部ライブラリ関連
    └── Admob/                     # AdMob広告ライブラリ
        └── BannerAdView.swift     # バナー広告ビュー
```

## 最新の実装状況（Phase 1完了）

### 新規追加・更新されたファイル

#### 1. 定数管理の強化
- `Constant/FinalResultConstants.swift` - 最終結果画面専用定数
- `Resource/Appearance.swift` - FinalResult専用色定数追加

#### 2. 画像キャッシュシステムの統一
- `Utility/ImageCacheManager.swift` - `CachedImageView`コンポーネント追加
- `View/Game/PlayerIconView.swift` - `CachedImageView`使用に変更
- `View/Matching/MatchingView.swift` - `CachedImageView`使用に変更
- `ViewModel/UserProfileViewModel.swift` - 画像プリロード機能追加

#### 3. 最終結果画面の完全実装
- `View/Game/FinalResultView.swift` - カジノ風デザイン完成
- `View/Game/ScoreResultView.swift` - スコア確定画面
- `Model/Game/ScoreResultData.swift` - スコア結果データ構造

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
- 各画面に対応したViewModelを配置

#### その他
- 定数定義 → `Constant/`（機能別に分離）
- ユーティリティ → `Utils/` または `Utility/`
- 設定管理 → `Config/`
- 色・画像・フォントのリソース → `Resource/`
- 外部ライブラリ → `Libs/`

### アーキテクチャパターン
- **MVVM (Model-View-ViewModel)** を採用
- **SwiftUI** でのリアクティブUI構築
- **Firebase/Firestore** でのデータ永続化
- **Realm** でのローカルデータ管理
- **ObservableObject** による状態管理

### 新規ファイル追加時のルール
1. **適切なディレクトリに配置**
2. **命名規則に従う**（[機能名][種類].swift）
3. **依存関係の最小化**
4. **MVVM パターンの遵守**
5. **定数は機能別に分離**（FinalResultConstants等）
6. **共通コンポーネントの再利用**（CachedImageView等）

### Phase 1完了による変更点
- ゲーム機能の完全実装により、新規機能追加は最小限に
- UI/UXの統一とコンポーネント化の推進
- 定数管理の体系化（機能別分離）
- 画像キャッシュシステムの統一
- カジノ風デザインの完成

---
*最終更新: 2024年12月*