import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    private var realm: Realm?
    
    private init() {
        setupRealm()
    }
    
    private func setupRealm() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // ここでスキーマの更新を行う
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
    
    func getRealm() -> Realm? {
        return realm
    }
} 