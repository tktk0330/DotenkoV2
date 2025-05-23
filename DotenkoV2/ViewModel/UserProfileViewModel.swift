import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Combine

/// プロフィール更新の状態を表す列挙型
enum ProfileUpdateState {
    case idle
    case loading
    case success
    case error(String)
}

class UserProfileViewModel: ObservableObject {
    private let repository = UserProfileRepository()
    private let db = Firestore.firestore()
    
    // MARK: - Published Properties
    @Published var username: String = "名無しさん"
    @Published var isEditingName: Bool = false
    @Published var newUsername: String = ""
    @Published var image: UIImage?            // 画面に表示するローカル画像
    @Published var isPickerPresented = false  // ImagePicker 表示フラグ
    @Published var updateState: ProfileUpdateState = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        loadProfile()
    }
    
    // MARK: - Profile Loading
    private func loadProfile() {
        switch repository.getOrCreateProfile() {
        case .success(let profile):
            username = profile.rmUserName
            if !profile.rmIconUrl.isEmpty {
                loadImageFromUrl(profile.rmIconUrl)
            }
        case .failure(let error):
            updateState = .error("プロフィールの読み込みに失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func loadImageFromUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            updateState = .error("無効なURL形式です")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.updateState = .error("画像のダウンロードに失敗しました")
                    }
                },
                receiveValue: { [weak self] image in
                    self?.image = image
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Username Management
    func updateUsername() {
        guard !newUsername.isEmpty else { return }
        
        updateState = .loading
        switch repository.updateUsername(newUsername) {
        case .success:
            username = newUsername
            isEditingName = false
            newUsername = ""
            updateFirestoreUsername()
            updateState = .success
            
        case .failure(let error):
            updateState = .error("ユーザー名の更新に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func updateFirestoreUsername() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).updateData([
            "name": username
        ]) { [weak self] error in
            if let error = error {
                self?.updateState = .error("Firestoreの更新に失敗しました: \(error.localizedDescription)")
            }
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
    
    // MARK: - Image Management
    func didSelectImage(_ uiImage: UIImage) {
        image = uiImage
        uploadImage(uiImage)
    }
    
    private func uploadImage(_ uiImage: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else {
            updateState = .error("ログインしていません")
            return
        }
        
        guard let data = uiImage.jpegData(compressionQuality: 0.8) else {
            updateState = .error("画像データの変換に失敗しました")
            return
        }
        
        updateState = .loading
        
        let ref = Storage.storage().reference()
            .child("profile_images/\(uid).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        uploadImageToStorage(data: data, ref: ref, metadata: metadata)
    }
    
    private func uploadImageToStorage(data: Data, ref: StorageReference, metadata: StorageMetadata) {
        ref.putData(data, metadata: metadata) { [weak self] meta, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.updateState = .error("アップロードに失敗しました: \(error.localizedDescription)")
                }
                return
            }
            
            self?.getDownloadURL(ref: ref)
        }
    }
    
    private func getDownloadURL(ref: StorageReference) {
        ref.downloadURL { [weak self] url, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.updateState = .error("URLの取得に失敗しました: \(error.localizedDescription)")
                    return
                }
                
                guard let url = url else {
                    self?.updateState = .error("URLが取得できませんでした")
                    return
                }
                
                self?.updateProfileWithNewImageURL(url.absoluteString)
            }
        }
    }
    
    private func updateProfileWithNewImageURL(_ urlString: String) {
        switch repository.updateIconUrl(urlString) {
        case .success:
            if let uid = Auth.auth().currentUser?.uid {
                updateFirestoreIconUrl(uid: uid, urlString: urlString)
            }
            updateState = .success
            
        case .failure(let error):
            updateState = .error("プロフィールの更新に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func updateFirestoreIconUrl(uid: String, urlString: String) {
        db.collection("users").document(uid).updateData([
            "icon_url": urlString
        ]) { [weak self] error in
            if let error = error {
                self?.updateState = .error("Firestoreの更新に失敗しました: \(error.localizedDescription)")
            }
        }
    }
}
