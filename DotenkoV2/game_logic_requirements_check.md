# DotenkoV2 - ゲームロジック要件すり合わせドキュメント

**作成日**: 2024年12月  
**目的**: どてんこ、しょてんこ、リベンジ、チャレンジゾーンのロジックや構成について、現在の実装と期待される要件の差異を特定し、要件をすり合わせる

---

## 📊 現在の実装状況

### 🎯 どてんこシステム

#### ✅ 実装済み機能
- **基本判定**: 場の一番上のカードと手札合計の一致判定 ✅
- **リアルタイム宣言**: ターン外でも宣言可能（早い者勝ち） ✅
- **UI制御**: 条件満たす時のみボタン表示 ✅
- **BOT対応**: 見逃しなしで自動宣言 ✅
- **勝敗設定**: どてんこした人が勝者、場のカードを出した人が敗者 ✅

#### ❌ 未実装・修正必要
- **自分のカード制限**: 自分が出したカードにはどてんこ不可 ❌
- **複数同時宣言**: 最後にどてんこした人が勝ち（現在は早い者勝ち） ❌

#### 🔍 実装詳細
```swift
// GameViewModel.swift - handleDotenkoDeclaration()
- 条件チェック: canPlayerDeclareDotenko()
- 状態更新: players[playerIndex].dtnk = true
- 勝者設定: revengeManager.setDotenkoWinnerId(playerId)
- 次フェーズ: revengeManager.startRevengeWaitingPhase()
```

---

### 🎊 しょてんこシステム

#### ✅ 実装済み機能
- **基本判定**: 最初の場札と手札合計の一致判定 ✅
- **勝敗設定**: しょてんこした人 vs その他全員 ✅
- **チャレンジゾーン**: しょてんこ後もチャレンジゾーン発生 ✅
- **BOT対応**: BOTが条件満たす場合は即座に宣言 ✅

#### ❌ 未実装・修正必要
- **手動宣言**: プレイヤーに対して自動実行しない（手動宣言のみ） ❌
- **デッキ限定**: デッキから出されたカードにのみ有効 ✅（実装済み）
- **ボタン切り替え**: カード出し後にしょてんこ→どてんこボタンに変化 ❌

#### 🔍 実装詳細
```swift
// GameViewModel.swift - checkShotenkoDeclarations()
- 判定タイミング: isFirstCardDealt && !fieldCards.isEmpty
- 条件チェック: handTotals.contains(fieldValue)
- BOT処理: 即座に宣言
- 人間処理: 3秒間ボタン表示 → 自動宣言
- 勝敗設定: しょてんこした人=勝者、その他=敗者
```

---

### 🔥 リベンジシステム

#### ✅ 実装済み機能
- **発生条件**: どてんこ宣言後、他にも条件を満たすプレイヤーがいる場合 ✅
- **連鎖対応**: 複数回のリベンジ可能 ✅
- **勝敗変更**: 最後にリベンジした人が勝者、前の勝者が敗者 ✅
- **BOT対応**: 条件満たせば必ず宣言（遅延あり） ✅

#### ❌ 未実装・修正必要
- **待機時間廃止**: 5秒待機を廃止し、即座にモーダル表示 ❌
- **参加モーダル**: チャレンジゾーン参加可否モーダルの実装 ❌
- **複数リベンジ**: 早い者勝ち処理（現在は遅延処理） ❌

#### 🔍 実装詳細
```swift
// GameRevengeManager.swift - startRevengeWaitingPhase()
- 待機時間: revengeCountdown = 5
- 対象特定: updateRevengeEligiblePlayers()
- タイマー: startRevengeTimer()
- BOTチェック: checkBotRevengeDeclarations()
- 連鎖処理: リベンジ後再度5秒待機
```

---

### 🎯 チャレンジゾーンシステム

#### ✅ 実装済み機能
- **発生条件**: 全プレイヤーのどてんこ宣言完了後 ✅
- **参加条件**: 手札合計 < 場のカード数字 ✅
- **進行順序**: どてんこした次の人から時計回り ✅
- **終了条件**: 参加者全員が条件を満たさなくなるまで ✅
- **手札制限**: チャレンジ中は手札無制限 ✅
- **ジョーカー**: 自動選択で最適化 ✅

