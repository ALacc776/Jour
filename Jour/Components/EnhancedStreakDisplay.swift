//
//  EnhancedStreakDisplay.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Enhanced streak display with visual progress and milestones
/// Shows current streak with motivational UI elements
struct EnhancedStreakDisplay: View {
    // MARK: - Properties
    
    /// The streak data to display
    let streak: JournalStreak
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            // Main streak card
            HStack(spacing: AppConstants.Spacing.xl) {
                // Animated flame icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    AppConstants.Colors.accentButton.opacity(0.2),
                                    AppConstants.Colors.accentButton.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: streak.current > 0 ? "flame.fill" : "flame")
                        .foregroundColor(AppConstants.Colors.accentButton)
                        .font(.system(size: 32))
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: streak.current)
                }
                
                // Streak numbers
                VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: AppConstants.Spacing.xs) {
                        Text("\(streak.current)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(AppConstants.Colors.primaryText)
                            .animation(.easeInOut, value: streak.current)
                        
                        Text("day\(streak.current == 1 ? "" : "s")")
                            .font(.headline)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    
                    Text("Current Streak")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                        .textCase(.uppercase)
                }
                
                Spacer()
                
                // Personal best badge
                VStack(spacing: AppConstants.Spacing.xs) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                    
                    Text("\(streak.longest)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppConstants.Colors.primaryText)
                    
                    Text("Best")
                        .font(.caption2)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                        .textCase(.uppercase)
                }
            }
            .padding(AppConstants.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                    .fill(AppConstants.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                            .stroke(AppConstants.Colors.cardBorder, lineWidth: 1)
                    )
            )
            .shadow(
                color: AppConstants.Shadows.card.color,
                radius: AppConstants.Shadows.card.radius,
                x: AppConstants.Shadows.card.x,
                y: AppConstants.Shadows.card.y
            )
            
            // Progress to next milestone
            if streak.current > 0 {
                VStack(spacing: AppConstants.Spacing.sm) {
                    HStack {
                        Text("Next milestone")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                            .textCase(.uppercase)
                        
                        Spacer()
                        
                        Text("\(nextMilestone) days")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(AppConstants.Colors.accentButton)
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppConstants.Colors.secondaryBackground)
                                .frame(height: 8)
                            
                            // Progress
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: AppConstants.Colors.streakGradient),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progressToNextMilestone, height: 8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressToNextMilestone)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, AppConstants.Spacing.sm)
            }
            
            // Encouraging message
            Text(encouragingMessage)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(streak.current > 0 ? AppConstants.Colors.accentText : AppConstants.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppConstants.Spacing.md)
        }
    }
    
    // MARK: - Computed Properties
    
    /// Next milestone to reach
    private var nextMilestone: Int {
        let milestones = [3, 7, 14, 30, 60, 100, 365]
        return milestones.first(where: { $0 > streak.current }) ?? (streak.current + 10)
    }
    
    /// Progress percentage to next milestone
    private var progressToNextMilestone: CGFloat {
        let milestones = [3, 7, 14, 30, 60, 100, 365]
        let previous = milestones.last(where: { $0 <= streak.current }) ?? 0
        let next = milestones.first(where: { $0 > streak.current }) ?? (streak.current + 10)
        
        let progress = CGFloat(streak.current - previous) / CGFloat(next - previous)
        return min(max(progress, 0), 1)
    }
    
    /// Encouraging message based on streak
    private var encouragingMessage: String {
        switch streak.current {
        case 0:
            return "Start your streak today! 🚀"
        case 1...2:
            return "Great start! Keep going! 💪"
        case 3...6:
            return "You're building a habit! 🔥"
        case 7...13:
            return "One week strong! Amazing! 🌟"
        case 14...29:
            return "Two weeks! You're on fire! 🚀"
        case 30...59:
            return "One month! Incredible dedication! 🏆"
        case 60...99:
            return "Two months! You're unstoppable! ⭐️"
        case 100...364:
            return "100+ days! You're a legend! 👑"
        default:
            return "One year+! Absolute dedication! 🎉"
        }
    }
}

#Preview {
    VStack {
        EnhancedStreakDisplay(streak: JournalStreak(current: 5, longest: 12))
            .padding()
        
        EnhancedStreakDisplay(streak: JournalStreak(current: 0, longest: 0))
            .padding()
    }
}

