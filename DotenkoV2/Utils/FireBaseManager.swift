import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore

class FireBaseManager {
    static let shared = FireBaseManager()
    private let db = Firestore.firestore()
    private init() {}
    
    func signInAnonymously() async throws -> AuthDataResult {
        return try await Auth.auth().signInAnonymously()
    }
    
    var currentAuthUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    func getCurrentUser() async throws -> User? {
        guard let authUser = currentAuthUser else { return nil }
        
        let document = try await db.collection("users").document(authUser.uid).getDocument()
        if document.exists {
            return try document.data(as: User.self)
        } else {
            // ユーザーが存在しない場合は新規作成
            let newUser = User(
                name: "Anonymous User",
                lastLoginAt: Date()
            )
            try db.collection("users").document(authUser.uid).setData(from: newUser)
            var createdUser = newUser
            createdUser.id = authUser.uid
            return createdUser
        }
    }
}
