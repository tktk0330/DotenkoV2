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
                VStack(spacing: 32) {
                    ZStack {
                        // プロフィール画像表示
                        Group {
                            if let uiImage = profileVM.image {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                // デフォルトアイコン
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(20)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipped()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .onTapGesture {
                            profileVM.isPickerPresented = true
                        }

                        if case .loading = profileVM.updateState {
                            ProgressView("アップロード中…")
                        }

                        if case .error(let message) = profileVM.updateState {
                            Text(message)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .sheet(isPresented: $profileVM.isPickerPresented) {
                        ImagePicker(sourceType: .photoLibrary) { image in
                            profileVM.didSelectImage(image)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        if profileVM.isEditingName {
                            // 名前編集モード
                            TextField("名前を入力", text: $profileVM.newUsername)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(Font(Appearance.Font.body))
                                .frame(width: 150)
                            
                            // 保存/キャンセルボタン
                            HStack(spacing: 8) {
                                Button(action: profileVM.updateUsername) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                                
                                Button(action: profileVM.cancelEditing) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        } else {
                            // 表示モード
                            Text(profileVM.username)
                                .font(Font(Appearance.Font.casinoHeading))
                                .foregroundColor(.white)
                            
                            // 編集ボタン
                            Button(action: profileVM.startEditing) {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(Color(uiColor: Appearance.Color.goldenYellow))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
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
