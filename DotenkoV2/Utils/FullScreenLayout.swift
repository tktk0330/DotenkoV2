import SwiftUI

struct FullScreenLayout<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
} 