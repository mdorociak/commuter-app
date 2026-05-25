
import Foundation

protocol Cacheable: Codable, Sendable {
    var cacheID: String { get }
    static var cacheIdentifier: String { get }
}

extension Array: Cacheable where Element: Cacheable {
    var cacheID: String { Self.cacheIdentifier }
    static var cacheIdentifier: String { "\(Element.cacheIdentifier)-array" }
}
