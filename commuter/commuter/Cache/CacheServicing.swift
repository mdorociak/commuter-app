
import Foundation

protocol CacheServicing: Sendable {
    func get<T: Cacheable>(_ type: T.Type, id: String) async -> CacheEntry<T>?
    func set<T: Cacheable>(_ value: T, expiresIn: TimeInterval?) async
    func remove<T: Cacheable>(_ type: T.Type, id: String) async
    func removeAll<T: Cacheable>(_ type: T.Type) async
    func clear() async
}

extension CacheServicing {
    func getValue<T: Cacheable>(_ type: T.Type, id: String) async -> T? {
        guard let entry = await get(type, id: id) else { return nil }
        guard !entry.isExpired else {
            await remove(type, id: id)
            return nil
        }
        return entry.value
    }
}
