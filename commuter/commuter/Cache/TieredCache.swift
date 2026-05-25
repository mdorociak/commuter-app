
import Foundation

struct TieredCache: CacheServicing, Sendable {
    private let memory: MemoryCache
    private let disk: DiskCache
    
    init(memory: MemoryCache = MemoryCache(), disk: DiskCache = DiskCache()) {
        self.memory = memory
        self.disk = disk
    }
    
    func get<T: Cacheable>(_ type: T.Type, id: String) async -> CacheEntry<T>? {
        if let entry = await memory.get(type, id: id) {
            return entry
        }
        if let entry = await disk.get(type, id: id) {
            await memory.set(entry.value, expiresIn: entry.expiresAt.map { $0.timeIntervalSinceNow })
            return entry
        }
        return nil
    }
    
    func set<T: Cacheable>(_ value: T, expiresIn: TimeInterval?) async {
        await memory.set(value, expiresIn: expiresIn)
        await disk.set(value, expiresIn: expiresIn)
    }
    
    func remove<T: Cacheable>(_ type: T.Type, id: String) async {
        await memory.remove(type, id: id)
        await disk.remove(type, id: id)
    }
    
    func removeAll<T: Cacheable>(_ type: T.Type) async {
        await memory.removeAll(type)
        await disk.removeAll(type)
    }
    
    func clear() async {
        await memory.clear()
        await disk.clear()
    }
}
