import SwiftUI

// MARK: - Dotenko Declaration Button
/// どてんこ宣言専用ボタンコンポーネント（円形パチンコ風赤ボタンデザイン）
struct DotenkoDeclarationButton: View {
    let action: () -> Void
    let isEnabled: Bool
    
    @State private var isPressed = false
    @State private var isBlinking = false
    @State private var heartbeatAnimation = false
    
    private let size: CGFloat = 100 // 円形ボタンのサイズ
    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            ZStack {
                // 円形パチンコ風赤背景
                circularPachinkoRedBackground
                
                // メインテキスト（DOTENKOのみ、カジノ風立体的な文字）
                ZStack {
                    // テキストの深い影（立体感の基盤）
                    Text("DOTENKO")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(Appearance.Color.commonBlack.opacity(0.8))
                        .tracking(1.2)
                        .offset(x: 2, y: 3)
                    
                    // メインテキスト（カジノ風ゴールド）
                    Text("DOTENKO")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.9, blue: 0.3), // 明るいゴールド
                                    Color(red: 1.0, green: 0.84, blue: 0.0), // ゴールド
                                    Color(red: 0.8, green: 0.6, blue: 0.0),  // 深いゴールド
                                    Color(red: 1.0, green: 0.84, blue: 0.0)  // ゴールド
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .tracking(1.2)
                        .shadow(color: Appearance.Color.commonBlack.opacity(0.9), radius: 2, x: 1, y: 2)
                        .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.8), radius: 4, x: 0, y: 0) // ゴールドグロー
                        .multilineTextAlignment(.center)
                    
                    // カジノ風の輝きエフェクト
                    Text("DOTENKO")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(Appearance.Color.commonWhite.opacity(0.6))
                        .tracking(1.2)
                        .blur(radius: 1)
                        .offset(x: -1, y: -1)
                        .multilineTextAlignment(.center)
                }
                
                // 押下時のオーバーレイ（円形パチンコボタンの押し込み効果）
                if isPressed && isEnabled {
                    Circle()
                        .fill(Appearance.Color.commonBlack.opacity(0.4))
                        .scaleEffect(0.9)
                }
            }
            .frame(width: size, height: size)
            .scaleEffect(isPressed && isEnabled ? 0.88 : 1.0) // より強い押し込み効果
            .scaleEffect(isBlinking ? 1.15 : 1.0) // より強い点滅効果
            .scaleEffect(heartbeatAnimation ? 1.12 : 1.0) // 心臓の鼓動アニメーション
            .animation(.easeInOut(duration: 0.1), value: isPressed) // より素早い反応
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isBlinking)
            .opacity(isEnabled ? 1.0 : 0.0) // 無効時は非表示
        }
        .buttonStyle(PlainButtonStyle())
        .zIndex(2000)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            if isEnabled {
                isPressed = pressing
            }
        }, perform: {})
        .disabled(!isEnabled)
        .onAppear {
            // 有効な時のみ点滅と心臓の鼓動
            isBlinking = isEnabled
            startHeartbeatAnimation()
        }
        .onChange(of: isEnabled) { enabled in
            // 有効状態に応じて点滅・心臓の鼓動制御
            isBlinking = enabled
            if enabled {
                startHeartbeatAnimation()
            } else {
                heartbeatAnimation = false
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var textColor: Color {
        isEnabled ? Appearance.Color.commonWhite : Appearance.Color.commonGray
    }
    
    @ViewBuilder
    private var circularPachinkoRedBackground: some View {
        ZStack {
            // 最下層: 深い影（立体感の基盤）
            Circle()
                .fill(Appearance.Color.commonBlack.opacity(0.9))
                .offset(x: 0, y: 8) // 下方向に影をずらす
                .blur(radius: 6)
            
            // ベース背景（深い赤のグラデーション - 円形パチンコボタン風）
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(red: 1.0, green: 0.2, blue: 0.2), location: 0.0), // 中心の明るい赤
                            .init(color: Color(red: 0.9, green: 0.1, blue: 0.1), location: 0.3), // 中間赤
                            .init(color: Color(red: 0.7, green: 0.0, blue: 0.0), location: 0.7), // 深い赤
                            .init(color: Color(red: 0.4, green: 0.0, blue: 0.0), location: 1.0)  // 外縁の最深赤
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .shadow(color: Appearance.Color.commonRed.opacity(0.9), radius: 15, x: 0, y: 0) // 強い赤いグロー
                .shadow(color: Appearance.Color.commonBlack.opacity(0.7), radius: 10, x: 0, y: 6) // 立体感の影
            
            // 上部ハイライト（パチンコボタンの強い光沢感）
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Appearance.Color.commonWhite.opacity(0.6), location: 0.0),
                            .init(color: Appearance.Color.commonWhite.opacity(0.3), location: 0.4),
                            .init(color: Appearance.Color.commonClear, location: 0.8)
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3), // 左上からの光
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .scaleEffect(0.8)
                .offset(x: -8, y: -8)
            
            // 金色の装飾枠線（円形パチンコボタンの豪華さ）
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.84, blue: 0.0), // ゴールド
                            Color(red: 1.0, green: 0.6, blue: 0.0),  // オレンジゴールド
                            Color(red: 1.0, green: 0.9, blue: 0.2),  // 明るいゴールド
                            Color(red: 1.0, green: 0.84, blue: 0.0), // ゴールド
                            Color(red: 1.0, green: 0.6, blue: 0.0)   // オレンジゴールド
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4.0
                )
                .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.8), radius: 3, x: 0, y: 0)
            
            // 内側の細い枠線（立体感の強調）
            Circle()
                .stroke(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.commonWhite.opacity(isEnabled ? 0.8 : 0.3),
                            Appearance.Color.commonWhite.opacity(isEnabled ? 0.4 : 0.1),
                            Appearance.Color.commonClear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 35
                    ),
                    lineWidth: 2.0
                )
                .scaleEffect(0.85)
            
            // 中央の強い光沢効果（パチンコボタンの特徴的な光）
            if isEnabled {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Appearance.Color.commonWhite.opacity(0.4), location: 0.0),
                                .init(color: Appearance.Color.commonWhite.opacity(0.2), location: 0.3),
                                .init(color: Appearance.Color.commonWhite.opacity(0.1), location: 0.6),
                                .init(color: Appearance.Color.commonClear, location: 1.0)
                            ]),
                            center: UnitPoint(x: 0.4, y: 0.4),
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .scaleEffect(0.6)
                    .offset(x: -5, y: -5)
            }
            
            // 外側のリング装飾（パチンコボタンの豪華さ）
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.8),
                            Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.6),
                            Color(red: 1.0, green: 0.9, blue: 0.2).opacity(0.9),
                            Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.8)
                        ]),
                        center: .center
                    ),
                    lineWidth: 1.5
                )
                .scaleEffect(1.05)
                .opacity(isEnabled ? 0.7 : 0.3)
        }
    }
    
    // MARK: - Animation Methods
    
    /// 心臓の鼓動のようなリズムアニメーションを開始
    /// ドクン、ドクンという2回の拍動パターンを繰り返す
    private func startHeartbeatAnimation() {
        guard isEnabled else { return }
        
        // 心臓の鼓動パターン: ドクン（0.15秒）→ 休憩（0.1秒）→ ドクン（0.15秒）→ 長い休憩（0.8秒）
        func performHeartbeat() {
            // 1回目の鼓動
            withAnimation(.easeInOut(duration: 0.15)) {
                heartbeatAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    heartbeatAnimation = false
                }
                
                // 短い休憩後、2回目の鼓動
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        heartbeatAnimation = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            heartbeatAnimation = false
                        }
                        
                        // 長い休憩後、次のサイクル
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            if isEnabled {
                                performHeartbeat()
                            }
                        }
                    }
                }
            }
        }
        
        performHeartbeat()
    }
}

