import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    var lastLoginAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case lastLoginAt
    }
} 
