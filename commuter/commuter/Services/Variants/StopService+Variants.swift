
import Foundation

extension StopService {
    static var unimplemented: StopService {
        StopService(
            store: StopStore(),
            search: { _, _ in fatalError("StopService.search not implemented") }
        )
    }
    
    static var preview: StopService {
        let store = StopStore()
        Task { @MainActor in store.setStations(Station.sampleData, source: .network) }
        return StopService(store: store, search: { _, _ in })
    }
}
