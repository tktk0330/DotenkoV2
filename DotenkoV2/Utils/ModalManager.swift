import SwiftUI

// モーダル表示用の環境キー
private struct ModalViewKey: EnvironmentKey {
    static let defaultValue: ModalContent? = nil
}

// 環境値の拡張
extension EnvironmentValues {
    var modalContent: ModalContent? {
        get { self[ModalViewKey.self] }
        set { self[ModalViewKey.self] = newValue }
    }
}

// モーダルコンテンツを表すstructure
struct ModalContent: Identifiable {
    let id = UUID()
    let view: AnyView
}

// モーダル管理用のクラス
@MainActor
class ModalManager: ObservableObject {
    @Published private(set) var content: ModalContent?
    
    static let shared = ModalManager()
    private init() {}
    
    func show<Content: View>(@ViewBuilder content: () -> Content) {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.content = ModalContent(view: AnyView(content()))
        }
    }
    
    func dismiss() {
        withAnimation(.easeInOut(duration: 0.2)) {
            content = nil
        }
    }
}

// View拡張でモーダル表示用のモディファイアを追加
extension View {
    func modalOverlay() -> some View {
        self.modifier(ModalOverlay())
    }
}

// モーダルオーバーレイのモディファイア
struct ModalOverlay: ViewModifier {
    @StateObject private var manager = ModalManager.shared
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if let modalContent = manager.content {
                    ModalView {
                        modalContent.view
                    }
                }
            }
    }
}