// MARK: - Revenge Declaration Button
/// リベンジ宣言専用ボタンコンポーネント（円形パチンコ風黄色ボタンデザイン）
struct RevengeDeclarationButton: View {
    let action: () -> Void
    let isEnabled: Bool
    
    @State private var isPressed = false
    @State private var isBlinking = false
    @State private var heartbeatAnimation = false
    
    private let size: CGFloat = 100 // 円形ボタンのサイズ
    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            ZStack {
                // 円形パチンコ風黄色背景
                circularPachinkoYellowBackground
                
                // メインテキスト（REVENGEのみ、カジノ風立体的な文字）
                ZStack {
                    // テキストの深い影（立体感の基盤）
                    Text("REVENGE")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(Appearance.Color.commonBlack.opacity(0.8))
                        .tracking(1.0)
                        .offset(x: 2, y: 3)
                    
                    // メインテキスト（カジノ風ブロンズゴールド）
                    Text("REVENGE")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.9, blue: 0.1), // 明るい黄金
                                    Color(red: 1.0, green: 0.7, blue: 0.0), // オレンジゴールド
                                    Color(red: 0.8, green: 0.5, blue: 0.0), // 深いブロンズ
                                    Color(red: 1.0, green: 0.7, blue: 0.0)  // オレンジゴールド
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .tracking(1.0)
                        .shadow(color: Appearance.Color.commonBlack.opacity(0.9), radius: 2, x: 1, y: 2)
                        .shadow(color: Color.orange.opacity(0.8), radius: 4, x: 0, y: 0) // オレンジグロー
                        .multilineTextAlignment(.center)
                    
                    // カジノ風の輝きエフェクト
                    Text("REVENGE")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(Appearance.Color.commonWhite.opacity(0.6))
                        .tracking(1.0)
                        .blur(radius: 1)
                        .offset(x: -1, y: -1)
                        .multilineTextAlignment(.center)
                }
                
