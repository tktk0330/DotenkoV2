import SwiftUI
import FirebaseStorage
import PhotosUI

struct ProfileMainView: View {
    
    @StateObject private var profileVM = UserProfileViewModel()
    @State private var isSEOn = true
    @State private var isSoundOn = true
    @State private var isVibrationOn = true
    @State private var selectedImage: UIImage?
    @State private var isUploading = false

    // PhotosPicker用
    @State private var photoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    
    var body: some View {
        BaseLayout {
            VStack(spacing: 20) {
                
                Spacer().frame(height: 100)
                
                // プロフィールアイコンとユーザー名
                HStack {
                    
                    
                    VStack(spacing: 16) {
                        // プロフィール画像表示
                        Group {
                            if let uiImage = profileVM.image {
                                Image(uiImage: uiImage)
                                    .resizable()
                            } else {
                                // デフォルトアイコン
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.gray)
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        .onTapGesture {
                            profileVM.isPickerPresented = true
                        }

                        if profileVM.isUploading {
                            ProgressView("アップロード中…")
                        }

                        if let error = profileVM.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .sheet(isPresented: $profileVM.isPickerPresented) {
                        ImagePicker(sourceType: .photoLibrary) { image in
                            profileVM.didSelectImage(image)
                        }
                    }
                    
                    
                    
                    
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
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
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
            }
            .padding(.horizontal)
        }
    }
}

struct SettingButton: View {
    let icon: String
    let title: String
    let isOn: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 50)
                Spacer()
                Text(title)
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(isOn ? Color(red: 32/255, green: 64/255, blue: 32/255) : Color.gray)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 8, y: 8)
        }
        .padding(.horizontal)
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
