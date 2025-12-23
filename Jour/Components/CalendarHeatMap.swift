//
//  CalendarHeatMap.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// GitHub-style heat map or Calendar Grid showing journaling activity
struct CalendarHeatMap: View {
    // MARK: - Properties
    
    let entries: [JournalEntry]
    
    enum TimeRange: String, CaseIterable {
        case oneMonth = "1M"
        case oneYear = "1Y"
    }
    
    @State private var selectedRange: TimeRange = .oneYear
    @State private var monthOffset: Int = 0
    
    // MARK: - Initialization
    
    private let counts: [Date: Int]
    
    init(entries: [JournalEntry]) {
        self.entries = entries
        
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
            // Header
            HStack {
                if selectedRange == .oneMonth {
                    HStack(spacing: 16) {
                        // Left Arrow: Go to Past (-1)
                        Button(action: {
                            withAnimation {
                                monthOffset -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppConstants.Colors.tertiaryText)
                        }
                        
                        Text(currentMonthYearString)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                            .frame(minWidth: 140) 
                        
                        // Right Arrow: Go to Future (+1)
                        Button(action: {
                            if monthOffset < 0 {
                                withAnimation {
                                    monthOffset += 1
                                }
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppConstants.Colors.tertiaryText)
                                .opacity(monthOffset >= 0 ? 0.3 : 1.0)
                        }
                        .disabled(monthOffset >= 0)
                    }
                } else {
                    Text("Your Journey")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppConstants.Colors.primaryText)
                }
                
                Spacer()
                
                Picker("Time Range", selection: $selectedRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
                .labelsHidden()
            }
            .padding(.bottom, 4)
            .onChange(of: selectedRange) { newValue in
                // Reset to current month when switching views
                monthOffset = 0
            }
            
            // Content
            Group {
                switch selectedRange {
                case .oneMonth:
                    MonthlyReviewView(monthOffset: monthOffset, counts: counts)
                        .id(monthOffset) // Force transition
                        .transition(.opacity.combined(with: .move(edge: monthOffset < 0 ? .leading : .trailing))) 
                        // Note: Transition direction logic is simplified here, can be refined.
                case .oneYear:
                    YearlyHeatMapView(counts: counts)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: selectedRange)
             
            // Legend
            HStack(spacing: AppConstants.Spacing.md) {
                Text("Less")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(AppConstants.Colors.tertiaryText)
                
                HStack(spacing: 4) {
                    // Empty (Gray)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppConstants.Colors.secondaryBackground)
                        .frame(width: 10, height: 10)
                    
                    // Filled Levels
                    ForEach(1..<4) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colorForLevel(level))
                            .frame(width: 10, height: 10)
                    }
                }
                
                Text("More")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(AppConstants.Colors.tertiaryText)
            }
            .padding(.top, 8)
        }
        .padding(AppConstants.Spacing.lg)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                    .fill(AppConstants.Colors.cardBorder.opacity(0.3))
                    .offset(y: 4)
                
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                    .fill(AppConstants.Colors.cardBackground)
            }
        )
    }
    
    private var currentMonthYearString: String {
        guard let date = Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) else { return "" }
        return date.formatted(.dateTime.month().year())
    }
    
    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 1: return AppConstants.Colors.duoGreen.opacity(0.3)
        case 2: return AppConstants.Colors.duoGreen.opacity(0.6)
        default: return AppConstants.Colors.duoGreen
        }
    }
}

// MARK: - Subviews

/// Renders a single calendar grid for 1M view
struct MonthlyReviewView: View {
    let monthOffset: Int
    let counts: [Date: Int]
    
    var body: some View {
        if let date = Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) {
            CalendarMonthGrid(monthDate: date, counts: counts)
        }
    }
}

/// A single month rendered as a 7-column grid
struct CalendarMonthGrid: View {
    let monthDate: Date
    let counts: [Date: Int]
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Days Grid
            LazyVGrid(columns: columns, spacing: 6) {
                // Weekday Headers
                let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                ForEach(0..<7, id: \.self) { index in
                    Text(days[index])
                        .font(.system(size: 10, weight: .bold)) // Slightly smaller/fixed font to fit
                        .foregroundColor(AppConstants.Colors.tertiaryText)
                }
                
                // Empty slots before start of month
                ForEach(0..<startOffset, id: \.self) { _ in
                    Color.clear.aspectRatio(1, contentMode: .fit)
                }
                
                // Days
                ForEach(daysInMonth, id: \.self) { date in
                    let count = counts[calendar.startOfDay(for: date)] ?? 0
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorForCount(count))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var startOffset: Int {
        let components = calendar.dateComponents([.year, .month], from: monthDate)
        guard let startOfMonth = calendar.date(from: components) else { return 0 }
        return calendar.component(.weekday, from: startOfMonth) - 1
    }
    
    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: monthDate) else { return [] }
        let components = calendar.dateComponents([.year, .month], from: monthDate)
        guard let startOfMonth = calendar.date(from: components) else { return [] }
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    private func colorForCount(_ count: Int) -> Color {
        if count == 0 {
            return AppConstants.Colors.secondaryBackground.opacity(1.5)
        }
        
        switch count {
        case 1: return AppConstants.Colors.duoGreen.opacity(0.4)
        case 2: return AppConstants.Colors.duoGreen.opacity(0.7)
        default: return AppConstants.Colors.duoGreen
        }
    }
}

/// The refined GitHub-style horizontal scrolling heatmap (1Y view)
struct YearlyHeatMapView: View {
    let counts: [Date: Int]
    
