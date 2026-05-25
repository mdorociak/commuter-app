
import SwiftUI

struct DestinationContent {
    
    @ViewBuilder
    static func content(for screen: Screen) -> some View {
        switch screen {
        case .commute(let screen):
            switch screen {
            case .root: DashboardView()
            }
        case .explore(let screen):
            switch screen {
            case .root: ExploreView()
            }
        case .saved(let screen):
            switch screen {
            case .root: SavedView()
            }
        case .alerts(let screen):
            switch screen {
            case .root: AlertsView()
            }
        }
    }
}

extension View {
    func screenDestination() -> some View {
        navigationDestination(for: Screen.self) { screen in
            DestinationContent.content(for: screen)
        }
    }
}
