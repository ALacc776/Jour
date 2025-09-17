//
//  TimelineView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

struct TimelineView: View {
    @ObservedObject var journalManager: JournalManager
    
    var body: some View {
        NavigationView {
            VStack {
                if journalManager.entries.isEmpty {
                    // Empty state
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
                    // Timeline of entries
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
    
    private var groupedEntries: [(Date, [JournalEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: journalManager.entries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        return grouped.sorted { $0.key > $1.key }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}
