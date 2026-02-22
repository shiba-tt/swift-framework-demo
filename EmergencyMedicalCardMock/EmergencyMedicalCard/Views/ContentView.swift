import SwiftUI

struct ContentView: View {
    @State private var viewModel = EmergencyMedicalCardViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("緊急情報", systemImage: "heart.text.clipboard", value: 0) {
                EmergencyInfoView(viewModel: viewModel)
            }

            Tab("服薬情報", systemImage: "pill.fill", value: 1) {
                MedicationListView(viewModel: viewModel)
            }

            Tab("連絡先", systemImage: "phone.fill", value: 2) {
                EmergencyContactsView(viewModel: viewModel)
            }
        }
        .tint(.red)
        .task {
            viewModel.loadProfile()
        }
    }
}

#Preview {
    ContentView()
}
