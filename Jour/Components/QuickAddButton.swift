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
    
    /// Background color theme (light)
    var color: Color = AppConstants.Colors.duoBlue
    
    /// Shadow color theme (dark)
    var shadowColor: Color = AppConstants.Colors.duoBlueDark
    
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
    ///   - color: Main background color (default: duoBlue)
    ///   - shadowColor: Shadow/edge color (default: duoBlueDark)
    ///   - action: Action to perform on tap
    init(emoji: String, label: String? = nil, color: Color = AppConstants.Colors.duoBlue, shadowColor: Color = AppConstants.Colors.duoBlueDark, action: @escaping () -> Void) {
        self.emoji = emoji
        self.label = label
        self.color = color
        self.shadowColor = shadowColor
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Trigger animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            // Reset animation and perform action
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                // Small delay to let the animation start before the action fires (if it changes view)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    action()
                }
            }
        }) {
            VStack(spacing: AppConstants.Spacing.xs) {
                Text(emoji)
                    .font(.title) // Larger emoji
                
                if let label = label {
                    Text(label)
                        .font(.system(size: 14, weight: .bold, design: .rounded)) // Playful font
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(minWidth: 80, minHeight: 80)
            .padding(AppConstants.Spacing.sm)
            .background(
                ZStack {
                    // 3D Lip (Shadow) layer - Only visible at bottom to create depth
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.xl)
                        .fill(shadowColor)
                        .offset(y: isPressed ? 0 : 6) // Moves up when pressed
                    
                    // Main Face layer
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.xl)
                        .fill(color)
                        .offset(y: isPressed ? 6 : 0) // Moves down when pressed
                }
            )
        }
        .accessibilityLabel(label ?? "Quick add")
        .accessibilityHint("Quickly adds a journal entry")
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
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

