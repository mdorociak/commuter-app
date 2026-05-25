
import SwiftUI
import SwiftData

struct RootView: View {
    @State private var selectedTab: Tab = .commute
    
    @State private var commutePath: [Screen] = []
    @State private var explorePath: [Screen] = []
    @State private var savedPath: [Screen] = []
    @State private var alertsPath: [Screen] = []
    
    enum Tab {
        case commute, explore, saved, alerts
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $commutePath) {
                DashboardView()
                    .screenDestination()
            }
            .tabItem { Label("Commute", systemImage: "tram.fill") }
            .tag(Tab.commute)
            
            NavigationStack(path: $explorePath) {
                ExploreView()
                    .screenDestination()
            }
            .tabItem { Label("Explore", systemImage: "map") }
            .tag(Tab.explore)
            
            NavigationStack(path: $savedPath) {
                SavedView()
                    .screenDestination()
            }
            .tabItem { Label("Saved", systemImage: "bookmark") }
            .tag(Tab.saved)
            
            NavigationStack(path: $alertsPath) {
                AlertsView()
                    .screenDestination()
            }
            .tabItem { Label("Alerts", systemImage: "bell") }
            .tag(Tab.alerts)
        }
    }
}

#Preview {
    RootView()
        .departureService(.preview)
        .stopService(.preview)
        .modelContainer(for: FavoriteStop.self, inMemory: true)
}
