
import Foundation

extension DepartureService {
    
    static var unimplemented: DepartureService {
        DepartureService(
            store: DepartureStore(),
            fetchDepartures: { _, _ in fatalError("DepartureService.fetchDepartures not implemented") }
        )
    }
    
    static var mock: DepartureService {
        let store = DepartureStore()
        return DepartureService(
            store: store,
            fetchDepartures: { _, _ in
                await store.setLoading()
                try await Task.sleep(for: .milliseconds(600))
                await store.setDepartures(Departure.sampleData, source: .network)
            }
        )
    }
    
    static var preview: DepartureService {
        let store = DepartureStore()
        Task { @MainActor in store.setDepartures(Departure.sampleData, source: .network) }
        return DepartureService(
            store: store,
            fetchDepartures: { _, _ in }
        )
    }
}
