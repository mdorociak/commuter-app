
import Foundation

struct StationApiModel: ApiModel {
    let id: String?
    let name: String?
    let code: String?
}

extension StationApiModel {
    var domainModel: Station? {
        guard let id, let name else { return nil }
        return Station(id: id, name: name, code: code)
    }
}
