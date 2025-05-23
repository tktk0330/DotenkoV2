import SwiftUI
import FirebaseStorage
import PhotosUI

struct HomeMainView: View {
    @EnvironmentObject private var navigator: NavigationStateManager
    @StateObject private var profileVM = UserProfileViewModel()
    @State private var isSEOn = true
    @State private var isSoundOn = true
    @State private var isVibrationOn = true
    
    var body: some View {
        BaseLayout {
            // メインコンテンツ
            VStack(spacing: 16) {
                
                Spacer().frame(height: 80)
                
                // プロフィールアイコンとユーザー名
                ProfileSectionView(profileVM: profileVM)
                
                // ゲームモード選択ボタン
                VStack(spacing: 16) {
                    // 個人戦ボタン
                    GameModeButton(
                        title: "個人戦",
                        backgroundImage: Appearance.Image.GameMode.singlePlayButton,
                        action: { navigator.push(Menu1View()) }
                    )
                    
                    // 友人戦ボタン
                    GameModeButton(
                        title: "友人戦",
                        backgroundImage: Appearance.Image.GameMode.friendPlayButton,
                        action: { navigator.push(GameRuleView()) }
                    )
                }
                .padding(.horizontal, 30)
                
                VStack(spacing: 32) {
                    SettingButton(
                        icon: "music.note",
                        title: "SE",
                        isOn: isSEOn,
                        onToggle: { isSEOn.toggle() }
                    )
                    SettingButton(
                        icon: "speaker.wave.2",
                        title: "Sound",
                        isOn: isSoundOn,
                        onToggle: { isSoundOn.toggle() }
                    )
                    SettingButton(
                        icon: "iphone.radiowaves.left.and.right",
                        title: "Vibration",
                        isOn: isVibrationOn,
                        onToggle: { isVibrationOn.toggle() }
                    )
                }
                .padding(.top, 40)
                
                Spacer(minLength: 40)
            }
            
        }
    }
}

func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        completion(.failure(NSError(domain: "ImageConversion", code: -1, userInfo: nil)))
        return
    }
    let storage = Storage.storage()
    let fileName = "profileIcons/\(UUID().uuidString).jpg"
    let ref = storage.reference().child(fileName)
    
    ref.putData(imageData, metadata: nil) { metadata, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        ref.downloadURL { url, error in
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                completion(.success(url))
            }
        }
    }
}


// UIKit の UIImagePickerController をラップ
struct ImagePicker: UIViewControllerRepresentable {
    enum Source { case photoLibrary, camera }
    var sourceType: Source = .photoLibrary
    var onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType == .camera ? .camera : .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
