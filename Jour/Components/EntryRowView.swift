//
//  EntryRowView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

struct EntryRowView: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let category = entry.category {
                HStack {
                    Text(JournalCategory(rawValue: category)?.emoji ?? "📝")
                        .font(.title2)
                    
                    Text(category)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if let time = entry.time {
                        Text(time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Text(entry.content)
                .font(.body)
                .lineLimit(nil)
            
            Text(entry.date, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
