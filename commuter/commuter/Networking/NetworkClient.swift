
import Foundation

struct NetworkClient: Sendable {
    var data: @Sendable (URL) async throws -> Data
    
    func fetch<T: Decodable>(
        _ type: T.Type,
        from url: URL,
        decoder: JSONDecoder = .api
    ) async throws -> T {
        let bytes = try await data(url)
        return try decoder.decode(type, from: bytes)
    }
}

extension NetworkClient {
    static func live() -> NetworkClient {
        NetworkClient(data: { url in
            let (bytes, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            guard(200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            return bytes
        })
    }
}
