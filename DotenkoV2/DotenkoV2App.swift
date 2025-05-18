import SwiftUI
import GoogleMobileAds

@main
struct DotenkoV2App: App {
    init() {
        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