    // Grid State
    @State private var weeks: [WeekData] = []
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 3) {
                    
                    // Day Labels Column (Left Axis)
                    VStack(alignment: .leading, spacing: 3) {
                        // Spacer for Month Label Header height (10pt font)
                        Color.clear.frame(height: 10)
                        
                        // Spacer for spacing between header and grid (4pt)
                        Color.clear.frame(height: 4)
                        
                        // Days
                        ForEach(0..<7, id: \.self) { row in
                            if [1, 3, 5].contains(row) {
                                Text(dayLabel(row))
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(AppConstants.Colors.tertiaryText)
                                    .frame(height: 10)
                            } else {
                                Color.clear.frame(height: 10)
                            }
                        }
                    }
                    .padding(.bottom, 2)
                    .padding(.trailing, 4)
                    
                    // Weeks Columns
                    LazyHStack(alignment: .bottom, spacing: 3) {
                        ForEach(weeks) { week in
                            VStack(alignment: .leading, spacing: 4) {
                                // Month Label
                                // Use overlay to prevent text width from expanding the column width
                                Color.clear
                                    .frame(width: 10, height: 10)
                                    .overlay(alignment: .bottomLeading) {
                                        if week.isStartOfMonth {
                                            Text(week.monthLabel)
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(AppConstants.Colors.tertiaryText)
                                                .fixedSize() // Allow text to overflow 10pt width visually
                                                .background(AppConstants.Colors.primaryBackground.opacity(0.8)) // Optional legibility
                                        }
                                    }
                                
                                // Days Grid Column
                                VStack(spacing: 3) {
                                    ForEach(week.days, id: \.self) { date in
                                        if let date = date {
                                            let count = counts[Calendar.current.startOfDay(for: date)] ?? 0
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(colorForCount(count))
                                                .frame(width: 10, height: 10)
                                        } else {
                                            Color.clear.frame(width: 10, height: 10)
                                        }
                                    }
                                }
                            }
                            .id(week.id) // Identify for scrolling
                        }
                    }
                    .padding(.trailing, 20)
                }
            .onAppear {
                generateWeeks()
                
                // Scroll to end after layout
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let lastWeek = weeks.last {
                        proxy.scrollTo(lastWeek.id, anchor: .trailing)
                    }
                }
            }
        }
        .frame(height: 130)
        // Fade mask on the left to show "history"
        .overlay(
            LinearGradient(
                gradient: Gradient(colors: [
                    AppConstants.Colors.cardBackground,
                    AppConstants.Colors.cardBackground.opacity(0.0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 30)
            .allowsHitTesting(false), // Allow touches through
            alignment: .leading
        )
    }
    }
    
    // MARK: - Data Generation
    
    private func generateWeeks() {
        let calendar = Calendar.current
        let today = Date()
        
        // Go back 52 weeks
        guard let oneYearAgo = calendar.date(byAdding: .weekOfYear, value: -52, to: today) else { return }
        
        // Find start of that week (Sunday)
        let weekday = calendar.component(.weekday, from: oneYearAgo)
        guard let startSunday = calendar.date(byAdding: .day, value: -(weekday - 1), to: oneYearAgo) else { return }
        
        var newWeeks: [WeekData] = []
        
        for i in 0...52 {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: i, to: startSunday) else { continue }
            
            var days: [Date?] = []
            // Collect 7 days
            for d in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: d, to: weekStart) {
                    // Only add if not in future (optional, but requested "whole year" usually implies past year)
                    if date > today {
                        days.append(nil) // Future placeholder if we want to stop exactly at today
                    } else {
                        days.append(date)
                    }
                } else {
                    days.append(nil)
                }
            }
            
            // Determine Month Label
            // Rule: Show label if this week contains the 1st of the month
            let monthLabel = getMonthLabel(for: weekStart)
            let isStart = monthLabel != nil
            
            newWeeks.append(WeekData(id: i, days: days, isStartOfMonth: isStart, monthLabel: monthLabel ?? ""))
        }
        
        self.weeks = newWeeks
    }
    
    private func getMonthLabel(for weekStart: Date) -> String? {
        let calendar = Calendar.current
        // Check all days in this week
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: weekStart) {
                if calendar.component(.day, from: date) <= 7 && i == 0 { 
                    // To be simple: if the week STARTS within the first 7 days, we can label it?
                    // Actually better rule: specific logic to align perfectly.
                    // If the 1st of the month IS in this week?
                    let day = calendar.component(.day, from: date)
                    if day == 1 {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MMM"
                        return formatter.string(from: date)
                    }
                }
            }
        }
        
        // Fallback: If 1st wasn't processed (maybe start of chart?), check purely based on week start?
        // Let's use a simpler heuristic: If the week start is the first week of the month encountered.
        // Actually, looking at GitHub, the label appears above the week that contains Day 1.
        
        for i in 0..<7 {
             if let date = calendar.date(byAdding: .day, value: i, to: weekStart) {
                 if calendar.component(.day, from: date) == 1 {
                     let formatter = DateFormatter()
                     formatter.dateFormat = "MMM"
                     return formatter.string(from: date)
                 }
             }
        }
        
        return nil
    }
    
    // MARK: - Helpers
    
    private func dayLabel(_ row: Int) -> String {
        switch row {
        case 1: return "Mon"
        case 3: return "Wed"
        case 5: return "Fri"
        default: return ""
        }
    }
    
    private func colorForCount(_ count: Int) -> Color {
        if count == 0 { return Color(uiColor: .systemGray6) }
        switch count {
        case 1: return AppConstants.Colors.duoGreen.opacity(0.4)
        case 2: return AppConstants.Colors.duoGreen.opacity(0.7)
        default: return AppConstants.Colors.duoGreen
        }
    }
}

/// Helper struct for column-based layout
struct WeekData: Identifiable {
    let id: Int
    let days: [Date?] // 7 days (can be nil if out of bounds)
    let isStartOfMonth: Bool
    let monthLabel: String
}

