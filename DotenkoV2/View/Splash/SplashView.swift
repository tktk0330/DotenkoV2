import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SplashView: View {
    @ObservedObject var navigator: NavigationStateManager
    @State private var opacity: Double = 1.0
    @State private var isAuthenticating = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                
                Text("Dotenko")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if isAuthenticating {
                    ProgressView()
                        .tint(.green)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
        .opacity(opacity)
        .task {
            do {
                // Firebase認証を実行
                let authResult = try await FireBaseManager.shared.signInAnonymously()
                let userId = authResult.user.uid
                
                // Firestoreのユーザーデータを更新
                let db = Firestore.firestore()
                try await db.collection("users").document(userId).setData([
                    "id": userId,
                    "name": "Anonymous User",
                    "lastLoginAt": Date()
                ])
                
                // 認証成功後、フェードアウトして遷移
                isAuthenticating = false
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0
                }
                
                // TopViewへ遷移
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    navigator.push(AnyView(TopView(navigator: navigator)))
                }
            } catch {
                print("Authentication error: \(error.localizedDescription)")
                // エラーメッセージを表示
                errorMessage = "認証に失敗しました。\nアプリを再起動してください。"
                isAuthenticating = false
                
                // エラー発生時も一定時間後に遷移
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        navigator.push(AnyView(TopView(navigator: navigator)))
                    }
                }
            }
        }
    }
}
