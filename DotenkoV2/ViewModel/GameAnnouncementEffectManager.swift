import SwiftUI
import Foundation
import Combine

// MARK: - Game Announcement Effect Manager
/// アナウンス・エフェクトシステムを管理するクラス
/// GameViewModelから分離された独立したUI演出機能を提供
class GameAnnouncementEffectManager: ObservableObject {
    
    // MARK: - Published Properties
    
    // アナウンスシステム
    @Published var showAnnouncement: Bool = false
    @Published var announcementText: String = ""
    @Published var announcementSubText: String = ""
    @Published var isAnnouncementBlocking: Bool = false
    
    // どてんこロゴアニメーションシステム
    @Published var showDotenkoLogoAnimation: Bool = false
    @Published var dotenkoAnimationTitle: String = ""
    @Published var dotenkoAnimationSubtitle: String = ""
    @Published var dotenkoAnimationColorType: DotenkoAnimationType = .dotenko
    
    // レートアップエフェクトシステム（連続表示対応）
    @Published var showRateUpEffect: Bool = false
    @Published var rateUpMultiplier: Int = 1
    @Published var rateUpEffectId: UUID = UUID() // 連続アニメーション識別用
    
    // MARK: - Private Properties
    private var rateUpEffectTimer: Timer?
    private var animationCompletionExecuted: Bool = false // アニメーション完了コールバックの重複実行防止
    private var rateUpEffectQueue: [RateUpEffectRequest] = [] // 連続エフェクト管理用キュー
    private var isProcessingRateUpEffect: Bool = false // エフェクト処理中フラグ
    
    // MARK: - Rate Up Effect Request Model
    private struct RateUpEffectRequest {
        let multiplier: Int
        let id: UUID = UUID()
    }
    
    // MARK: - Lifecycle
    deinit {
        // タイマーのクリーンアップ
        rateUpEffectTimer?.invalidate()
        print("🎭 GameAnnouncementEffectManager解放")
    }
    
    // MARK: - Announcement System
    
