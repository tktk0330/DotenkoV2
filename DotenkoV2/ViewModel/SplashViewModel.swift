/**
 * SplashViewModel
 * 
 * スプラッシュ画面のビジネスロジックを管理するViewModel
 * アプリ起動時の認証処理とアプリステータスの確認を行う
 */

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

/// スプラッシュ画面のビジネスロジックを管理するViewModel
class SplashViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// 認証処理中の状態
    @Published var isAuthenticating = true
    
    /// エラーメッセージ
    @Published var errorMessage: String?
    
    /// アプリケーションの状態
    @Published var appStatus: AppStatus?
    
    /// 画面遷移の制御フラグ
    @Published var shouldNavigate = false
    
    // MARK: - Private Properties
    
    /// Firestoreデータベースの参照
    private let db = Firestore.firestore()
    
    /// プログレスビューの管理クラス
    private let progressManager = ProgressViewManager.shared
    
    // MARK: - Public Methods
    
    /// 認証処理とユーザーデータの更新を実行
    /// アプリステータスの確認、匿名認証、ユーザーデータの更新を順次実行
    func authenticateAndUpdateUser() async throws {
        progressManager.show()
        do {
            // 1. 先にFirebase匿名認証を実行
            let authResult = try await FireBaseManager.shared.signInAnonymously()
            let userId = authResult.user.uid

            // 2. 認証後にAppStatusを取得
            try await fetchAppStatus()

            // 3. ユーザーデータを更新
            try await updateUserData(userId: userId)

            await MainActor.run {
                self.isAuthenticating = false
                self.progressManager.hide()
                self.shouldNavigate = true
            }
        } catch {
            await MainActor.run {
                print("Authentication error: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                self.isAuthenticating = false
                self.progressManager.hide()
                self.shouldNavigate = false
            }
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    /// ユーザーデータをFirestoreに更新
    /// - Parameter userId: ユーザーID
    private func updateUserData(userId: String) async throws {
        try await db.collection("users").document(userId).setData([
            "id": userId,
            "name": "Anonymous User",
            "last_login_at": Date()
        ])
    }
    
    /// アプリケーションの状態を取得し、必要なチェックを実行
    /// - メンテナンスモードの確認
    /// - アプリバージョンの確認
    private func fetchAppStatus() async throws {
        // アプリステータスの取得
        let document = try await db.collection("app_status_master")
            .document("app_status")
            .getDocument()
        
        guard let data = document.data() else {
            let errorMessage = "アプリステータスが見つかりません"
            await MainActor.run {
                self.errorMessage = errorMessage
            }
            throw NSError(domain: "AppStatusError", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        // データのデコード
        let appStatus = try Firestore.Decoder().decode(AppStatus.self, from: data)
        
        await MainActor.run {
            self.appStatus = appStatus
        }
        
        // メンテナンスモードの確認
        if appStatus.maintenanceFlag == Constant.FLAG_ON {
            let errorMessage = "現在メンテナンス中です"
            await MainActor.run {
                self.errorMessage = errorMessage
            }
            throw NSError(domain: "AppStatusError", code: -2, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        // アプリバージョンの確認
        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if currentVersion.compare(appStatus.minIosVersion, options: .numeric) == .orderedAscending {
                let errorMessage = "アプリの更新が必要です"
                await MainActor.run {
                    self.errorMessage = errorMessage
                }
                throw NSError(domain: "AppStatusError", code: -3, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
        }
    }
} 
