
import SwiftUI

struct StationPickerView: View {
    @Environment(\.stopService) private var stopService
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchTerm = ""
    
    let onSelect: (Station) -> Void
    
    private var store: StopStore { stopService.store }
    
    var body: some View {
        NavigationStack {
            List(store.stations) { station in
                Button {
                    onSelect(station)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(station.name)
                            .foregroundStyle(.primary)
                        if let code = station.code {
                            Text("Stop \(code)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .overlay {
                if store.loadingState.isLoading && store.stations.isEmpty {
                    ProgressView()
                }
            }
            .searchable(text: $searchTerm, prompt: "Search stations")
            .navigationTitle("Choose Station")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task(id: searchTerm) {
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                try? await stopService.search(searchTerm, .cacheThenFetch)
            }
        }
    }
}

#Preview {
    StationPickerView(onSelect: { _ in })
        .stopService(.preview)
}
