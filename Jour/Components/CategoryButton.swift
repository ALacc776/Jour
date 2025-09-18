//
//  CategoryButton.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Reusable button component for selecting journal entry categories
/// Displays category emoji and name with visual feedback for selection state
struct CategoryButton: View {
    // MARK: - Properties
    
    /// The journal category this button represents
    let category: JournalCategory
    
    /// Whether this category is currently selected
    let isSelected: Bool
    
    /// Action to perform when the button is tapped
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Category emoji
                Text(category.emoji)
                    .font(.title)
                
                // Category name
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
