
import Foundation

struct StopService: Sendable {
    let store: StopStore
    var search: @Sendable (String, CachePolicy) async throws -> Void
}

private let stopsTTL: TimeInterval = 60 * 60 * 24

extension StopService {
    static func live(
        client: NetworkClient,
        baseURL: URL,
        cache: CacheServicing
    ) -> StopService {
        let store = StopStore()

        return StopService(
            store: store,
            search: { query, policy in

                let isFullList = query.isEmpty
                let cacheID = [Station].cacheIdentifier

                func fetchFromNetwork() async throws -> [Station] {
                    let endpoint = baseURL.appendingPathComponent("stops")
                    var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)!
                    if !query.isEmpty {
                        components.queryItems = [URLQueryItem(name: "search", value: query)]
                    }
                    guard let url = components.url else { throw URLError(.badURL) }
                    let apiModels = try await client.fetch([StationApiModel].self, from: url)
                    return apiModels.compactMap(\.domainModel)
                }

                func loadFromCache() async -> Bool {
                    guard isFullList,
                          let cached = await cache.getValue([Station].self, id: cacheID) else {
                        return false
                    }
                    await store.setStations(cached, source: .cache)
                    return true
                }

                func fetchFreshAndStore() async throws {
                    let fresh = try await fetchFromNetwork()
                    if isFullList {
                        await cache.set(fresh, expiresIn: stopsTTL)
                    }
                    await store.setStations(fresh, source: .network)
                }

                switch policy {
                case .cacheThenFetch:
                    let hadCache = await loadFromCache()
                    if !hadCache { await store.setLoading() }
                    do {
                        try await fetchFreshAndStore()
                    } catch {
                        if !hadCache { await store.setError(error); throw error }
                    }

                case .cacheElseFetch:
                    if await loadFromCache() { return }
                    await store.setLoading()
                    do { try await fetchFreshAndStore() }
                    catch { await store.setError(error); throw error }

                case .networkOnly:
                    await store.setLoading()
                    do { try await fetchFreshAndStore() }
                    catch { await store.setError(error); throw error }

                case .cacheOnly:
                    if await loadFromCache() == false {
                        await store.setStations([], source: .cache)
                    }

                case .networkElseCache:
                    await store.setLoading()
                    do {
                        try await fetchFreshAndStore()
                    } catch {
                        if await loadFromCache() == false {
                            await store.setError(error); throw error
                        }
                    }
                }
            }
        )
    }
}