                // 押下時のオーバーレイ（円形パチンコボタンの押し込み効果）
                if isPressed && isEnabled {
                    Circle()
                        .fill(Appearance.Color.commonBlack.opacity(0.4))
                        .scaleEffect(0.9)
                }
            }
            .frame(width: size, height: size)
            .scaleEffect(isPressed && isEnabled ? 0.88 : 1.0) // より強い押し込み効果
            .scaleEffect(isBlinking ? 1.15 : 1.0) // より強い点滅効果
            .scaleEffect(heartbeatAnimation ? 1.12 : 1.0) // 心臓の鼓動アニメーション
            .animation(.easeInOut(duration: 0.1), value: isPressed) // より素早い反応
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isBlinking)
            .animation(
                Animation.easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: false)
                    .delay(0.0),
                value: heartbeatAnimation
            ) // 心臓の鼓動リズム
            .opacity(isEnabled ? 1.0 : 0.0) // 無効時は非表示
        }
        .buttonStyle(PlainButtonStyle())
        .zIndex(2000)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            if isEnabled {
                isPressed = pressing
            }
        }, perform: {})
        .disabled(!isEnabled)
        .onAppear {
            // 有効な時のみ点滅と心臓の鼓動
            isBlinking = isEnabled
            startHeartbeatAnimation()
        }
        .onChange(of: isEnabled) { enabled in
            // 有効状態に応じて点滅・心臓の鼓動制御
            isBlinking = enabled
            if enabled {
                startHeartbeatAnimation()
            } else {
                heartbeatAnimation = false
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var textColor: Color {
        isEnabled ? Appearance.Color.commonWhite : Appearance.Color.commonGray
    }
    
    // MARK: - Animation Methods
    
    /// 心臓の鼓動のようなリズムアニメーションを開始
    /// ドクン、ドクンという2回の拍動パターンを繰り返す
    private func startHeartbeatAnimation() {
        guard isEnabled else { return }
        
        // 心臓の鼓動パターン: ドクン（0.15秒）→ 休憩（0.1秒）→ ドクン（0.15秒）→ 長い休憩（0.8秒）
        func performHeartbeat() {
            // 1回目の鼓動
            withAnimation(.easeInOut(duration: 0.15)) {
                heartbeatAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    heartbeatAnimation = false
                }
                
                // 短い休憩後、2回目の鼓動
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        heartbeatAnimation = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            heartbeatAnimation = false
                        }
                        
                        // 長い休憩後、次のサイクル
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            if isEnabled {
                                performHeartbeat()
                            }
                        }
                    }
                }
            }
        }
        
        performHeartbeat()
    }
    
    @ViewBuilder
    private var circularPachinkoYellowBackground: some View {
        ZStack {
            // 最下層: 深い影（立体感の基盤）
            Circle()
                .fill(Appearance.Color.commonBlack.opacity(0.9))
                .offset(x: 0, y: 8) // 下方向に影をずらす
                .blur(radius: 6)
            
            // ベース背景（深い黄色のグラデーション - 円形パチンコボタン風）
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(red: 1.0, green: 0.9, blue: 0.1), location: 0.0), // 中心の明るい黄色
                            .init(color: Color(red: 1.0, green: 0.7, blue: 0.0), location: 0.3), // 中間オレンジ
                            .init(color: Color(red: 0.8, green: 0.5, blue: 0.0), location: 0.7), // 深いオレンジ
                            .init(color: Color(red: 0.6, green: 0.3, blue: 0.0), location: 1.0)  // 外縁の最深オレンジ
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .shadow(color: Color.orange.opacity(0.9), radius: 15, x: 0, y: 0) // 強いオレンジグロー
                .shadow(color: Appearance.Color.commonBlack.opacity(0.7), radius: 10, x: 0, y: 6) // 立体感の影
            
            // 上部ハイライト（パチンコボタンの強い光沢感）
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Appearance.Color.commonWhite.opacity(0.6), location: 0.0),
                            .init(color: Appearance.Color.commonWhite.opacity(0.3), location: 0.4),
                            .init(color: Appearance.Color.commonClear, location: 0.8)
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3), // 左上からの光
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .scaleEffect(0.8)
                .offset(x: -8, y: -8)
            
            // ブロンズゴールドの装飾枠線（円形パチンコボタンの豪華さ）
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.7, blue: 0.0), // オレンジゴールド
                            Color(red: 1.0, green: 0.9, blue: 0.1), // 明るい黄金
                            Color(red: 0.8, green: 0.5, blue: 0.0), // ブロンズ
                            Color(red: 1.0, green: 0.7, blue: 0.0), // オレンジゴールド
                            Color(red: 1.0, green: 0.9, blue: 0.1)  // 明るい黄金
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4.0
                )
                .shadow(color: Color.orange.opacity(0.8), radius: 3, x: 0, y: 0)
            
            // 内側の細い枠線（立体感の強調）
            Circle()
                .stroke(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.commonWhite.opacity(isEnabled ? 0.8 : 0.3),
                            Appearance.Color.commonWhite.opacity(isEnabled ? 0.4 : 0.1),
                            Appearance.Color.commonClear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 35
                    ),
                    lineWidth: 2.0
                )
                .scaleEffect(0.85)
            
            // 中央の強い光沢効果（パチンコボタンの特徴的な光）
            if isEnabled {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Appearance.Color.commonWhite.opacity(0.4), location: 0.0),
                                .init(color: Appearance.Color.commonWhite.opacity(0.2), location: 0.3),
                                .init(color: Appearance.Color.commonWhite.opacity(0.1), location: 0.6),
                                .init(color: Appearance.Color.commonClear, location: 1.0)
                            ]),
                            center: UnitPoint(x: 0.4, y: 0.4),
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .scaleEffect(0.6)
                    .offset(x: -5, y: -5)
            }
            
            // 外側のリング装飾（パチンコボタンの豪華さ）
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.8),
                            Color.yellow.opacity(0.6),
                            Color(red: 1.0, green: 0.7, blue: 0.0).opacity(0.9),
                            Color.orange.opacity(0.8)
                        ]),
                        center: .center
                    ),
                    lineWidth: 1.5
                )
                .scaleEffect(1.05)
                .opacity(isEnabled ? 0.7 : 0.3)
        }
    }
}

