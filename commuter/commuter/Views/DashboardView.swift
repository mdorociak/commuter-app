
import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.departureService) private var departureService
    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [FavoriteStop]
        
    @AppStorage("selectedStationID") private var stationID = "2246799"
    @AppStorage("selectedStationName") private var stationName = "Brzeg"
    
    @State private var showingPicker: Bool = false
    
    private var store: DepartureStore { departureService.store }
    private var isFavorited: Bool {
        favorites.contains { $0.stopID == stationID }
    }
        
    var body: some View {
        Group {
            switch store.loadingState {
            case .idle, .loading:
                ProgressView("Loading departures...")
            case .failed(let error):
                ContentUnavailableView(
                    "Couldn't load departures.",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
            case .loaded:
                departureList
            }
        }
        .navigationTitle(stationName)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { showingPicker = true } label: {
                    Label("Change Station", systemImage: "magnifyingglass")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorited ? "star.fill" : "star")
                }
                .accessibilityLabel(isFavorited ? "Remove from favorites" : "Add to favorites")
            }
        }
        .task(id: stationID) {
            try? await departureService.fetchDepartures(stationID, .cacheThenFetch)
        }
        .sheet(isPresented: $showingPicker) {
            StationPickerView { station in
                stationID = station.id
                stationName = station.name
                showingPicker = false
            }
        }
    }
    
    private var departureList: some View {
        List(store.departures) { departure in
            DepartureRow(departure: departure)
        }
    }
    
    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.stopID == stationID }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavoriteStop(stopID: stationID, name: stationName))
        }
    }
}

struct DepartureRow: View {
    let departure: Departure
    
    var body: some View {
        HStack(spacing: 12) {
            Text(departure.line)
                .font(.headline)
                .frame(minWidth: 56, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(departure.destination ?? "-")
                if let platform = departure.platform {
                    Text("Platform \(platform)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text(departure.departureTime, style: .time)
                .monospacedDigit()
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .departureService(.preview)
    .stopService(.preview)
    .modelContainer(for: FavoriteStop.self, inMemory: true)
}
