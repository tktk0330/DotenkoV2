/**
 設定ファイル
 ※ GitHubにあげない！！
 */

import Foundation

struct Config {
    
#if DEBUG
    // BannerID
    static let bannerId = "ca-app-pub-3940256099942544/2934735716"
    
    struct GameConfig {
        // 広告の表示設定
        static let isAdmob = false
        // 手札見れるか
        static let isCardOpen = true
        
    }
#else
    static let bannerId = ""
    
    struct GameConfig {
        static let isAdmob = true
        static let isCardOpen = false
    }
#endif
    
    
}
