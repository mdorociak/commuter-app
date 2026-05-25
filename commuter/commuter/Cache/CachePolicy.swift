
import Foundation

enum CachePolicy: Sendable {
    case cacheThenFetch
    case cacheElseFetch
    case networkOnly
    case cacheOnly
    case networkElseCache
}