    /// アナウンスを表示（右から流れて中央で停止して左に完全に流れ切る）
    /// - Parameters:
    ///   - title: メインタイトルテキスト
    ///   - subtitle: サブタイトルテキスト（オプション）
    ///   - completion: アニメーション完了後のコールバック
    func showAnnouncementMessage(title: String, subtitle: String = "", completion: (() -> Void)? = nil) {
        announcementText = title
        announcementSubText = subtitle
        isAnnouncementBlocking = true
        
        print("📢 アナウンス表示開始: \(title)")
        if !subtitle.isEmpty {
            print("   サブタイトル: \(subtitle)")
        }
        
        // アナウンス表示開始
        showAnnouncement = true
        
        // 総アニメーション時間を定数から取得
        // 構成: 開始遅延(0.1秒) + 右→中央(0.8秒) + 中央停止(1.5秒) + 中央→左(1.2秒) = 3.6秒
        let totalDuration = LayoutConstants.AnnouncementAnimation.totalDuration
        
        print("   総アニメーション時間: \(totalDuration)秒")
        print("   - 右→中央: \(LayoutConstants.AnnouncementAnimation.enteringDuration)秒")
        print("   - 中央停止: \(LayoutConstants.AnnouncementAnimation.stayingDuration)秒")
        print("   - 中央→左: \(LayoutConstants.AnnouncementAnimation.exitingDuration)秒")
        
        // アニメーション完了後に処理再開とコールバック実行
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            self.hideAnnouncement()
            completion?()
        }
    }
    
    /// アナウンスを非表示
    func hideAnnouncement() {
        showAnnouncement = false
        isAnnouncementBlocking = false
        announcementText = ""
        announcementSubText = ""
        print("📢 アナウンス表示終了")
    }
    
    /// アナウンスが表示中かチェック
    func isAnnouncementActive() -> Bool {
        return isAnnouncementBlocking
    }
    
    // MARK: - Rate Up Effect System（連続表示対応版）
    
    /// レートアップエフェクトを表示（連続表示対応）
    /// - Parameter multiplier: 現在の倍率
    func showRateUpEffect(multiplier: Int) {
        let request = RateUpEffectRequest(multiplier: multiplier)
        rateUpEffectQueue.append(request)
        
        print("📈 レートアップエフェクト要求追加: ×\(multiplier) (キュー数: \(rateUpEffectQueue.count))")
        
        // 現在処理中でなければ即座に処理開始
        if !isProcessingRateUpEffect {
            processNextRateUpEffect()
        }
    }
    
    /// 次のレートアップエフェクトを処理
    private func processNextRateUpEffect() {
        guard !rateUpEffectQueue.isEmpty else {
            isProcessingRateUpEffect = false
            print("📈 レートアップエフェクトキュー処理完了")
            return
        }
        
        isProcessingRateUpEffect = true
        let request = rateUpEffectQueue.removeFirst()
        
        print("📈 レートアップエフェクト処理開始: ×\(request.multiplier)")
        
        // 新しいエフェクトIDを生成してアニメーションを強制更新
        rateUpEffectId = UUID()
        rateUpMultiplier = request.multiplier
        showRateUpEffect = true
        
        // 既存のタイマーをキャンセル（新しいエフェクト用）
        rateUpEffectTimer?.invalidate()
        
        // エフェクト表示時間（3.0秒に短縮してパフォーマンス向上）
        let effectDuration: Double = 3.0
        
        // エフェクト終了タイマーを設定
        rateUpEffectTimer = Timer.scheduledTimer(withTimeInterval: effectDuration, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.completeCurrentRateUpEffect()
        }
    }
    
    /// 現在のレートアップエフェクトを完了し、次のエフェクトを処理
    private func completeCurrentRateUpEffect() {
        print("📈 レートアップエフェクト完了: ×\(rateUpMultiplier)")
        
        // エフェクトを非表示
        showRateUpEffect = false
        rateUpMultiplier = 1
        
        // タイマーをクリーンアップ
        rateUpEffectTimer?.invalidate()
        rateUpEffectTimer = nil
        
        // 短い間隔を置いて次のエフェクトを処理（連続表示の視認性向上）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.processNextRateUpEffect()
        }
    }
    
    /// レートアップエフェクトを非表示（外部からの強制終了用）
    func hideRateUpEffect() {
        rateUpEffectTimer?.invalidate()
        rateUpEffectTimer = nil
        showRateUpEffect = false
        rateUpMultiplier = 1
        rateUpEffectQueue.removeAll() // キューもクリア
        isProcessingRateUpEffect = false
        print("📈 レートアップエフェクト強制終了")
    }
    
    /// レートアップエフェクトが表示中かチェック
    func isRateUpEffectActive() -> Bool {
        return showRateUpEffect || !rateUpEffectQueue.isEmpty
    }
    
    // MARK: - Declaration Animation System
    
    /// 宣言アニメーションの種類
    enum DeclarationAnimationType {
        case dotenko    // どてんこ宣言
        case shotenko   // しょてんこ宣言
        case revenge    // リベンジ宣言
        case burst      // バースト宣言
        
        var title: String {
            switch self {
            case .dotenko: return "どてんこ！"
            case .shotenko: return "しょてんこ！"
            case .revenge: return "リベンジ！"
            case .burst: return "バースト！"
            }
        }
        
        var subtitle: String {
            switch self {
            case .dotenko: return "勝利宣言"
            case .shotenko: return "初手勝利"
            case .revenge: return "逆転宣言"
            case .burst: return "手札上限敗北"
            }
        }
        
        var colorType: DotenkoAnimationType {
            switch self {
            case .dotenko: return .dotenko
            case .shotenko: return .shotenko
            case .revenge: return .revenge
            case .burst: return .burst
            }
        }
    }
    
    /// 宣言アニメーションを表示（TOP画面ロゴアニメーション使用）
    /// - Parameters:
    ///   - type: 宣言の種類
    ///   - playerName: 宣言したプレイヤー名
    ///   - completion: アニメーション完了後のコールバック
    func showDeclarationAnimation(type: DeclarationAnimationType, playerName: String, completion: (() -> Void)? = nil) {
        let title = type.title
        let subtitle = "\(playerName) の\(type.subtitle)"
        
        print("🎊 宣言アニメーション開始: \(type) - プレイヤー: \(playerName)")
        
        // どてんこロゴアニメーションシステムを使用
        showDotenkoLogoAnimation(title: title, subtitle: subtitle, colorType: type.colorType, completion: completion)
    }
    
    /// どてんこロゴアニメーションを表示
    /// - Parameters:
    ///   - title: メインタイトル
    ///   - subtitle: サブタイトル
    ///   - colorType: アニメーションの色タイプ
    ///   - completion: アニメーション完了後のコールバック
    func showDotenkoLogoAnimation(title: String, subtitle: String, colorType: DotenkoAnimationType = .dotenko, completion: (() -> Void)? = nil) {
        dotenkoAnimationTitle = title
        dotenkoAnimationSubtitle = subtitle
        dotenkoAnimationColorType = colorType
        isAnnouncementBlocking = true
        animationCompletionExecuted = false // 重複実行防止フラグをリセット
        
        print("🎭 どてんこロゴアニメーション表示開始: \(title)")
        if !subtitle.isEmpty {
            print("   サブタイトル: \(subtitle)")
        }
        
        // アニメーション表示開始
        showDotenkoLogoAnimation = true
        
        // 総アニメーション時間（TOP画面と同じ）
        let totalDuration = DotenkoAnimationConfig.Logo.totalAnimationDuration
        
        print("   総アニメーション時間: \(totalDuration)秒")
        
        // アニメーション完了後に処理再開とコールバック実行
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            // 重複実行防止チェック
            guard !self.animationCompletionExecuted else {
                print("🎭 アニメーション完了コールバック重複実行防止")
                return
            }
            self.animationCompletionExecuted = true
            
            self.hideDotenkoLogoAnimation()
            completion?()
        }
    }
    
    /// どてんこロゴアニメーションを非表示
    func hideDotenkoLogoAnimation() {
        showDotenkoLogoAnimation = false
        isAnnouncementBlocking = false
        dotenkoAnimationTitle = ""
        dotenkoAnimationSubtitle = ""
        dotenkoAnimationColorType = .dotenko
        print("🎭 どてんこロゴアニメーション表示終了")
    }
    
    // MARK: - Special Card Effect System
    
    /// 特殊カード演出の種類
    enum SpecialCardEffectType {
        case multiplier50
        case diamond3
        case black3Reverse
        case heart3
    }
    
    /// 特殊カード演出を表示
    /// - Parameters:
    ///   - title: 演出タイトル
    ///   - subtitle: 演出サブタイトル
    ///   - effectType: 演出タイプ
    ///   - completion: 演出完了後のコールバック
    func showSpecialCardEffect(title: String, subtitle: String, effectType: SpecialCardEffectType, completion: @escaping () -> Void) {
        // 特殊カード演出（現在はアナウンス削除のため、ログ出力のみ）
        print("🎴 特殊カード演出: \(title) - \(subtitle)")
        print("   演出タイプ: \(effectType)")
        
        // 将来的にはここで特殊カード専用のエフェクトを実装
        // 現在は即座にコールバックを実行
        completion()
    }
    
    // MARK: - Utility Methods
    
    /// 全てのエフェクトをリセット
    func resetAllEffects() {
        hideAnnouncement()
        hideDotenkoLogoAnimation()
        hideRateUpEffect()
        print("🎭 全エフェクトリセット完了")
    }
    
    /// エフェクトマネージャーの状態をログ出力
    func logCurrentState() {
        print("🎭 エフェクトマネージャー状態:")
        print("   アナウンス表示中: \(showAnnouncement)")
        print("   アナウンスブロック中: \(isAnnouncementBlocking)")
        print("   レートアップエフェクト表示中: \(showRateUpEffect)")
        print("   レートアップ倍率: ×\(rateUpMultiplier)")
    }
    
    /// チャレンジゾーン開始アナウンスを表示
    /// - Parameters:
    ///   - participantCount: 参加者数
    ///   - completion: アニメーション完了後のコールバック
    func showChallengeZoneStartAnnouncement(participantCount: Int, completion: (() -> Void)? = nil) {
        let title = "チャレンジゾーン開始"
        let subtitle = "\(participantCount)人が参加"
        
        print("🎯 チャレンジゾーン開始アナウンス表示: 参加者\(participantCount)人")
        
        showAnnouncementMessage(title: title, subtitle: subtitle, completion: completion)
    }
    
    /// チャレンジゾーン終了アナウンスを表示
    /// - Parameters:
    ///   - winnerName: 勝者名
    ///   - completion: アニメーション完了後のコールバック
    func showChallengeZoneEndAnnouncement(winnerName: String, completion: (() -> Void)? = nil) {
        let title = "チャレンジゾーン終了"
        let subtitle = "\(winnerName) の勝利"
        
        print("🏁 チャレンジゾーン終了アナウンス表示: 勝者\(winnerName)")
        
        showAnnouncementMessage(title: title, subtitle: subtitle, completion: completion)
    }
} 