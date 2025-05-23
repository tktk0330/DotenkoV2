import SwiftUI

@MainActor
class ErrorManager: ObservableObject {
    static let shared = ErrorManager()
    private let modalManager = ModalManager.shared
    
    private init() {}
    
    func showError(_ message: String) {
        modalManager.show {
            ErrorView(errorMessage: message)
        }
    }
}

// MARK: - View Extension
extension View {
    func withErrorHandling() -> some View {
        self.modifier(ErrorHandlingModifier())
    }
}

struct ErrorHandlingModifier: ViewModifier {
    @StateObject private var errorManager = ErrorManager.shared
    
    func body(content: Content) -> some View {
        content
            .modalOverlay()
    }
} 
