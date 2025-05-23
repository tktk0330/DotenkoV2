import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Combine

class UserProfileViewModel: ObservableObject {
    private let repository = UserProfileRepository()
    private let db = Firestore.firestore()
    @Published var username: String = "名無しさん"
    @Published var isEditingName: Bool = false
    @Published var newUsername: String = ""
    
    @Published var image: UIImage?            // 画面に表示するローカル画像
    @Published var isPickerPresented = false  // ImagePicker 表示フラグ
    @Published var isUploading = false        // アップロード中フラグ
    @Published var errorMessage: String?      // エラー表示用
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadProfile()
    }
    
    private func loadProfile() {
        if let profile = repository.getOrCreateProfile() {
            username = profile.rmUserName
            // アイコンURLが存在する場合は画像をダウンロード
            if !profile.rmIconUrl.isEmpty {
                loadImageFromUrl(profile.rmIconUrl)
            }
        }
    }
    
    private func loadImageFromUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.errorMessage = "画像のダウンロードに失敗しました"
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.image = UIImage(data: data)
            }
        }.resume()
    }
    
    func updateUsername() {
        guard !newUsername.isEmpty else { return }
        if repository.updateUsername(newUsername) {
            username = newUsername
            isEditingName = false
            newUsername = ""
            
            // Firestoreも更新
            if let uid = Auth.auth().currentUser?.uid {
                db.collection("users").document(uid).updateData([
                    "name": username
                ]) { error in
                    if let error = error {
                        print("Firestore更新エラー: \(error)")
                    }
                }
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
    
    /// 画像を選択した後に呼ぶ
    func didSelectImage(_ uiImage: UIImage) {
        image = uiImage
        uploadImage(uiImage)
    }
    
    /// Firebase Storage にアップロード
    private func uploadImage(_ uiImage: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "ログインしていません"
            return
        }
        guard let data = uiImage.jpegData(compressionQuality: 0.8) else {
            errorMessage = "画像データ化に失敗"
            return
        }
        
        isUploading = true
        errorMessage = nil
        
        let ref = Storage.storage().reference()
            .child("profile_images/\(uid).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(data, metadata: metadata) { [weak self] meta, err in
            if let err = err {
                DispatchQueue.main.async {
                    self?.isUploading = false
                    self?.errorMessage = "アップロード失敗：\(err.localizedDescription)"
                }
                return
            }
            
            // ダウンロードURLを取得してユーザー情報を更新
            ref.downloadURL { [weak self] url, err in
                DispatchQueue.main.async {
                    self?.isUploading = false
                    
                    if let err = err {
                        self?.errorMessage = "URL取得失敗：\(err.localizedDescription)"
                        return
                    }
                    
                    guard let url = url else {
                        self?.errorMessage = "URLが取得できませんでした"
                        return
                    }
                    
                    // Realmに保存
                    _ = self?.repository.updateIconUrl(url.absoluteString)
                    
                    // Firestoreに保存
                    self?.db.collection("users").document(uid).updateData([
                        "icon_url": url.absoluteString
                    ]) { error in
                        if let error = error {
                            print("Firestore更新エラー: \(error)")
                        }
                    }
                }
            }
        }
    }
}
