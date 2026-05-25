
import Foundation

@MainActor
@Observable
final class DepartureStore {
    private(set) var departures: [Departure] = []
    private(set) var dataSource: DataSource?
    private(set) var lastUpdated: Date?
    private(set) var loadingState: LoadingState<[Departure]> = .idle
    
    var isShowingCachedData: Bool { dataSource == .cache }
    
    nonisolated init() {}
    
    func setLoading() { loadingState = .loading }
    
    func setDepartures(_ departures: [Departure], source: DataSource) {
        self.departures = departures
        self.dataSource = source
        self.lastUpdated = Date()
        loadingState = .loaded(departures)
    }
    
    func setError(_ error: Error) {
        loadingState = .failed(error)
    }
}
