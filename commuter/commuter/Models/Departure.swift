
import Foundation

struct Departure: DomainModel, Identifiable {
    let id: String
    let line: String
    let destination: String?
    let departureTime: Date
    let platform: String?
}
