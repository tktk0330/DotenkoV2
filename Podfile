# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'DotenkoV2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DotenkoV2

  # Google Mobile Ads SDKの追加
  pod 'Google-Mobile-Ads-SDK'

  # Realmの追加
  pod 'RealmSwift'

  # Firebase
  pod 'FirebaseAnalytics'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseStorage'
  pod 'FirebaseMessaging'
  pod 'FirebaseDatabase'  # Realtime Database
  pod 'FirebaseFunctions'
  pod 'FirebaseFirestoreSwift'
  pod 'Firebase/Storage'

  target 'DotenkoV2Tests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'DotenkoV2UITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end
end