// MARK: - Shotenko Declaration Button
/// しょてんこ宣言専用ボタンコンポーネント（円形パチンコ風青ボタンデザイン）
struct ShotenkoDeclarationButton: View {
    let action: () -> Void
    let isEnabled: Bool
    
    @State private var isPressed = false
    @State private var isBlinking = false
    @State private var heartbeatAnimation = false
    
    private let size: CGFloat = 100 // 円形ボタンのサイズ
    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            ZStack {
                // 円形パチンコ風青背景
                circularPachinkoBlueBackground
                
                // メインテキスト（SHOTENKOのみ、カジノ風立体的な文字）
                ZStack {
                    // テキストの深い影（立体感の基盤）
                    Text("SHOTENKO")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(Appearance.Color.commonBlack.opacity(0.8))
                        .tracking(1.0)
                        .offset(x: 2, y: 3)
                    
                    // メインテキスト（カジノ風シルバー）
                    Text("SHOTENKO")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.95, green: 0.95, blue: 1.0), // 明るいシルバー
                                    Color(red: 0.9, green: 0.9, blue: 0.9),   // シルバー
                                    Color(red: 0.7, green: 0.7, blue: 0.8),   // 深いシルバー
                                    Color(red: 0.9, green: 0.9, blue: 0.9)    // シルバー
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .tracking(1.0)
                        .shadow(color: Appearance.Color.commonBlack.opacity(0.9), radius: 2, x: 1, y: 2)
                        .shadow(color: Color.cyan.opacity(0.8), radius: 4, x: 0, y: 0) // シアングロー
                        .multilineTextAlignment(.center)
                    
                    // カジノ風の輝きエフェクト
                    Text("SHOTENKO")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(Appearance.Color.commonWhite.opacity(0.6))
                        .tracking(1.0)
                        .blur(radius: 1)
                        .offset(x: -1, y: -1)
                        .multilineTextAlignment(.center)
                }
                
