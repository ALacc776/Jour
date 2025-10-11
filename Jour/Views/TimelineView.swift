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
                    VStack(spacing: AppConstants.Spacing.xxxl) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 80))
                            .foregroundColor(AppConstants.Colors.tertiaryText)
                        
                        VStack(spacing: AppConstants.Spacing.sm) {
                            Text("Your Journal is Empty")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(AppConstants.Colors.primaryText)
                            
                            Text("Start writing your first entry")
                                .font(.body)
                                .foregroundColor(AppConstants.Colors.secondaryText)
                        }
                    }
                    .padding(AppConstants.Spacing.xxxxl)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cleanBackground()
                } else {
                    // MARK: - Timeline of Entries
                    ScrollView {
                        LazyVStack(spacing: AppConstants.Spacing.lg) {
                            ForEach(groupedEntries, id: \.0) { date, entries in
                                VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
                                    // Date Header
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(AppConstants.Colors.accentButton)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        
                                        Text(formatDate(date))
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(AppConstants.Colors.primaryText)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, AppConstants.Spacing.xl)
                                    .padding(.top, AppConstants.Spacing.sm)
                                    
                                    // Entries for this date
                                    VStack(spacing: AppConstants.Spacing.sm) {
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
                                    .padding(.horizontal, AppConstants.Spacing.xl)
                                }
                            }
                        }
                        .padding(.vertical, AppConstants.Spacing.xl)
                    }
                    .refreshable {
                        // Add haptic feedback for refresh
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        // Simulate refresh delay for better UX
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    }
                    .cleanBackground()
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
