/**
 * RealmManager
 * 
 * Realmデータベースの初期化と管理を行うシングルトンクラス
 * アプリケーション全体で一つのRealmインスタンスを共有するために使用
 */

import Foundation
import RealmSwift

/// Realmデータベースの管理を行うシングルトンクラス
class RealmManager {
    /// シングルトンインスタンス
    static let shared = RealmManager()
    
    /// Realmインスタンス
    private var realm: Realm?
    
    /// プライベートイニシャライザ
    /// シングルトンパターンを実現するため、外部からの初期化を防ぐ
    private init() {
        setupRealm()
    }
    
    /// Realmデータベースの初期設定を行う
    /// - スキーマバージョンの設定
    /// - マイグレーション処理の設定
    /// - Realmインスタンスの初期化
    private func setupRealm() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // スキーマの更新が必要な場合はここで処理
                }
            }
        )
        
        Realm.Configuration.defaultConfiguration = config
        
        do {
            realm = try Realm()
        } catch {
            print("Realmの初期化エラー: \(error)")
        }
    }
    
    /// 現在のRealmインスタンスを取得
    /// - Returns: 初期化済みのRealmインスタンス。初期化に失敗している場合はnil
    func getRealm() -> Realm? {
        return realm
    }
} 