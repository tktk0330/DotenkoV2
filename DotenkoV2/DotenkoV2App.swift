import SwiftUI
import GoogleMobileAds
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

@main
struct DotenkoV2App: App {
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
