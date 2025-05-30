import Foundation
import SwiftUI
import CryptoKit
import Combine

// MARK: - Image Cache Manager
class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let maxCacheAge: TimeInterval = 7 * 24 * 60 * 60 // 1週間
    private let maxCacheSize: Int = 100 * 1024 * 1024 // 100MB
    
    private init() {
        // キャッシュディレクトリの設定
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cacheDir.appendingPathComponent("ImageCache")
        
        // ディレクトリが存在しない場合は作成
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        // メモリキャッシュの設定
        memoryCache.countLimit = 50 // 最大50枚
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // 起動時に古いキャッシュをクリーンアップ
        cleanupExpiredCache()
    }
    
    // 画像をキャッシュから取得
    func cachedImage(for urlString: String) -> UIImage? {
        let cacheKey = cacheKey(from: urlString)
        
        // メモリキャッシュから確認
        if let memoryImage = memoryCache.object(forKey: cacheKey as NSString) {
            return memoryImage
        }
        
        // ディスクキャッシュから確認
        let fileURL = cacheDirectory.appendingPathComponent(cacheKey)
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        // メモリキャッシュにも保存
        memoryCache.setObject(image, forKey: cacheKey as NSString)
        return image
    }
    
    // 画像をキャッシュに保存
    func cacheImage(_ image: UIImage, for urlString: String) {
        let cacheKey = cacheKey(from: urlString)
        
        // メモリキャッシュに保存
        memoryCache.setObject(image, forKey: cacheKey as NSString)
        
        // ディスクキャッシュに保存
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self,
                  let data = image.jpegData(compressionQuality: 0.8) else { return }
            
            let fileURL = self.cacheDirectory.appendingPathComponent(cacheKey)
            try? data.write(to: fileURL)
            
            // キャッシュサイズをチェック
            self.manageCacheSize()
        }
    }
    
    // URLからキャッシュキーを生成
    private func cacheKey(from urlString: String) -> String {
        let data = Data(urlString.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // 期限切れキャッシュのクリーンアップ
    private func cleanupExpiredCache() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let files = try self.fileManager.contentsOfDirectory(at: self.cacheDirectory, includingPropertiesForKeys: [.creationDateKey])
                let now = Date()
                
                for file in files {
                    let attributes = try self.fileManager.attributesOfItem(atPath: file.path)
                    if let creationDate = attributes[.creationDate] as? Date,
                       now.timeIntervalSince(creationDate) > self.maxCacheAge {
                        try? self.fileManager.removeItem(at: file)
                    }
                }
            } catch {
                print("キャッシュクリーンアップエラー: \(error)")
            }
        }
    }
    
    // キャッシュサイズの管理
    private func manageCacheSize() {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey, .creationDateKey])
            let totalSize = files.compactMap { url -> (URL, Int, Date)? in
                guard let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize,
                      let date = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate else {
                    return nil
                }
                return (url, size, date)
            }
            
            let currentSize = totalSize.reduce(0) { $0 + $1.1 }
            
            if currentSize > maxCacheSize {
                // 古いファイルから削除
                let sortedFiles = totalSize.sorted { $0.2 < $1.2 }
                var deletedSize = 0
                
                for file in sortedFiles {
                    try? fileManager.removeItem(at: file.0)
                    deletedSize += file.1
                    
                    if currentSize - deletedSize <= maxCacheSize * 3 / 4 { // 75%まで削減
                        break
                    }
                }
            }
        } catch {
            print("キャッシュサイズ管理エラー: \(error)")
        }
    }
    
    // キャッシュをクリア
    func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // キャッシュ統計情報を取得
    func getCacheInfo() -> (memoryCount: Int, diskSize: Int64) {
        let memoryCount = memoryCache.countLimit
        
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            let diskSize = files.compactMap { url in
                try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize
            }.reduce(0, +)
            
            return (memoryCount, Int64(diskSize))
        } catch {
            return (memoryCount, 0)
        }
    }
}

// MARK: - Enhanced Image Loader
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    private let cacheManager = ImageCacheManager.shared
    
    func loadImage(from urlString: String) {
        // 既にロード中の場合は重複実行を防ぐ
        guard !isLoading else { return }
        
        // まずキャッシュから確認
        if let cachedImage = cacheManager.cachedImage(for: urlString) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }
        
        // キャッシュにない場合はネットワークから取得
        guard let url = URL(string: urlString) else {
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("画像ロードエラー: \(error)")
                    }
                },
                receiveValue: { [weak self] image in
                    guard let self = self, let image = image else { return }
                    
                    self.image = image
                    // 取得した画像をキャッシュに保存
                    self.cacheManager.cacheImage(image, for: urlString)
                }
            )
            .store(in: &cancellables)
    }
    
    // 画像をプリロード（表示せずにキャッシュのみ）
    func preloadImage(from urlString: String) {
        guard cacheManager.cachedImage(for: urlString) == nil,
              let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .receive(on: DispatchQueue.global(qos: .background))
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] image in
                    guard let image = image else { return }
                    self?.cacheManager.cacheImage(image, for: urlString)
                }
            )
            .store(in: &cancellables)
    }
} 