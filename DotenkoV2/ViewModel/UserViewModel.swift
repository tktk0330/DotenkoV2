import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserViewModel: ObservableObject {
    private let db = Firestore.firestore()
    @Published var currentUser: User?
    @Published var error: Error?
    
    // ユーザーを作成または更新
    func createOrUpdateUser(name: String) async {
        do {
            let user = User(
                name: name,
                lastLoginAt: Date()
            )
            
            if let userId = currentUser?.id {
                // 既存ユーザーの更新
                try await db.collection("users").document(userId).setData(from: user)
            } else {
                // 新規ユーザーの作成
                let docRef = try await db.collection("users").addDocument(from: user)
                var newUser = user
                newUser.id = docRef.documentID
                DispatchQueue.main.async {
                    self.currentUser = newUser
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
            }
        }
    }
    
    // ユーザー情報の取得
    func fetchUser(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            let user = try document.data(as: User.self)
            DispatchQueue.main.async {
                self.currentUser = user
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
            }
        }
    }
    
    // 最終ログイン時刻の更新
    func updateLastLoginTime() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            try await db.collection("users").document(userId).updateData([
                "lastLoginAt": Date()
            ])
        } catch {
            DispatchQueue.main.async {
                self.error = error
            }
        }
    }
} 
