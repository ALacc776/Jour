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
    
    /// Pre-calculated entry counts for O(1) lookup
    private let counts: [Date: Int]
    
    // MARK: - Initialization
    
    init(entries: [JournalEntry], weeksToShow: Int = 12) {
        self.entries = entries
        self.weeksToShow = weeksToShow
        
        // Optimization: Pre-calculate counts once to avoid O(N*M) complexity during rendering
        let calendar = Calendar.current
        var c: [Date: Int] = [:]
        for entry in entries {
            let day = calendar.startOfDay(for: entry.date)
            c[day, default: 0] += 1
        }
        self.counts = c
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
            HStack {
                Text("Your Journey")
                    .font(.title3) // Slightly larger
                    .fontWeight(.bold)
                    .foregroundColor(AppConstants.Colors.primaryText)
                
                Spacer()
                
                // Optional: Year/Month selector could go here
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: cellSpacing) {
                    // Day labels (S, M, T, W, T, F, S)
                    VStack(spacing: cellSpacing) {
                        ForEach(0..<7) { day in
                            if day % 2 == 1 { // Show labels for alternate days
                                Text(dayLabel(day))
                                    .font(.system(size: 9, weight: .bold, design: .rounded)) // Rounded font
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
                                
                                RoundedRectangle(cornerRadius: 3) // More rounded
                                    .fill(colorForCount(count))
                                    .frame(width: cellSize, height: cellSize)
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
                    .fontWeight(.medium)
                    .foregroundColor(AppConstants.Colors.tertiaryText)
                
                HStack(spacing: cellSpacing) {
                    ForEach(0..<4) { level in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(colorForLevel(level))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
                
                Text("More")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(AppConstants.Colors.tertiaryText)
            }
        }
        .padding(AppConstants.Spacing.lg)
        .background(
            ZStack {
                // 3D Card style (consistent with NewEntryView)
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                    .fill(AppConstants.Colors.cardBorder.opacity(0.3)) // Subtle shadow/lip
                    .offset(y: 4)
                
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                    .fill(AppConstants.Colors.cardBackground)
            }
        )
    }
    
    // MARK: - Computed Properties
    
    /// Array of week offsets from today
    private var weeksArray: [Int] {
        Array(0..<weeksToShow)
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
        return counts[day] ?? 0
    }
    
    /// Returns color based on entry count
    private func colorForCount(_ count: Int) -> Color {
        if count == 0 {
            return AppConstants.Colors.secondaryBackground // Empty cell
        }
        
        // 4 Levels of intensity
        switch count {
        case 1:
            return AppConstants.Colors.duoGreen.opacity(0.4)
        case 2:
            return AppConstants.Colors.duoGreen.opacity(0.6)
        case 3:
            return AppConstants.Colors.duoGreen.opacity(0.8)
        default: // 4 or more
            return AppConstants.Colors.duoGreen
        }
    }
    
    /// Returns color for legend level
    private func colorForLevel(_ level: Int) -> Color {
        // Legend levels: 0 (empty) to 3 (darkest)
        if level == 0 {
            return AppConstants.Colors.secondaryBackground
        }
        switch level {
        case 1: return AppConstants.Colors.duoGreen.opacity(0.4)
        case 2: return AppConstants.Colors.duoGreen.opacity(0.8) // Using 2 levels for legend simple
        default: return AppConstants.Colors.duoGreen
        }
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

