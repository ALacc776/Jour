//
//  QuickAddButton.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Quick-add button for logging activities with a single tap
/// Displays an emoji and optional label for instant entry creation
struct QuickAddButton: View {
    // MARK: - Properties
    
    /// The emoji to display on the button
    let emoji: String
    
    /// Optional label text below the emoji
    let label: String?
    
    /// Action to perform when tapped
    let action: () -> Void
    
    // MARK: - State
    
    /// Tracks if the button is being pressed for animation
    @State private var isPressed = false
    
    // MARK: - Initializers
    
    /// Creates a quick-add button
    /// - Parameters:
    ///   - emoji: The emoji to display
    ///   - label: Optional text label
    ///   - action: Action to perform on tap
    init(emoji: String, label: String? = nil, action: @escaping () -> Void) {
        self.emoji = emoji
        self.label = label
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        }) {
            VStack(spacing: AppConstants.Spacing.xs) {
                Text(emoji)
                    .font(.title2)
                
                if let label = label {
                    Text(label)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(minWidth: 60)
            .padding(.vertical, AppConstants.Spacing.sm)
            .padding(.horizontal, AppConstants.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                    .fill(AppConstants.Colors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                            .stroke(AppConstants.Colors.cardBorder, lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        }
        .accessibilityLabel(label ?? "Quick add")
        .accessibilityHint("Quickly adds a journal entry")
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

/// Model for storing quick-add button configurations
struct QuickAddItem: Identifiable, Codable, Equatable {
    let id: UUID
    let emoji: String
    let label: String
    let defaultText: String
    
    init(emoji: String, label: String, defaultText: String, id: UUID = UUID()) {
        self.id = id
        self.emoji = emoji
        self.label = label
        self.defaultText = defaultText
    }
    
    // Default quick-add items
    static let defaults: [QuickAddItem] = [
        QuickAddItem(emoji: "☕️", label: "Coffee", defaultText: "Had coffee"),
        QuickAddItem(emoji: "💪", label: "Workout", defaultText: "Worked out"),
        QuickAddItem(emoji: "📚", label: "Read", defaultText: "Did some reading"),
        QuickAddItem(emoji: "🍽️", label: "Meal", defaultText: "Had a meal")
    ]
}

