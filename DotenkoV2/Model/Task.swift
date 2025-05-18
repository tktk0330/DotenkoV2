import Foundation
import RealmSwift

class Task: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var detail: String = ""
    @Persisted var isCompleted: Bool = false
    @Persisted var createdAt: Date = Date()
    
    convenience init(title: String, detail: String = "") {
        self.init()
        self.title = title
        self.detail = detail
    }
} 