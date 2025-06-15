import SwiftUI

// MARK: - Casino Unified Button
/// カジノ風統一ボタンコンポーネント
/// アプリ全体で使用する統一デザインボタン
struct CasinoUnifiedButton: View {
    
    // MARK: - Button Style Enum
    enum ButtonStyle {
        case primary    // メインアクション（OK、開始等）
        case secondary  // サブアクション（戻る、キャンセル等）
        case danger     // 危険なアクション（ゲームを抜ける等）
        case success    // 成功アクション（決定、確認等）
        
        fileprivate var colors: ButtonColors {
            switch self {
            case .primary:
                return ButtonColors(
                    gradient: [
                        Color(red: 1.0, green: 0.84, blue: 0.0),  // ゴールド
                        Color(red: 1.0, green: 0.7, blue: 0.0),   // オレンジゴールド
                        Color(red: 0.8, green: 0.5, blue: 0.0)    // ダークゴールド
                    ],
                    border: Color(red: 1.0, green: 0.9, blue: 0.2),
                    glow: Color(red: 1.0, green: 0.84, blue: 0.0),
                    text: Appearance.Color.commonBlack
                )
            case .secondary:
                return ButtonColors(
                    gradient: [
                        Color.gray.opacity(0.8),
                        Color.gray.opacity(0.6),
                        Color.gray.opacity(0.4)
                    ],
                    border: Color.gray.opacity(0.9),
                    glow: Color.gray.opacity(0.5),
                    text: Appearance.Color.commonWhite
                )
            case .danger:
                return ButtonColors(
                    gradient: [
                        Color.red.opacity(0.9),
                        Color.red.opacity(0.7),
                        Color.red.opacity(0.5)
                    ],
                    border: Color.red,
                    glow: Color.red.opacity(0.6),
                    text: Appearance.Color.commonWhite
                )
            case .success:
                return ButtonColors(
                    gradient: [
                        Color.green.opacity(0.9),
                        Color.green.opacity(0.7),
                        Color.green.opacity(0.5)
                    ],
                    border: Color.green,
                    glow: Color.green.opacity(0.6),
                    text: Appearance.Color.commonWhite
                )
            }
        }
    }
    
    // MARK: - Button Size Enum
    enum ButtonSize {
        case small   // 小さいボタン（戻る等）
        case medium  // 中サイズボタン（OK等）
        case large   // 大きいボタン（開始等）
        
        fileprivate var dimensions: ButtonDimensions {
            switch self {
            case .small:
                return ButtonDimensions(width: 120, height: 44, fontSize: 16)
            case .medium:
                return ButtonDimensions(width: 200, height: 60, fontSize: 20)
            case .large:
                return ButtonDimensions(width: 280, height: 70, fontSize: 24)
            }
        }
    }
    
    // MARK: - Supporting Structures
    fileprivate struct ButtonColors {
        let gradient: [Color]
        let border: Color
        let glow: Color
        let text: Color
    }
    
    fileprivate struct ButtonDimensions {
        let width: CGFloat
        let height: CGFloat
        let fontSize: CGFloat
    }
    
    // MARK: - Properties
    let title: String
    let style: ButtonStyle
    let size: ButtonSize
    let action: () -> Void
    let isEnabled: Bool
    let icon: String?
    
    @State private var isPressed = false
    @State private var glowAnimation = false
    
    // MARK: - Initialization
    init(
        title: String,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        icon: String? = nil,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.icon = icon
        self.isEnabled = isEnabled
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            buttonContent
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .onAppear {
            startGlowAnimation()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            if isEnabled {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    // MARK: - Button Content
    private var buttonContent: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: dimensions.fontSize * 0.8, weight: .bold))
                    .foregroundColor(colors.text)
            }
            
