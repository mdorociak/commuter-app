
import Foundation

enum LoadingState<T: Sendable>: Sendable {
    case idle
    case loading
    case loaded(T)
    case failed(Error)
    
    var value: T? {
        if case .loaded(let value) = self { return value }
        return nil
    }
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var error: Error? {
        if case .failed(let error) = self { return error }
        return nil
    }
}
