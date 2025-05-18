import Foundation
import SwiftUI

class UserProfileViewModel: ObservableObject {
    private let repository = UserProfileRepository()
    @Published var username: String = "名無しさん"
    @Published var isEditingName: Bool = false
    @Published var newUsername: String = ""
    
    init() {
        loadProfile()
    }
    
    private func loadProfile() {
        if let profile = repository.getOrCreateProfile() {
            username = profile.username
        }
    }
    
    func updateUsername() {
        guard !newUsername.isEmpty else { return }
        if repository.updateUsername(newUsername) {
            username = newUsername
            isEditingName = false
            newUsername = ""
        }
    }
    
    func startEditing() {
        newUsername = username
        isEditingName = true
    }
    
    func cancelEditing() {
        isEditingName = false
        newUsername = ""
    }
} 