            Text(title)
                .font(.system(size: dimensions.fontSize, weight: .bold))
                .foregroundColor(colors.text)
                .tracking(1.0)
        }
        .frame(width: dimensions.width, height: dimensions.height)
        .background(buttonBackground)
        .overlay(buttonBorder)
        .clipShape(RoundedRectangle(cornerRadius: dimensions.height / 2))
        .scaleEffect(isPressed && isEnabled ? 0.95 : 1.0)
        .scaleEffect(glowAnimation && isEnabled ? 1.02 : 1.0)
        .shadow(color: colors.glow.opacity(isEnabled ? 0.6 : 0.2), radius: isEnabled ? 8 : 4, x: 0, y: 4)
        .opacity(isEnabled ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowAnimation)
    }
    
    // MARK: - Background
    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: dimensions.height / 2)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: colors.gradient),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    // MARK: - Border
    private var buttonBorder: some View {
        RoundedRectangle(cornerRadius: dimensions.height / 2)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        colors.border,
                        colors.border.opacity(0.7),
                        colors.border
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
    }
    
    // MARK: - Computed Properties
    private var colors: ButtonColors {
        style.colors
    }
    
    private var dimensions: ButtonDimensions {
        size.dimensions
    }
    
    // MARK: - Animation
    private func startGlowAnimation() {
        if isEnabled {
            glowAnimation = true
        }
    }
}

// MARK: - Convenience Initializers
extension CasinoUnifiedButton {
    
    /// OKボタン用の便利イニシャライザ
    static func ok(action: @escaping () -> Void) -> CasinoUnifiedButton {
        CasinoUnifiedButton(
            title: "OK",
            style: .primary,
            size: .medium,
            action: action
        )
    }
    
    /// 戻るボタン用の便利イニシャライザ
    static func back(action: @escaping () -> Void) -> CasinoUnifiedButton {
        CasinoUnifiedButton(
            title: "戻る",
            style: .secondary,
            size: .small,
            icon: "chevron.left",
            action: action
        )
    }
    
    /// 開始ボタン用の便利イニシャライザ
    static func start(title: String = "ゲームを開始", action: @escaping () -> Void) -> CasinoUnifiedButton {
        CasinoUnifiedButton(
            title: title,
            style: .primary,
            size: .large,
            icon: "play.fill",
            action: action
        )
    }
    
    /// 決定ボタン用の便利イニシャライザ
    static func confirm(title: String = "決定", action: @escaping () -> Void) -> CasinoUnifiedButton {
        CasinoUnifiedButton(
            title: title,
            style: .success,
            size: .medium,
            icon: "checkmark.circle.fill",
            action: action
        )
    }
    
    /// 危険なアクション用の便利イニシャライザ
    static func danger(title: String, action: @escaping () -> Void) -> CasinoUnifiedButton {
        CasinoUnifiedButton(
            title: title,
            style: .danger,
            size: .medium,
            icon: "exclamationmark.triangle.fill",
            action: action
        )
    }
    
    /// 閉じるボタン用の便利イニシャライザ
    static func close(action: @escaping () -> Void) -> CasinoUnifiedButton {
        CasinoUnifiedButton(
            title: "閉じる",
            style: .secondary,
            size: .medium,
            icon: "xmark.circle.fill",
            action: action
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("カジノ統一ボタン")
            .font(.title)
            .foregroundColor(.white)
        
        // 各スタイルのプレビュー
        VStack(spacing: 16) {
            CasinoUnifiedButton.ok(action: {})
            CasinoUnifiedButton.start(action: {})
            CasinoUnifiedButton.confirm(action: {})
            CasinoUnifiedButton.danger(title: "ゲームを抜ける", action: {})
            CasinoUnifiedButton.back(action: {})
            CasinoUnifiedButton.close(action: {})
        }
        
        // サイズ比較
        VStack(spacing: 16) {
            CasinoUnifiedButton(title: "小", style: .primary, size: .small, action: {})
            CasinoUnifiedButton(title: "中", style: .primary, size: .medium, action: {})
            CasinoUnifiedButton(title: "大", style: .primary, size: .large, action: {})
        }
        
        // 無効状態
        CasinoUnifiedButton(title: "無効", style: .primary, size: .medium, isEnabled: false, action: {})
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
    .previewDisplayName("カジノ統一ボタン")
} 