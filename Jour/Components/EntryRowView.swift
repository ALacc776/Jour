//
//  EntryRowView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Reusable view component for displaying individual journal entries in lists
/// Shows entry content, category, time, and creation timestamp in a clean layout
struct EntryRowView: View {
    // MARK: - Properties
    
    /// The journal entry to display
    let entry: JournalEntry
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Category and Time Header
            if let category = entry.category {
                HStack {
                    // Category emoji
                    Text(JournalCategory(rawValue: category)?.emoji ?? "📝")
                        .font(.title2)
                    
                    // Category name
                    Text(category)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Optional time display
                    if let time = entry.time {
                        Text(time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // MARK: - Entry Content
            Text(entry.content)
                .font(.body)
                .lineLimit(nil)
            
            // MARK: - Creation Time
            Text(entry.date, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
