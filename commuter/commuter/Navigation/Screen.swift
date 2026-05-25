
import Foundation

enum Screen: Hashable {
    case commute(CommuteScreen)
    case explore(ExploreScreen)
    case saved(SavedScreen)
    case alerts(AlertsScreen)
    
    enum CommuteScreen: Hashable {
        case root
    }
    enum ExploreScreen: Hashable {
        case root
    }
    enum SavedScreen: Hashable {
        case root
    }
    enum AlertsScreen: Hashable {
        case root
    }
    
}
