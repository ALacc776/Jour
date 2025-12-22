
import SwiftUI

struct StatsView: View {
    @ObservedObject var journalManager: JournalManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Enhanced Streak Display
                    EnhancedStreakDisplay(streak: journalManager.streak)
                    
                    // Heatmap
                    CalendarHeatMap(entries: journalManager.entries)
                }
                .padding()
            }
            .navigationTitle("Your Journey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(AppConstants.Colors.accentButton)
                }
            }
            .background(AppConstants.Colors.primaryBackground)
        }
    }
}
