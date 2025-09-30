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
        VStack(spacing: AppConstants.Spacing.md) {
            // MARK: - Streak Information Card
            HStack {
                // Flame icon for visual appeal
                Image(systemName: "flame.fill")
                    .primaryTextStyle()
                    .font(.title2)
                    .scaleEffect(streak.current > 0 ? 1.1 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: streak.current)
                
                // Current streak display
                VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                    Text("\(streak.current) Days")
                        .font(.title2)
                        .fontWeight(.bold)
                        .primaryTextStyle()
                        .contentTransition(.numericText())
                    
                    Text("Current Streak")
                        .font(.caption)
                        .secondaryTextStyle()
                }
                
                Spacer()
                
                // Personal best display
                VStack(alignment: .trailing, spacing: AppConstants.Spacing.xs) {
                    Text("Best: \(streak.longest)")
                        .font(.headline)
                        .primaryTextStyle()
                        .contentTransition(.numericText())
                    
                    Text("Personal Best")
                        .font(.caption)
                        .secondaryTextStyle()
                }
            }
            .padding(AppConstants.Spacing.xl)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: AppConstants.Colors.streakGradient),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppConstants.CornerRadius.lg)
            .shadow(
                color: AppConstants.Shadows.streak.color,
                radius: AppConstants.Shadows.streak.radius,
                x: AppConstants.Shadows.streak.x,
                y: AppConstants.Shadows.streak.y
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Current streak: \(streak.current) days. Personal best: \(streak.longest) days")
            
            // MARK: - Encouraging Message
            if streak.current > 0 {
                Text(encouragingMessage)
                    .font(.caption)
                    .tertiaryTextStyle()
                    .multilineTextAlignment(.center)
                    .horizontalPadding()
            } else {
                Text("Keep your streak alive - log today!")
                    .font(.caption)
                    .tertiaryTextStyle()
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
