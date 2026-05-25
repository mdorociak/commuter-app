
import Foundation

@MainActor
@Observable
final class StopStore {
    private(set) var stations: [Station] = []
    private(set) var dataSource: DataSource?
    private(set) var loadingState: LoadingState<[Station]> = .idle
    
    var isShowingCachedData: Bool { dataSource == .cache }
    
    nonisolated init() {}
    
    func setLoading() { loadingState = .loading }
    
    func setStations(_ stations: [Station], source: DataSource) {
        self.stations = stations
        self.dataSource = source
        loadingState = .loaded(stations)
    }
    
    func setError(_ error: Error) { loadingState = .failed(error) }
}
