
import SwiftUI

extension EnvironmentValues {
    @Entry var departureService: DepartureService = .unimplemented
    @Entry var stopService: StopService = .unimplemented
}

extension View {
    func departureService(_ service: DepartureService) -> some View {
        environment(\.departureService, service)
    }
    
    func stopService(_ service: StopService) -> some View {
        environment(\.stopService, service)
    }
}
