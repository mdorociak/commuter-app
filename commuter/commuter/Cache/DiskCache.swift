
import Foundation

actor DiskCache: CacheServicing {
    private let baseDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let fileManager = FileManager.default
    
    init(directory: URL? = nil) {
        if let directory {
            baseDirectory = directory
        } else {
            let caches = fileManager
                .urls(for: .cachesDirectory, in: .userDomainMask).first!
            baseDirectory = caches.appendingPathComponent("AppCache", isDirectory: true)
        }
    }
    
    func get<T: Cacheable>(_ type: T.Type, id: String) async -> CacheEntry<T>? {
        let url = fileURL(for: T.cacheIdentifier, id: id)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(CacheEntry<T>.self, from: data)
        } catch {
            try? fileManager.removeItem(at: url)
            return nil
        }
    }
    
    func set<T: Cacheable>(_ value: T, expiresIn: TimeInterval?) async {
        let entry = CacheEntry(
            value: value,
            cachedAt: Date(),
            expiresAt: expiresIn.map { Date().addingTimeInterval($0) }
        )
        let directory = typeDirectory(for: T.cacheIdentifier)
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try encoder.encode(entry)
            try data.write(to: fileURL(for: T.cacheIdentifier, id: value.cacheID), options: .atomic)
        } catch {
            // silent fail, should be logged
        }
    }
    
    func remove<T: Cacheable>(_ type: T.Type, id: String) async {
        try? fileManager.removeItem(at: fileURL(for: T.cacheIdentifier, id: id))
    }
    
    func removeAll<T: Cacheable>(_ type: T.Type) async {
        try? fileManager.removeItem(at: typeDirectory(for: T.cacheIdentifier))
    }
    
    func clear() async {
        try? fileManager.removeItem(at: baseDirectory)
    }
    
    private func typeDirectory(for typeKey: String) -> URL {
        baseDirectory.appendingPathComponent(typeKey, isDirectory: true)
    }
    
    private func fileURL(for typeKey: String, id: String) -> URL {
        typeDirectory(for: typeKey).appendingPathComponent("\(id).json")
    }
}
