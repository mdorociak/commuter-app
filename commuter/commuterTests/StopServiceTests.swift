
import Testing
import Foundation
@testable import commuter

@MainActor
struct StopServiceTests {

    private let sampleJSON = Data(#"""
    [{"id":"2246799","name":"Brzeg","code":"11","lat":50.852881,"lon":17.470911,"platforms":[{"id":"2333170","code":"II"}]}]
    """#.utf8)

    private func service(client: NetworkClient, cache: CacheServicing) -> StopService {
        .live(client: client, baseURL: URL(string: "http://example.com")!, cache: cache)
    }

    @Test func decodesStationIgnoringUnusedFields() throws {
        let models = try JSONDecoder.api.decode([StationApiModel].self, from: sampleJSON)
        #expect(models.first?.name == "Brzeg")
    }

    @Test func networkOnlySearchDecodesMapsAndStores() async throws {
        let svc = service(client: NetworkClient(data: { _ in self.sampleJSON }), cache: MemoryCache())
        try await svc.search("brzeg", .networkOnly)
        #expect(svc.store.stations.first?.name == "Brzeg")
        #expect(svc.store.dataSource == .network)
    }

    @Test func fullListIsCachedAndServedOffline() async throws {
        let cache = MemoryCache()

        let online = service(client: NetworkClient(data: { _ in self.sampleJSON }), cache: cache)
        try await online.search("", .cacheThenFetch)
        #expect(online.store.stations.count == 1)

        struct Boom: Error {}
        let offline = service(client: NetworkClient(data: { _ in throw Boom() }), cache: cache)
        try await offline.search("", .cacheElseFetch)
        #expect(offline.store.stations.count == 1)
        #expect(offline.store.dataSource == .cache)
    }

    @Test func searchQueryRecordsErrorWhenNetworkFails() async {
        struct Boom: Error {}
        let svc = service(client: NetworkClient(data: { _ in throw Boom() }), cache: MemoryCache())
        do {
            try await svc.search("brzeg", .networkOnly)
            Issue.record("expected search to throw")
        } catch {
            // silent fail, should be logged
        }
        #expect(svc.store.loadingState.error != nil)
    }
}
