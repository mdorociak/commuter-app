import Testing
import Foundation
@testable import commuter

@MainActor
struct DepartureServiceTests {

    private let sampleJSON = Data(#"""
    [{"line":"D5","destination":"Wrocław Główny","departure_time":"2026-05-21T18:39:00+02:00","platform":"II"}]
    """#.utf8)

    private func sampleDeparture() -> Departure {
        Departure(id: "x", line: "D5", destination: "Wrocław Główny",
                  departureTime: Date(timeIntervalSinceReferenceDate: 0), platform: "II")
    }

    private func service(client: NetworkClient, cache: CacheServicing) -> DepartureService {
        .live(client: client, baseURL: URL(string: "http://example.com")!, cache: cache)
    }

    @Test func decodesIso8601DepartureTime() throws {
        let models = try JSONDecoder.api.decode([DepartureApiModel].self, from: sampleJSON)
        #expect(models.first?.departureTime != nil)
    }

    @Test func networkOnlyDecodesMapsAndStores() async throws {
        let svc = service(client: NetworkClient(data: { _ in self.sampleJSON }), cache: MemoryCache())
        try await svc.fetchDepartures("2246799", .networkOnly)
        #expect(svc.store.departures.first?.line == "D5")
        #expect(svc.store.dataSource == .network)
    }

    @Test func cacheElseFetchUsesCacheAndSkipsNetwork() async throws {
        let cache = MemoryCache()
        await cache.set(CachedDepartures(stationID: "S", departures: [sampleDeparture()]), expiresIn: nil)

        struct Boom: Error {}
        let svc = service(client: NetworkClient(data: { _ in throw Boom() }), cache: cache)

        try await svc.fetchDepartures("S", .cacheElseFetch)
        #expect(svc.store.departures.count == 1)
        #expect(svc.store.dataSource == .cache)
    }

    @Test func networkElseCacheFallsBackToCacheOnFailure() async throws {
        let cache = MemoryCache()
        await cache.set(CachedDepartures(stationID: "S", departures: [sampleDeparture()]), expiresIn: nil)

        struct Boom: Error {}
        let svc = service(client: NetworkClient(data: { _ in throw Boom() }), cache: cache)

        try await svc.fetchDepartures("S", .networkElseCache)
        #expect(svc.store.dataSource == .cache)
        #expect(svc.store.departures.count == 1)
    }

    @Test func networkElseCacheThrowsWhenNetworkFailsAndCacheEmpty() async {
        struct Boom: Error {}
        let svc = service(client: NetworkClient(data: { _ in throw Boom() }), cache: MemoryCache())

        do {
            try await svc.fetchDepartures("S", .networkElseCache)
            Issue.record("expected fetchDepartures to throw")
        } catch {
            // expected
        }
        #expect(svc.store.loadingState.error != nil)
    }
}
