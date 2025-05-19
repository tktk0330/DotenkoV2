import Network
import SwiftUI

@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published private(set) var isConnected = true
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            DispatchQueue.main.async {
                self?.isConnected = isConnected
                if !isConnected {
                    ErrorManager.shared.showError("インターネット接続がありません。\n接続を確認してください。")
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

// MARK: - View Extension
extension View {
    func withNetworkMonitoring() -> some View {
        self.modifier(NetworkMonitoringModifier())
    }
}

struct NetworkMonitoringModifier: ViewModifier {
    @StateObject private var monitor = NetworkMonitor.shared
    
    func body(content: Content) -> some View {
        content
    }
} 