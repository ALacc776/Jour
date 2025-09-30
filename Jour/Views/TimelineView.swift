//
//  TimelineView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Displays a chronological timeline of all journal entries
/// Shows entries grouped by date with an empty state when no entries exist
struct TimelineView: View {
    // MARK: - Properties
    
    /// Reference to the journal manager for accessing entries
    @ObservedObject var journalManager: JournalManager
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if journalManager.entries.isEmpty {
                    // MARK: - Empty State
                    VStack(spacing: 24) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.6))
                        
                        VStack(spacing: 8) {
                            Text("Your Journal is Empty")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Start writing your first entry")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.indigo.opacity(0.1),
                                Color.purple.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                } else {
                    // MARK: - Timeline of Entries
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(groupedEntries, id: \.0) { date, entries in
                                VStack(alignment: .leading, spacing: 12) {
                                    // Date Header
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(.white.opacity(0.7))
                                            .font(.caption)
                                        
                                        Text(formatDate(date))
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 8)
                                    
                                    // Entries for this date
                                    VStack(spacing: 8) {
                                        ForEach(entries) { entry in
                                            EntryRowView(entry: entry)
                                                .swipeActions(edge: .trailing) {
                                                    Button("Delete", role: .destructive) {
                                                        withAnimation(.spring()) {
                                                            journalManager.deleteEntry(entry)
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    .refreshable {
                        // Add haptic feedback for refresh
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        // Simulate refresh delay for better UX
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.indigo.opacity(0.1),
                                Color.purple.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Computed Properties
    
    /// Groups journal entries by date and sorts them with newest dates first
    /// - Returns: Array of tuples containing date and associated entries
    private var groupedEntries: [(Date, [JournalEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: journalManager.entries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        return grouped.sorted { $0.key > $1.key }
    }
    
    // MARK: - Private Methods
    
    /// Formats a date for display in the timeline
    /// - Parameter date: The date to format
    /// - Returns: Formatted date string using full date style
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}
