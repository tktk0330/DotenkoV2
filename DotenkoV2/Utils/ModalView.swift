import SwiftUI

struct ModalView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景のオーバーレイ（広告エリアを除く）
                Color.black
                    .opacity(0.4)
                    .ignoresSafeArea(.all, edges: [.top, .horizontal])
                    .allowsHitTesting(false) // 背景タップを無効化
                
                // モーダルコンテンツ
                VStack {
                    content
                        .frame(maxWidth: geometry.size.width * 0.9)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

// 角丸を特定の角にのみ適用するための拡張
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// カスタムの角丸形状
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
