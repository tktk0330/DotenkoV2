import Foundation
import RealmSwift

class UserProfile: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var username: String = ""
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
    
    convenience init(username: String) {
        self.init()
        self.username = username
        self.createdAt = Date()
        self.updatedAt = Date()
    }
} 