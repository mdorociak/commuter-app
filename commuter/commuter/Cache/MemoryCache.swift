
import Foundation

actor MemoryCache: CacheServicing {
    
    private var storage: [String: [String: Any]] = [:]
    private var accessOrder: [String: [String]] = [:]
    private let maxItemsPerType: Int
    
    init(maxItemsPerType: Int = 100) {
        self.maxItemsPerType = maxItemsPerType
    }
    
    func get<T: Cacheable>(_ type: T.Type, id: String) async -> CacheEntry<T>? {
        let typeKey = T.cacheIdentifier
        guard let entry = storage[typeKey]?[id] as? CacheEntry<T> else {
            return nil
        }
        touch(typeKey: typeKey, id: id)
        return entry
    }
    
    func set<T: Cacheable>(_ value: T, expiresIn: TimeInterval?) async {
        let typeKey = T.cacheIdentifier
        let id = value.cacheID
        let entry = CacheEntry(
            value: value,
            cachedAt: Date(),
            expiresAt: expiresIn.map { Date().addingTimeInterval($0) }
        )
        storage[typeKey, default: [:]][id] = entry
        touch(typeKey: typeKey, id: id)
        evictIfNeeded(typeKey: typeKey)
    }
    
    func remove<T: Cacheable>(_ type: T.Type, id: String) async {
        let typeKey = T.cacheIdentifier
        storage[typeKey]?[id] = nil
        accessOrder[typeKey]?.removeAll { $0 == id }
    }
    
    func removeAll<T: Cacheable>(_ type: T.Type) async {
        let typeKey = T.cacheIdentifier
        storage[typeKey] = nil
        accessOrder[typeKey] = nil
    }
    
    func clear() async {
        storage.removeAll()
        accessOrder.removeAll()
    }
    
    private func touch(typeKey: String, id: String) {
        var order = accessOrder[typeKey] ?? []
        order.removeAll { $0 == id }
        order.append(id)
        accessOrder[typeKey] = order
    }
    
    private func evictIfNeeded(typeKey: String) {
        guard let order = accessOrder[typeKey], order.count > maxItemsPerType else {
            return
        }
        let removeCount = order.count - maxItemsPerType
        for id in order.prefix(removeCount) {
            storage[typeKey]?[id] = nil
        }
        accessOrder[typeKey] = Array(order.dropFirst(removeCount))
    }
}
