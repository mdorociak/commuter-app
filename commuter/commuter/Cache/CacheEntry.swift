
import Foundation

struct CacheEntry<T: Cacheable>: Codable, Sendable {
    let value: T
    let cachedAt: Date
    let expiresAt: Date?
    
    var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date() > expiresAt
    }
    
    var age: TimeInterval {
        Date().timeIntervalSince(cachedAt)
    }
}
