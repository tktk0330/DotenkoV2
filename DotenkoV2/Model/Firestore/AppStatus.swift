/**
 * AppStatus
 * 
 * Firestoreのapp_status_masterコレクション内のapp_statusドキュメントを表すモデル
 * 
 * Firestore構造:
 * app_status_master (コレクション)
 *  └─ app_status (ドキュメント)
 *      ├─ maintenance_flag: String - メンテナンスモードの状態を示すフラグ
 *      └─ min_ios_ver: String - アプリが動作する最小iOSバージョン
 */

import Foundation
import FirebaseFirestoreSwift

/// アプリケーションの状態を管理するモデル
struct AppStatus: Codable {
    /// メンテナンスモードの状態を示すフラグ
    /// - "0": メンテナンスモード無効
    /// - "1": メンテナンスモード有効
    let maintenanceFlag: String
    
    /// アプリが動作する最小iOSバージョン
    /// 例: "15.0.0"
    let minIosVersion: String
    
    /// Firestoreのフィールド名とSwiftのプロパティ名のマッピング
    enum CodingKeys: String, CodingKey {
        case maintenanceFlag = "maintenance_flag"
        case minIosVersion = "min_ios_ver"
    }
} 