                // 押下時のオーバーレイ（円形パチンコボタンの押し込み効果）
                if isPressed && isEnabled {
                    Circle()
                        .fill(Appearance.Color.commonBlack.opacity(0.4))
                        .scaleEffect(0.9)
                }
            }
            .frame(width: size, height: size)
            .scaleEffect(isPressed && isEnabled ? 0.88 : 1.0) // より強い押し込み効果
            .scaleEffect(isBlinking ? 1.15 : 1.0) // より強い点滅効果
            .scaleEffect(heartbeatAnimation ? 1.12 : 1.0) // 心臓の鼓動アニメーション
            .animation(.easeInOut(duration: 0.1), value: isPressed) // より素早い反応
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isBlinking)
            .opacity(isEnabled ? 1.0 : 0.0) // 無効時は非表示
        }
        .buttonStyle(PlainButtonStyle())
        .zIndex(2000)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            if isEnabled {
                isPressed = pressing
            }
        }, perform: {})
        .disabled(!isEnabled)
        .onAppear {
            // 有効な時のみ点滅と心臓の鼓動
            isBlinking = isEnabled
            startHeartbeatAnimation()
        }
        .onChange(of: isEnabled) { enabled in
            // 有効状態に応じて点滅・心臓の鼓動制御
            isBlinking = enabled
            if enabled {
                startHeartbeatAnimation()
            } else {
                heartbeatAnimation = false
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var textColor: Color {
        isEnabled ? Appearance.Color.commonWhite : Appearance.Color.commonGray
    }
    
    // MARK: - Animation Methods
    
    /// 心臓の鼓動のようなリズムアニメーションを開始
    /// ドクン、ドクンという2回の拍動パターンを繰り返す
    private func startHeartbeatAnimation() {
        guard isEnabled else { return }
        
        // 心臓の鼓動パターン: ドクン（0.15秒）→ 休憩（0.1秒）→ ドクン（0.15秒）→ 長い休憩（0.8秒）
        func performHeartbeat() {
            // 1回目の鼓動
            withAnimation(.easeInOut(duration: 0.15)) {
                heartbeatAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    heartbeatAnimation = false
                }
                
                // 短い休憩後、2回目の鼓動
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        heartbeatAnimation = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            heartbeatAnimation = false
                        }
                        
                        // 長い休憩後、次のサイクル
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            if isEnabled {
                                performHeartbeat()
                            }
                        }
                    }
                }
            }
        }
        
        performHeartbeat()
    }
    
    @ViewBuilder
    private var circularPachinkoBlueBackground: some View {
        ZStack {
            // 最下層: 深い影（立体感の基盤）
            Circle()
                .fill(Appearance.Color.commonBlack.opacity(0.9))
                .offset(x: 0, y: 8) // 下方向に影をずらす
                .blur(radius: 6)
            
            // ベース背景（深い青のグラデーション - 円形パチンコボタン風）
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(red: 0.2, green: 0.4, blue: 1.0), location: 0.0), // 中心の明るい青
                            .init(color: Color(red: 0.1, green: 0.3, blue: 0.9), location: 0.3), // 中間青
                            .init(color: Color(red: 0.0, green: 0.2, blue: 0.7), location: 0.7), // 深い青
                            .init(color: Color(red: 0.0, green: 0.1, blue: 0.4), location: 1.0)  // 外縁の最深青
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .shadow(color: Color.cyan.opacity(0.9), radius: 15, x: 0, y: 0) // 強いシアングロー
                .shadow(color: Appearance.Color.commonBlack.opacity(0.7), radius: 10, x: 0, y: 6) // 立体感の影
            
            // 上部ハイライト（パチンコボタンの強い光沢感）
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Appearance.Color.commonWhite.opacity(0.6), location: 0.0),
                            .init(color: Appearance.Color.commonWhite.opacity(0.3), location: 0.4),
                            .init(color: Appearance.Color.commonClear, location: 0.8)
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3), // 左上からの光
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .scaleEffect(0.8)
                .offset(x: -8, y: -8)
            
            // シルバーの装飾枠線（円形パチンコボタンの豪華さ）
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.9, green: 0.9, blue: 0.9), // シルバー
                            Color(red: 0.7, green: 0.8, blue: 1.0), // ブルーシルバー
                            Color(red: 0.95, green: 0.95, blue: 1.0), // 明るいシルバー
                            Color(red: 0.9, green: 0.9, blue: 0.9), // シルバー
                            Color(red: 0.7, green: 0.8, blue: 1.0)  // ブルーシルバー
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4.0
                )
                .shadow(color: Color.cyan.opacity(0.8), radius: 3, x: 0, y: 0)
            
            // 内側の細い枠線（立体感の強調）
            Circle()
                .stroke(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Appearance.Color.commonWhite.opacity(isEnabled ? 0.8 : 0.3),
                            Appearance.Color.commonWhite.opacity(isEnabled ? 0.4 : 0.1),
                            Appearance.Color.commonClear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 35
                    ),
                    lineWidth: 2.0
                )
                .scaleEffect(0.85)
            
            // 中央の強い光沢効果（パチンコボタンの特徴的な光）
            if isEnabled {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Appearance.Color.commonWhite.opacity(0.4), location: 0.0),
                                .init(color: Appearance.Color.commonWhite.opacity(0.2), location: 0.3),
                                .init(color: Appearance.Color.commonWhite.opacity(0.1), location: 0.6),
                                .init(color: Appearance.Color.commonClear, location: 1.0)
                            ]),
                            center: UnitPoint(x: 0.4, y: 0.4),
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .scaleEffect(0.6)
                    .offset(x: -5, y: -5)
            }
            
            // 外側のリング装飾（パチンコボタンの豪華さ）
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.cyan.opacity(0.8),
                            Color.blue.opacity(0.6),
                            Color(red: 0.7, green: 0.8, blue: 1.0).opacity(0.9),
                            Color.cyan.opacity(0.8)
                        ]),
                        center: .center
                    ),
                    lineWidth: 1.5
                )
                .scaleEffect(1.05)
                .opacity(isEnabled ? 0.7 : 0.3)
        }
    }
}

