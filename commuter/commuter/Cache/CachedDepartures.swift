
import Foundation

struct CachedDepartures: Cacheable {
    let stationID: String
    let departures: [Departure]
    
    var cacheID: String { stationID }
    static var cacheIdentifier: String { "departures" }
}
