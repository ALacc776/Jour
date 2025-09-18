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
        VStack(spacing: 8) {
            // MARK: - Streak Information Card
            HStack {
                // Flame icon for visual appeal
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                // Current streak display
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(streak.current)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Day Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Personal best display
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Best: \(streak.longest)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Personal Best")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            
            // MARK: - Encouraging Message
            if streak.current > 0 {
                Text(encouragingMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
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
