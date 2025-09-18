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
            VStack {
                if journalManager.entries.isEmpty {
                    // MARK: - Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Your Journal is Empty")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Start writing your first entry")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // MARK: - Timeline of Entries
                    List {
                        ForEach(groupedEntries, id: \.0) { date, entries in
                            Section(header: Text(formatDate(date)).font(.headline)) {
                                ForEach(entries) { entry in
                                    EntryRowView(entry: entry)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Timeline")
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
