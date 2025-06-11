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
    
    // レートアップエフェクトシステム
    @Published var showRateUpEffect: Bool = false
    @Published var rateUpMultiplier: Int = 1
    
    // MARK: - Private Properties
    private var rateUpEffectTimer: Timer?
    
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
    
    // MARK: - Rate Up Effect System
    
    /// レートアップエフェクトを表示
    /// - Parameter multiplier: 現在の倍率
    func showRateUpEffect(multiplier: Int) {
        // 既存のタイマーをキャンセル
        rateUpEffectTimer?.invalidate()
        
        rateUpMultiplier = multiplier
        showRateUpEffect = true
        
        print("📈 レートアップエフェクト表示: ×\(multiplier)")
        
        // 5.0秒後にエフェクトを非表示（5回発射 + スローアニメーション完了時間に合わせて調整）
        rateUpEffectTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.hideRateUpEffect()
        }
    }
    
    /// レートアップエフェクトを非表示
    func hideRateUpEffect() {
        rateUpEffectTimer?.invalidate()
        rateUpEffectTimer = nil
        showRateUpEffect = false
        rateUpMultiplier = 1
        print("📈 レートアップエフェクト終了")
    }
    
    /// レートアップエフェクトが表示中かチェック
    func isRateUpEffectActive() -> Bool {
        return showRateUpEffect
    }
    
    // MARK: - Declaration Animation System
    
    /// 宣言アニメーションの種類
    enum DeclarationAnimationType {
        case dotenko    // どてんこ宣言
        case shotenko   // しょてんこ宣言
        case revenge    // リベンジ宣言
        
        var title: String {
            switch self {
            case .dotenko: return "どてんこ！"
            case .shotenko: return "しょてんこ！"
            case .revenge: return "リベンジ！"
            }
        }
        
        var subtitle: String {
            switch self {
            case .dotenko: return "勝利宣言"
            case .shotenko: return "初手勝利"
            case .revenge: return "逆転宣言"
            }
        }
    }
    
    /// 宣言アニメーションを表示
    /// - Parameters:
    ///   - type: 宣言の種類
    ///   - playerName: 宣言したプレイヤー名
    ///   - completion: アニメーション完了後のコールバック
    func showDeclarationAnimation(type: DeclarationAnimationType, playerName: String, completion: (() -> Void)? = nil) {
        let title = type.title
        let subtitle = "\(playerName) の\(type.subtitle)"
        
        print("🎊 宣言アニメーション開始: \(type) - プレイヤー: \(playerName)")
        
        // アナウンスシステムを使用してアニメーション表示
        showAnnouncementMessage(title: title, subtitle: subtitle, completion: completion)
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
} 