// MARK: - Challenge Zone Draw Card Button
/// チャレンジゾーン用カード引きボタン
struct ChallengeDrawCardButton: View {
    let action: () -> Void
    let isEnabled: Bool
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "plus.rectangle.on.rectangle")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Appearance.Color.commonWhite)
                
                Text("カードを引く")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Appearance.Color.commonWhite)
            }
            .frame(width: 100, height: 80)
            .background(challengeButtonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(challengeButtonBorder)
            .shadow(color: challengeButtonShadowColor, radius: 6, x: 0, y: 3)
            .scaleEffect(isEnabled ? 1.0 : 0.9)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
    
    private var challengeButtonBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.8),
                Color.blue.opacity(0.6),
                Color.blue.opacity(0.9)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var challengeButtonBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.cyan.opacity(0.8),
                        Color.blue.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
    }
    
    private var challengeButtonShadowColor: Color {
        Color.blue.opacity(0.4)
    }
}

// MARK: - Game Announcement View
/// ゲームアナウンス表示コンポーネント（右から流れて中央で1秒停止して左に流れる）
struct GameAnnouncementView: View {
    let title: String
    let subtitle: String
    let isVisible: Bool
    
    @State private var animationPhase: AnnouncementPhase = .hidden
    @State private var glowAnimation: Bool = false
    
