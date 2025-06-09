import SwiftUI

// MARK: - Water Ripple Spotlight View
/// ターンプレイヤーの背景に表示する水面波打ちスポットライトView
struct WaterRippleSpotlightView: View {
    let isActive: Bool
    let size: CGFloat
    
    @State private var animationPhase: Double = 0
    @State private var rippleScale: CGFloat = 0.9
    @State private var rippleOpacity: Double = 0.8
    
    var body: some View {
        ZStack {
            // 複数の波紋レイヤーで水面効果を作成
            ForEach(0..<3, id: \.self) { index in
                WaterRippleLayer(
                    phase: animationPhase + Double(index) * 0.33,
                    scale: rippleScale + CGFloat(index) * 0.1,
                    opacity: rippleOpacity - Double(index) * 0.15,
                    size: size
                )
            }
        }
        .opacity(isActive ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.5), value: isActive)
        .onAppear {
            if isActive {
                startAnimation()
            }
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
    }
    
    private func startAnimation() {
        // 連続的な波紋アニメーション（より高速に）
        withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
            animationPhase = 2 * Double.pi
        }
        
        // スケールの脈動アニメーション（より激しく）
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            rippleScale = 1.3
        }
        
        // 透明度の脈動アニメーション（より激しく）
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            rippleOpacity = 0.2
        }
    }
    
    private func stopAnimation() {
        withAnimation(.easeOut(duration: 0.5)) {
            animationPhase = 0
            rippleScale = 0.9
            rippleOpacity = 0.8
        }
    }
}

// MARK: - Water Ripple Layer
/// 個別の波紋レイヤー
private struct WaterRippleLayer: View {
    let phase: Double
    let scale: CGFloat
    let opacity: Double
    let size: CGFloat
    
    var body: some View {
        WaterRippleShape(phase: phase)
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.playerGold.opacity(opacity * 0.9),
                        Appearance.Color.playerDarkGold.opacity(opacity * 0.8),
                        Appearance.Color.playerGold.opacity(opacity * 0.6),
                        Appearance.Color.playerDarkGold.opacity(opacity * 0.4),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: size * 0.02,
                    endRadius: size * 0.48
                )
            )
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .blur(radius: 2)
    }
}

// MARK: - Water Ripple Shape
/// 水面波打ち効果のカスタムShape
private struct WaterRippleShape: Shape, Animatable {
    var phase: Double
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        // 波紋の数と振幅（より激しい動き）
        let rippleCount = 16
        let amplitude = radius * 0.12
        
        // 円形の波紋パスを作成
        for angle in stride(from: 0, to: 2 * Double.pi, by: Double.pi / 180) {
            // 波紋効果の計算
            let rippleOffset = sin(angle * Double(rippleCount) + phase) * amplitude
            let adjustedRadius = radius + rippleOffset
            
            let x = center.x + cos(angle) * adjustedRadius
            let y = center.y + sin(angle) * adjustedRadius
            
            if angle == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview
#if DEBUG
struct WaterRippleSpotlightView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            
            WaterRippleSpotlightView(
                isActive: true,
                size: 200
            )
        }
        .previewLayout(.sizeThatFits)
        .frame(width: 300, height: 300)
    }
}
#endif 