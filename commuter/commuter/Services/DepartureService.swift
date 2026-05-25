
import Foundation

struct DepartureService: Sendable {
    let store: DepartureStore
    var fetchDepartures: @Sendable (String, CachePolicy) async throws -> Void
}

private let departuresTTL: TimeInterval = 60

extension DepartureService {
    @MainActor
    static func live(client: NetworkClient, baseURL: URL, cache: CacheServicing) -> DepartureService {
        let store = DepartureStore()
        
        return DepartureService(
            store: store,
            fetchDepartures: { stationID, policy in
                
                func fetchFromNetwork() async throws -> [Departure] {
                    let endpoint = baseURL.appendingPathComponent("departures")
                    var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)!
                    components.queryItems = [URLQueryItem(name: "station_id", value: stationID)]
                    guard let url = components.url else { throw URLError(.badURL) }
                    let apiModels = try await client.fetch([DepartureApiModel].self, from: url)
                    return apiModels.compactMap(\.domainModel)
                }
                
                func loadFromCache() async -> Bool {
                    guard let cached = await cache.getValue(CachedDepartures.self, id: stationID) else {
                        return false
                    }
                    await store.setDepartures(cached.departures, source: .cache)
                    return true
                }
                
                func fetchFreshAndStore() async throws {
                    let fresh = try await fetchFromNetwork()
                    await cache.set(
                        CachedDepartures(stationID: stationID, departures: fresh),
                        expiresIn: departuresTTL
                    )
                    await store.setDepartures(fresh, source: .network)
                }
                
                switch policy {
                case .cacheThenFetch:
                    let hadCache = await loadFromCache()
                    if !hadCache { await store.setLoading() }
                    do {
                        try await fetchFreshAndStore()
                    } catch {
                        if !hadCache { await store.setError(error)
                            throw error
                        }
                    }
                    
                case .cacheElseFetch:
                    if await loadFromCache() { return }
                    await store.setLoading()
                    do { try await fetchFreshAndStore() }
                    catch { await store.setError(error)
                        throw error
                    }
                    
                case .networkOnly:
                    await store.setLoading()
                    do { try await fetchFreshAndStore() }
                    catch { await store.setError(error)
                        throw error
                    }
                    
                case .cacheOnly:
                    if await loadFromCache() == false {
                        await store.setDepartures([], source: .cache)
                    }
                    
                case .networkElseCache:
                    await store.setLoading()
                    do {
                        try await fetchFreshAndStore()
                    } catch {
                        if await loadFromCache() == false {
                            await store.setError(error)
                            throw error
                        }
                    }
                }
            }
        )
    }
}
