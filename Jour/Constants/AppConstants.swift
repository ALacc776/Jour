//
//  AppConstants.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Centralized constants for the Jour app
/// This file contains all app-wide constants including colors, spacing, and configuration values
enum AppConstants {
    
    // MARK: - App Information
    
    static let appName = "QuickJournal"
    static let appTagline = "Reflect on your day, build mindful habits"
    
    // MARK: - Colors
    
    /// Primary color palette for the app
    enum Colors {
        // Background gradients
        static let primaryGradient = [
            Color.indigo.opacity(0.3),
            Color.purple.opacity(0.2)
        ]
        
        static let secondaryGradient = [
            Color.indigo.opacity(0.1),
            Color.purple.opacity(0.05)
        ]
        
        // Button gradients
        static let buttonGradient = [
            Color.blue.opacity(0.8),
            Color.blue.opacity(0.6)
        ]
        
        static let streakGradient = [
            Color.purple.opacity(0.8),
            Color.purple.opacity(0.6)
        ]
        
        // Text colors
        static let primaryText = Color.white
        static let secondaryText = Color.white.opacity(0.8)
        static let tertiaryText = Color.white.opacity(0.7)
        static let placeholderText = Color.white.opacity(0.5)
        
        // Card colors
        static let cardBackground = Color.white.opacity(0.1)
        static let cardBorder = Color.white.opacity(0.2)
        static let cardShadow = Color.black.opacity(0.1)
    }
    
    // MARK: - Spacing
    
    /// Consistent spacing values throughout the app
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let xxxxl: CGFloat = 40
    }
    
    // MARK: - Corner Radius
    
    /// Consistent corner radius values
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
    
    // MARK: - Shadows
    
    /// Consistent shadow configurations
    enum Shadows {
        static let card = (color: Color.black.opacity(0.1), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let button = (color: Color.blue.opacity(0.3), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let streak = (color: Color.purple.opacity(0.3), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
    }
    
    // MARK: - Animation
    
    /// Animation durations and configurations
    enum Animation {
        static let short: Double = 0.2
        static let medium: Double = 0.3
        static let long: Double = 0.5
        
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: medium)
    }
    
    // MARK: - Layout
    
    /// Layout configuration values
    enum Layout {
        static let categoryGridColumns = 2
        static let categoryGridSpacing: CGFloat = 12
        static let categoryButtonPadding: CGFloat = 16
        static let maxContentWidth: CGFloat = 600
    }
    
    // MARK: - UserDefaults Keys
    
    /// Keys for UserDefaults storage
    enum UserDefaultsKeys {
        static let journalEntries = "journal_entries"
        static let journalStreak = "journal_streak"
    }
    
    // MARK: - Date Formatting
    
    /// Date format strings
    enum DateFormats {
        static let storage = "yyyy-MM-dd"
        static let display = "EEEE, MMMM d, yyyy"
        static let time = "h:mm a"
    }
    
    // MARK: - Accessibility
    
    /// Accessibility identifiers and labels
    enum Accessibility {
        static let logDayButton = "Log Day Button"
        static let streakDisplay = "Streak Display"
        static let timelineView = "Timeline View"
        static let calendarView = "Calendar View"
        static let newEntryView = "New Entry View"
        static let categoryButton = "Category Button"
        static let entryRow = "Journal Entry Row"
    }
}
