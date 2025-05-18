import SwiftUI

struct OverlayLayout<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
            .ignoresSafeArea()
            .edgesIgnoringSafeArea(.all)
    }
} 