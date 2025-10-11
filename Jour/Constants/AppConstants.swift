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
    
    /// Professional minimalist color palette
    enum Colors {
        // Background colors
        static let primaryBackground = Color(red: 0.98, green: 0.98, blue: 0.99) // Light gray background
        static let secondaryBackground = Color.white // Pure white for cards
        static let tertiaryBackground = Color(red: 0.95, green: 0.95, blue: 0.96) // Subtle gray for sections
        
        // Primary gradient (subtle and professional)
        static let primaryGradient = [
            Color(red: 0.98, green: 0.98, blue: 0.99),
            Color(red: 0.95, green: 0.95, blue: 0.96)
        ]
        
        static let secondaryGradient = [
            Color(red: 0.97, green: 0.97, blue: 0.98),
            Color(red: 0.94, green: 0.94, blue: 0.95)
        ]
        
        // Button colors
        static let primaryButton = Color(red: 0.2, green: 0.2, blue: 0.25) // Dark gray for primary actions
        static let secondaryButton = Color(red: 0.9, green: 0.9, blue: 0.92) // Light gray for secondary actions
        static let accentButton = Color(red: 0.95, green: 0.6, blue: 0.3) // Warm orange accent
        
        // Button gradients
        static let buttonGradient = [
            Color(red: 0.2, green: 0.2, blue: 0.25),
            Color(red: 0.15, green: 0.15, blue: 0.2)
        ]
        
        static let streakGradient = [
            Color(red: 0.95, green: 0.6, blue: 0.3),
            Color(red: 0.9, green: 0.55, blue: 0.25)
        ]
        
        // Text colors
        static let primaryText = Color(red: 0.15, green: 0.15, blue: 0.2) // Dark gray for main text
        static let secondaryText = Color(red: 0.5, green: 0.5, blue: 0.55) // Medium gray for secondary text
        static let tertiaryText = Color(red: 0.7, green: 0.7, blue: 0.75) // Light gray for tertiary text
        static let placeholderText = Color(red: 0.8, green: 0.8, blue: 0.85) // Very light gray for placeholders
        static let accentText = Color(red: 0.95, green: 0.6, blue: 0.3) // Orange for highlights
        
        // Card colors
        static let cardBackground = Color.white
        static let cardBorder = Color(red: 0.9, green: 0.9, blue: 0.92)
        static let cardShadow = Color.black.opacity(0.05)
        
        // Status colors
        static let successColor = Color(red: 0.2, green: 0.7, blue: 0.3)
        static let warningColor = Color(red: 0.95, green: 0.6, blue: 0.3)
        static let errorColor = Color(red: 0.9, green: 0.3, blue: 0.3)
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
    
    /// Professional shadow configurations
    enum Shadows {
        static let card = (color: Color.black.opacity(0.04), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(2))
        static let button = (color: Color.black.opacity(0.08), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(4))
        static let streak = (color: Color.black.opacity(0.06), radius: CGFloat(10), x: CGFloat(0), y: CGFloat(3))
        static let elevated = (color: Color.black.opacity(0.1), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
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