#### ❌ 未実装・修正必要
- **参加モーダル**: 参加可否選択モーダル ❌
- **手札公開**: チャレンジゾーン参加者の手札公開 ❌
- **BOT応答遅延**: 1-3秒の応答遅延 ❌

#### 🔍 実装詳細
```swift
// GameRevengeManager.swift - startChallengeZone()
- 参加条件: minHandTotal < fieldValue
- 開始位置: (dotenkoWinnerIndex + 1) % players.count
- ターン処理: processChallengeZoneTurn()
- BOT行動: performBotChallengeAction()
- 終了判定: challengeParticipants.isEmpty
```

---

## ✅ 要件すり合わせ完了（ユーザー回答済み）

### 期待されるゲーム進行フロー
```
どてんこ宣言 → チャレンジゾーン参加モーダル → 勝者以外にチャレンジする人がいればチャレンジゾーン → スコア計算
```

### 確定した修正項目

#### 1. どてんこシステム修正
- **自分のカード制限**: 自分が出したカードにはどてんこ不可
- **複数同時宣言**: 早い者勝ち、最後にどてんこした人が勝ち
- **宣言タイミング**: 制限なし（いつでも宣言可能）

#### 2. しょてんこシステム修正
- **プレイヤー自動実行廃止**: 手動宣言のみ
- **デッキ限定**: デッキから出されたカードにのみ有効
- **ボタン切り替え**: カード出し後にしょてんこ→どてんこボタンに変化

#### 3. リベンジシステム修正
- **待機時間廃止**: 5秒待機を廃止
- **即座にモーダル**: どてんこアニメーション後に参加モーダル表示
- **複数リベンジ**: 早い者勝ち、先に押した人が適用

#### 4. チャレンジゾーン参加モーダル
- **全員表示**: 勝者以外の全プレイヤーに表示
- **ボタン種類**:
  - 通常: 「参加する」「参加しない」
  - リベンジ可能: 「リベンジ」「参加しない」
  - 勝敗絡み: 「参加する」のみ
- **BOT行動**: 問答無用で参加、リベンジ可能時は必ずリベンジ
- **タイムアウト**: 5秒、デフォルト「参加する」
- **待機表示**: ローディング表示

#### 5. 手札公開機能
- **公開対象**: チャレンジゾーン参加者のみ
- **公開範囲**: 開始時から追加カードまで全て
- **表示対象**: 全プレイヤーから見える

#### 6. BOT行動詳細
- **リベンジ優先**: リベンジ可能時は必ず「リベンジ」選択
- **通常参加**: 通常時は「参加する」選択
- **応答遅延**: 1-3秒のランダム遅延

---

## 📋 実装完了チェックリスト

### Phase 1: 基本ロジック修正
- [ ] 自分が出したカードにはどてんこ不可
- [ ] 複数同時宣言は最後の人が勝ち
- [ ] プレイヤーのしょてんこ自動実行廃止
- [ ] リベンジ5秒待機時間廃止

### Phase 2: UI/UX実装
- [ ] チャレンジゾーン参加モーダル実装
- [ ] 手札公開機能実装
- [ ] ボタン切り替え実装
- [ ] BOT応答遅延実装

### Phase 3: 詳細調整
- [ ] 参加条件を満たさないプレイヤーの処理
- [ ] チャレンジゾーン中のリベンジ不可制限
- [ ] エラーハンドリング強化

---

## 🔄 実装状況確認結果（2024年12月）

### 現在の実装状況
- **Phase 1完了**: BOT対戦機能100%実装済み
- **要件すり合わせ**: 完了、修正項目明確化
- **実装ギャップ**: 6つの主要修正項目特定

### 次のステップ
1. **Phase 1実装開始**: 基本ロジック修正
2. **段階的テスト**: 修正後の動作確認
3. **Phase 2実装**: UI/UX新機能追加

### 修正対象ファイル
- `ViewModel/GameViewModel.swift`
- `ViewModel/GameRevengeManager.swift`
- `ViewModel/BotManager.swift`
- `View/Game/GamePlayersAreaView.swift`
- 新規: `ChallengeZoneParticipationModal.swift`
- 新規: `HandRevealView.swift`

---

*最終更新: 2024年12月* 