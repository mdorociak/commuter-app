
import SwiftUI
import SwiftData

@main
struct commuterApp: App {
    private let departureService: DepartureService
    private let stopService: StopService
    
    init() {
        let baseURL = URL(string: "http://127.0.0.1:8000")!
        let client = NetworkClient.live()
        let cache: CacheServicing = TieredCache()
        
        departureService = .live(client: client, baseURL: baseURL, cache: cache)
        stopService = .live(client: client, baseURL: baseURL, cache: cache)
    }
        
    var body: some Scene {
        WindowGroup {
            RootView()
                .departureService(departureService)
                .stopService(stopService)
        }
        .modelContainer(for: FavoriteStop.self)
    }
}
