/*
 * DotenkoV2App.swift
 * 
 * ファイル概要:
 * DotenkoV2アプリケーションのエントリーポイント
 * - Firebaseの初期化
 * - Google Mobile Ads SDKの初期化
 * - アプリケーションのメイン設定
 * - ルートビューの設定
 * 
 * 主要機能:
 * - Firebase Core, Auth, Firestore, Realtime Databaseの初期化
 * - AdMob広告SDKの初期化
 * - アプリケーションライフサイクルの管理
 * 
 * 作成日: 2024年12月
 */

import SwiftUI
import GoogleMobileAds
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

// MARK: - App Delegate
/// アプリケーションデリゲート
/// Firebase初期化とアプリケーションライフサイクルの管理を行う
class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// アプリケーション起動時の初期化処理
    /// - Parameters:
    ///   - application: アプリケーションインスタンス
    ///   - launchOptions: 起動オプション
    /// - Returns: 初期化成功フラグ
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Firebase初期化
        FirebaseApp.configure()
        return true
    }
}

// MARK: - Main App
/// DotenkoV2アプリケーションのメインクラス
/// アプリケーションの起動と初期設定を管理
@main
struct DotenkoV2App: App {
    
    /// アプリケーションデリゲートの適用
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    /// アプリケーション初期化
    /// Google Mobile Ads SDKの初期化を行う
    init() {
        // Google Mobile Ads SDK初期化
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    /// アプリケーションのメインシーン
    var body: some Scene {
        WindowGroup {
            // ルートビューを表示
            RootView()
        }
    }
}
