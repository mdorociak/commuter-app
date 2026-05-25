
import Foundation

struct Station: DomainModel, Identifiable {
    let id: String
    let name: String
    let code: String?
}

extension Station: Cacheable {
    var cacheID: String { id }
    static var cacheIdentifier: String { "stations"}
}
