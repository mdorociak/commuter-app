
import Foundation

struct DepartureApiModel: ApiModel {
    let line: String?
    let destination: String?
    let departureTime: Date?
    let platform: String?
    
    enum CodingKeys: String, CodingKey {
        case line
        case destination
        case departureTime = "departure_time"
        case platform
    }
}

extension DepartureApiModel {
    var domainModel: Departure? {
        guard let line, !line.isEmpty, let departureTime else {
            return nil
        }
        return Departure(
            id: "\(line)|\(departureTime.timeIntervalSinceReferenceDate)|\(platform ?? "")",
            line: line,
            destination: destination,
            departureTime: departureTime,
            platform: platform
        )
    }
}
