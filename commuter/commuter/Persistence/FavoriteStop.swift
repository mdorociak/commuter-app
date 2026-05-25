
import Foundation
import SwiftData

@Model
final class FavoriteStop {
    @Attribute(.unique) var stopID: String
    var name: String
    var dateAdded: Date
    
    init(stopID: String, name: String, dateAdded: Date = .now) {
        self.stopID = stopID
        self.name = name
        self.dateAdded = dateAdded
    }
}
