//
//  CalendarHeatMap.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// GitHub-style heat map showing journaling activity over time
/// Displays a visual representation of entry frequency
struct CalendarHeatMap: View {
    // MARK: - Properties
    
    /// Journal entries to visualize
    let entries: [JournalEntry]
    
    /// Number of weeks to display (default: 12 weeks)
    let weeksToShow: Int
    
    /// Size of each day cell
    private let cellSize: CGFloat = 12
    private let cellSpacing: CGFloat = 3
    
    // MARK: - Initialization
    
    init(entries: [JournalEntry], weeksToShow: Int = 12) {
        self.entries = entries
        self.weeksToShow = weeksToShow
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
            Text("Activity")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.primaryText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: cellSpacing) {
                    // Day labels (S, M, T, W, T, F, S)
                    VStack(spacing: cellSpacing) {
                        ForEach(0..<7) { day in
                            if day % 2 == 1 { // Show labels for alternate days
                                Text(dayLabel(day))
                                    .font(.system(size: 8))
                                    .foregroundColor(AppConstants.Colors.tertiaryText)
                                    .frame(width: cellSize, height: cellSize)
                            } else {
                                Color.clear
                                    .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                    
                    // Heat map grid
                    ForEach(weeksArray.reversed(), id: \.self) { weekOffset in
                        VStack(spacing: cellSpacing) {
                            ForEach(0..<7) { dayOfWeek in
                                let date = dateFor(weekOffset: weekOffset, dayOfWeek: dayOfWeek)
                                let count = entryCount(for: date)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(colorForCount(count))
                                    .frame(width: cellSize, height: cellSize)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2)
                                            .strokeBorder(
                                                date.isToday ? AppConstants.Colors.accentButton : Color.clear,
                                                lineWidth: 1.5
                                            )
                                    )
                            }
                        }
                    }
                }
                .padding(.vertical, AppConstants.Spacing.xs)
            }
            
            // Legend
            HStack(spacing: AppConstants.Spacing.md) {
                Text("Less")
                    .font(.caption2)
                    .foregroundColor(AppConstants.Colors.tertiaryText)
                
                HStack(spacing: cellSpacing) {
                    ForEach(0..<5) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colorForLevel(level))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
                
                Text("More")
                    .font(.caption2)
                    .foregroundColor(AppConstants.Colors.tertiaryText)
            }
        }
        .padding(AppConstants.Spacing.lg)
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
    }
    
    // MARK: - Computed Properties
    
    /// Array of week offsets from today
    private var weeksArray: [Int] {
        Array(0..<weeksToShow)
    }
    
    /// Dictionary mapping dates to entry counts
    private var entryCounts: [Date: Int] {
        let calendar = Calendar.current
        var counts: [Date: Int] = [:]
        
        for entry in entries {
            let day = calendar.startOfDay(for: entry.date)
            counts[day, default: 0] += 1
        }
        
        return counts
    }
    
    // MARK: - Methods
    
    /// Returns the date for a specific week offset and day of week
    private func dateFor(weekOffset: Int, dayOfWeek: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        // Get start of current week (Sunday)
        let currentWeekday = calendar.component(.weekday, from: today)
        let daysFromSunday = currentWeekday - 1
        
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysFromSunday, to: today) else {
            return today
        }
        
        // Calculate target date
        let weeksBack = -weekOffset
        let totalDaysOffset = (weeksBack * 7) + dayOfWeek
        
        return calendar.date(byAdding: .day, value: totalDaysOffset, to: startOfWeek) ?? today
    }
    
    /// Returns the number of entries for a specific date
    private func entryCount(for date: Date) -> Int {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        return entryCounts[day] ?? 0
    }
    
    /// Returns color based on entry count
    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0:
            return AppConstants.Colors.tertiaryBackground
        case 1:
            return AppConstants.Colors.accentButton.opacity(0.3)
        case 2:
            return AppConstants.Colors.accentButton.opacity(0.5)
        case 3:
            return AppConstants.Colors.accentButton.opacity(0.7)
        default:
            return AppConstants.Colors.accentButton
        }
    }
    
    /// Returns color for legend level
    private func colorForLevel(_ level: Int) -> Color {
        colorForCount(level)
    }
    
    /// Returns day label (S, M, T, W, T, F, S)
    private func dayLabel(_ day: Int) -> String {
        let labels = ["S", "M", "T", "W", "T", "F", "S"]
        return labels[day]
    }
}

#Preview {
    let manager = JournalManager()
    CalendarHeatMap(entries: manager.entries)
        .padding()
}

