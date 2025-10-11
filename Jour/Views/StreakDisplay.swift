//
//  StreakDisplay.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Displays the user's current journaling streak and personal best
/// Shows encouraging messages based on the current streak length
struct StreakDisplay: View {
    // MARK: - Properties
    
    /// The streak data to display
    let streak: JournalStreak
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            // MARK: - Streak Information Card
            HStack(spacing: AppConstants.Spacing.xl) {
                // Flame icon for visual appeal
                Image(systemName: "flame.fill")
                    .foregroundColor(AppConstants.Colors.accentButton)
                    .font(.title2)
                    .scaleEffect(streak.current > 0 ? 1.1 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: streak.current)
                
                // Current streak display
                VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                    Text("\(streak.current)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppConstants.Colors.primaryText)
                        .contentTransition(.numericText())
                    
                    Text("Current Streak")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                }
                
                Spacer()
                
                // Personal best display
                VStack(alignment: .trailing, spacing: AppConstants.Spacing.xs) {
                    Text("Best: \(streak.longest)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppConstants.Colors.primaryText)
                        .contentTransition(.numericText())
                    
                    Text("Personal Best")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                }
            }
            .padding(AppConstants.Spacing.xl)
            .elevatedCardStyle()
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Current streak: \(streak.current) days. Personal best: \(streak.longest) days")
            
            // MARK: - Encouraging Message
            if streak.current > 0 {
                Text(encouragingMessage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppConstants.Colors.accentText)
                    .multilineTextAlignment(.center)
                    .horizontalPadding()
            } else {
                Text("Keep your streak alive - log today!")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppConstants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .horizontalPadding()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Returns an encouraging message based on the current streak length
    /// Provides motivational feedback to encourage continued journaling
    private var encouragingMessage: String {
        switch streak.current {
        case 1...3:
            return "Great start! Keep it up! 🔥"
        case 4...7:
            return "You're building a great habit! 💪"
        case 8...14:
            return "Amazing consistency! 🌟"
        case 15...30:
            return "You're on fire! This is incredible! 🚀"
        default:
            return "You're a journaling legend! 🏆"
        }
    }
}