    enum AnnouncementPhase {
        case hidden      // 非表示
        case entering    // 右から中央へ
        case staying     // 中央で停止
        case exiting     // 中央から左へ
    }
    
    var body: some View {
        if isVisible {
            // 絶対位置指定でレイアウトに影響しないオーバーレイ
            GeometryReader { geometry in
                VStack(spacing: 16) {
                    // メインタイトル
                    Text(title)
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(Appearance.Color.commonWhite)
                        .tracking(4.0)
                        .shadow(color: Appearance.Color.commonBlack, radius: 3, x: 0, y: 2)
                        .scaleEffect(glowAnimation ? 1.08 : 1.0)
                    
                    // サブタイトル
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Appearance.Color.commonWhite.opacity(0.95))
                            .tracking(1.5)
                            .shadow(color: Appearance.Color.commonBlack, radius: 2, x: 0, y: 1)
                    }
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 40)
                .background(luxuryAnnouncementBackground)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .overlay(luxuryAnnouncementBorder)

                .shadow(color: Appearance.Color.commonBlack.opacity(0.6), radius: 8, x: 0, y: 4)
                .scaleEffect(animationPhase == .staying ? (glowAnimation ? 1.02 : 1.0) : 1.0)
                .position(
                    x: geometry.size.width / 2 + offsetX(for: geometry),
                    y: geometry.size.height / 2
                )
                .opacity(opacity)
            }
            .allowsHitTesting(false) // タッチイベントを完全に無効化
            .zIndex(99999) // 確実に最前面に表示（全ての要素より上）
            .onAppear {
                startAnimation()
                startContinuousAnimations()
            }
            .onChange(of: isVisible) { visible in
                if visible {
                    startAnimation()
                    startContinuousAnimations()
                } else {
                    animationPhase = .hidden
                    glowAnimation = false
                }
            }
        }
    }
    
    // MARK: - Decorative Elements (削除済み)
    
    // MARK: - Animation Properties
    
    /// アニメーションフェーズに応じたX軸オフセットを計算
    /// - Parameter geometry: 画面サイズ情報
    /// - Returns: X軸オフセット値
    private func offsetX(for geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        
        switch animationPhase {
        case .hidden:
            // 画面右端の外側（定数で定義された余裕を持って）
            return screenWidth + LayoutConstants.AnnouncementAnimation.screenOffsetMargin
        case .entering:
            // 画面中央
            return 0
        case .staying:
            // 画面中央で停止
            return 0
        case .exiting:
            // 画面左端の外側（テキスト幅を考慮して完全に流れ切る）
            return -screenWidth - LayoutConstants.AnnouncementAnimation.textWidthMargin
        }
    }
    
    private var opacity: Double {
        switch animationPhase {
        case .hidden:
            return 0.0
        case .entering, .staying, .exiting:
            return 1.0
        }
    }
    
    // MARK: - Animation Control
    
    /// アナウンスアニメーションを開始（3フェーズ構成）
    /// フェーズ1: 右から中央へ高速移動 → フェーズ2: 中央で停止 → フェーズ3: 中央から左へ高速移動
    private func startAnimation() {
        // 初期状態: 画面右端の外側
        animationPhase = .hidden
        
        // フェーズ1: 右から中央へ移動（高速化: 0.8秒）
        DispatchQueue.main.asyncAfter(deadline: .now() + LayoutConstants.AnnouncementAnimation.startDelay) {
            withAnimation(.easeOut(duration: LayoutConstants.AnnouncementAnimation.enteringDuration)) {
                self.animationPhase = .entering
            }
        }
        
        // フェーズ2: 中央で停止（1.5秒間）
        let stayingStartTime = LayoutConstants.AnnouncementAnimation.startDelay + LayoutConstants.AnnouncementAnimation.enteringDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + stayingStartTime) {
            self.animationPhase = .staying
        }
        
        // フェーズ3: 中央から左へ完全に流れ切る（高速化: 1.2秒）
        let exitingStartTime = stayingStartTime + LayoutConstants.AnnouncementAnimation.stayingDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + exitingStartTime) {
            withAnimation(.easeIn(duration: LayoutConstants.AnnouncementAnimation.exitingDuration)) {
                self.animationPhase = .exiting
            }
        }
    }
    
    /// 継続的なアニメーション効果を開始（グロー効果）
    /// 中央停止フェーズで視覚的インパクトを最大化
    private func startContinuousAnimations() {
        // グローアニメーション開始（中央停止時に開始）
        DispatchQueue.main.asyncAfter(deadline: .now() + LayoutConstants.AnnouncementAnimation.glowStartDelay) {
            withAnimation(.easeInOut(duration: LayoutConstants.AnnouncementAnimation.glowDuration).repeatForever(autoreverses: true)) {
                self.glowAnimation = true
            }
        }
    }
    
    @ViewBuilder
    private var luxuryAnnouncementBackground: some View {
        // キリッとしたシンプルな背景
        RoundedRectangle(cornerRadius: 25)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.commonBlack.opacity(0.95),
                        Appearance.Color.commonBlack.opacity(0.85)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
    

    
    @ViewBuilder
    private var luxuryAnnouncementBorder: some View {
        // キリッとしたシンプルなボーダー
        RoundedRectangle(cornerRadius: 25)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Appearance.Color.playerGold,
                        Appearance.Color.playerGold.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
    }
}

