import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import Combine

class UserProfileViewModel: ObservableObject {
    private let repository = UserProfileRepository()
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
               DispatchQueue.main.async {
                   self?.isUploading = false
                   if let err = err {
                       self?.errorMessage = "アップロード失敗：\(err.localizedDescription)"
                   } else {
                       // 必要ならダウンロードURLを取得してユーザー情報に保存する
                       ref.downloadURL { url, err in
                           if let url = url {
                               print("Download URL: \(url.absoluteString)")
                               // 例: Firestore の users コレクションに保存する、など
                           }
                       }
                   }
               }
           }
       }
}
