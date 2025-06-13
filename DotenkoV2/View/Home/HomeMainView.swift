import SwiftUI
import FirebaseStorage
import PhotosUI

struct HomeMainView: View {
    @EnvironmentObject private var navigator: NavigationStateManager
    @StateObject private var profileVM = UserProfileViewModel()
    
    var body: some View {
        BaseLayout {
            // メインコンテンツ
            VStack(spacing: 16) {
                
                Spacer().frame(height: 30)
                
                // プロフィールアイコンとユーザー名
                ProfileSectionView(profileVM: profileVM)
                
                // ゲームモード選択ボタン
                GameModeButtonsView()
                
                Spacer(minLength: 40)
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
