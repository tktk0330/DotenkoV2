import SwiftUI

// ViewをHashableにラップするための構造体
struct ViewWrapper: Hashable {
    let id = UUID()
    let view: AnyView
    
    static func == (lhs: ViewWrapper, rhs: ViewWrapper) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@MainActor
class NavigationStateManager: ObservableObject {
    @Published var currentView: AnyView?
    private var viewStack: [AnyView] = []
    
    func push<V: View>(_ view: V) {
        if let current = currentView {
            viewStack.append(current)
        }
        withAnimation(.easeInOut(duration: 0.0)) {
            currentView = AnyView(view)
        }
    }
    
    func pop() {
        withAnimation(.easeInOut(duration: 0.0)) {
            if !viewStack.isEmpty {
                currentView = viewStack.removeLast()
            } else {
                currentView = nil
            }
        }
    }
    
    func popToRoot() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentView = nil
            viewStack.removeAll()
        }
    }
    
    // デバッグ用：現在のスタック状態を確認
    func printNavigationState() {
        print("Current view exists: \(currentView != nil)")
        print("Stack count: \(viewStack.count)")
    }
}

@MainActor
class NavigationAllViewStateManager: ObservableObject {
    @Published var currentView: AnyView?
    private var viewStack: [AnyView] = []
    
    static let shared = NavigationAllViewStateManager()
    
    private init() {}
    
    func push<V: View>(_ view: V) {
        if let current = currentView {
            viewStack.append(current)
        }
        withAnimation(.easeInOut(duration: 0.0)) {
            currentView = AnyView(
                ZStack {
                    Color(uiColor: Appearance.Color.mossGreen)
                        .ignoresSafeArea()
                    view
                }
            )
        }
    }
    
    func pop() {
        withAnimation(.easeInOut(duration: 0.0)) {
            if !viewStack.isEmpty {
                currentView = viewStack.removeLast()
            } else {
                currentView = nil
            }
        }
    }
    
    func popToRoot() {
        withAnimation(.easeInOut(duration: 0)) {
            currentView = nil
            viewStack.removeAll()
        }
    }
    
    // デバッグ用：現在のスタック状態を確認
    func printNavigationState() {
        print("Current all view exists: \(currentView != nil)")
        print("All view stack count: \(viewStack.count)")
    }
}