// MARK: - Diamond Shape
/// ダイヤモンド形状
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: height))
        path.addLine(to: CGPoint(x: 0, y: height / 2))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - SwiftUI Previews
/// DOTENKOボタンのプレビュー（パチンコ風赤ボタンデザイン）
struct DotenkoDeclarationButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 有効状態のDOTENKOボタン
            VStack(spacing: 30) {
                Text("パチンコ風DOTENKOボタン")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                DotenkoDeclarationButton(
                    action: {
                        print("DOTENKO宣言！")
                    },
                    isEnabled: true
                )
                
                Text("有効状態 - 赤い立体ボタン")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.1, green: 0.2, blue: 0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .previewDisplayName("DOTENKO有効")
            
            // 無効状態のDOTENKOボタン
            VStack(spacing: 30) {
                Text("無効状態")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                DotenkoDeclarationButton(
                    action: {
                        print("無効状態")
                    },
                    isEnabled: false
                )
                
                Text("無効状態 - 非表示")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.1, green: 0.2, blue: 0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .previewDisplayName("DOTENKO無効")
            
            // 複数ボタン比較プレビュー
            VStack(spacing: 40) {
                Text("宣言ボタン比較")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack(spacing: 30) {
                    VStack(spacing: 10) {
                        DotenkoDeclarationButton(
                            action: { print("DOTENKO!") },
                            isEnabled: true
                        )
                        Text("DOTENKO")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 10) {
                        RevengeDeclarationButton(
                            action: { print("REVENGE!") },
                            isEnabled: true
                        )
                        Text("REVENGE")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 10) {
                        ShotenkoDeclarationButton(
                            action: { print("SHOTENKO!") },
                            isEnabled: true
                        )
                        Text("SHOTENKO")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.1, green: 0.2, blue: 0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .previewDisplayName("ボタン比較")
            
            // アニメーション確認用プレビュー
            AnimationPreviewView()
                .previewDisplayName("アニメーション確認")
        }
    }
}

/// アニメーション確認用プレビュー
struct AnimationPreviewView: View {
    @State private var isPressed = false
    @State private var showButton = true
    
    var body: some View {
        VStack(spacing: 40) {
            Text("アニメーション確認")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            DotenkoDeclarationButton(
                action: {
                    // ボタンを一時的に無効化してアニメーション確認
                    showButton = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        showButton = true
                    }
                },
                isEnabled: showButton
            )
            
            VStack(spacing: 15) {
                Text("特徴:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• 赤ベースの立体的デザイン")
                    Text("• パチンコボタン風の光沢感")
                    Text("• 金色装飾枠線")
                    Text("• 常時グローアニメーション")
                    Text("• 強い押し込み効果")
                    Text("• 赤いグロー効果")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            
            Button("リセット") {
                showButton = true
            }
            .padding()
            .background(Color.blue.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(red: 0.1, green: 0.2, blue: 0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
} 