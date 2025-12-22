
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
                    
                    // Coming Soon Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Coming Soon")
                            .font(.headline)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                            .padding(.horizontal, 4)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            FutureFeatureCard(icon: "sparkles", title: "AI Insights", desc: "Deep analysis of your entries")
                            FutureFeatureCard(icon: "chart.xyaxis.line", title: "Mood Analytics", desc: "Track your emotional trends")
                            FutureFeatureCard(icon: "square.and.arrow.up", title: "Export PDF", desc: "Share your journal")
                            FutureFeatureCard(icon: "lock.shield", title: "Cloud Backup", desc: "Sync across devices")
                        }
                    }
                    .padding(.horizontal, 4)
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

/// Placeholder card for future features
struct FutureFeatureCard: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color.gray.opacity(0.5))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.gray.opacity(0.7))
                
                Text(desc)
                    .font(.caption)
                    .foregroundColor(Color.gray.opacity(0.5))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
