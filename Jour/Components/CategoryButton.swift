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
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                
                // Category name
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ? 
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.8),
                                Color.blue.opacity(0.6)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.blue : Color.white.opacity(0.3), 
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.1), 
                        radius: isSelected ? 8 : 4, 
                        x: 0, 
                        y: isSelected ? 4 : 2
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(category.rawValue) category")
        .accessibilityHint(isSelected ? "Selected" : "Tap to select")
    }
}
