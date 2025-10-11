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
            VStack(spacing: AppConstants.Spacing.sm) {
                // Category emoji
                Text(category.emoji)
                    .font(.title2)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                
                // Category name
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : AppConstants.Colors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppConstants.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                    .fill(
                        isSelected ? 
                        AppConstants.Colors.accentButton :
                        AppConstants.Colors.secondaryBackground
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                            .stroke(
                                isSelected ? AppConstants.Colors.accentButton : AppConstants.Colors.cardBorder, 
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            .shadow(
                color: isSelected ? AppConstants.Colors.accentButton.opacity(0.3) : AppConstants.Shadows.card.color,
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(category.rawValue) category")
        .accessibilityHint(isSelected ? "Selected" : "Tap to select")
    }
}
