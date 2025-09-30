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
        VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
            // MARK: - Category Badge (if available)
            if let category = entry.category {
                HStack {
                    Text(category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
            }
            
            // MARK: - Entry Content
            Text(entry.content)
                .font(.body)
                .primaryTextStyle()
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // MARK: - Time Display
            HStack {
                if let time = entry.time {
                    Text(time)
                        .font(.caption)
                        .tertiaryTextStyle()
                }
                
                Spacer()
                
                Text(entry.date, style: .time)
                    .font(.caption)
                    .tertiaryTextStyle()
            }
        }
        .journalCardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.category ?? "Entry"): \(entry.content)")
        .accessibilityHint("Created at \(entry.date, style: .time)")
    }
}
