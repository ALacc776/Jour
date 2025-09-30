//
//  ViewExtensions.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Useful extensions for SwiftUI Views
/// This file contains common view modifiers and utilities for better code reusability
extension View {
    
    // MARK: - Gradient Backgrounds
    
    /// Applies the primary gradient background used throughout the app
    func primaryGradientBackground() -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(colors: AppConstants.Colors.primaryGradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    /// Applies the secondary gradient background for subtle areas
    func secondaryGradientBackground() -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(colors: AppConstants.Colors.secondaryGradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Card Styling
    
    /// Applies the standard card styling used for journal entries
    func journalCardStyle() -> some View {
        self
            .padding(AppConstants.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                    .fill(AppConstants.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
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
    
    /// Applies button gradient styling
    func buttonGradientStyle() -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(colors: AppConstants.Colors.buttonGradient),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(AppConstants.CornerRadius.md)
    }
    
    // MARK: - Text Styling
    
    /// Applies primary text styling
    func primaryTextStyle() -> some View {
        self.foregroundColor(AppConstants.Colors.primaryText)
    }
    
    /// Applies secondary text styling
    func secondaryTextStyle() -> some View {
        self.foregroundColor(AppConstants.Colors.secondaryText)
    }
    
    /// Applies tertiary text styling
    func tertiaryTextStyle() -> some View {
        self.foregroundColor(AppConstants.Colors.tertiaryText)
    }
    
    // MARK: - Spacing
    
    /// Applies consistent horizontal padding
    func horizontalPadding(_ size: CGFloat = AppConstants.Spacing.xl) -> some View {
        self.padding(.horizontal, size)
    }
    
    /// Applies consistent vertical padding
    func verticalPadding(_ size: CGFloat = AppConstants.Spacing.lg) -> some View {
        self.padding(.vertical, size)
    }
    
    // MARK: - Animation
    
    /// Applies the standard spring animation
    func springAnimation() -> some View {
        self.animation(AppConstants.Animation.spring, value: UUID())
    }
    
    /// Applies the standard ease in-out animation
    func easeInOutAnimation() -> some View {
        self.animation(AppConstants.Animation.easeInOut, value: UUID())
    }
    
    /// Hides the keyboard by resigning first responder
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Color Extensions

extension Color {
    /// Creates a color with opacity for better readability
    func withOpacity(_ opacity: Double) -> Color {
        self.opacity(opacity)
    }
}

// MARK: - Date Extensions

extension Date {
    /// Formats the date for storage in UserDefaults
    var storageFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstants.DateFormats.storage
        return formatter.string(from: self)
    }
    
    /// Formats the date for display in the UI
    var displayFormat: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: self)
    }
    
    /// Gets the start of day for this date
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Checks if this date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Checks if this date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
}

// MARK: - String Extensions

extension String {
    /// Trims whitespace and newlines from the string
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Checks if the string is empty after trimming
    var isEmptyAfterTrimming: Bool {
        self.trimmed.isEmpty
    }
    
    /// Splits the string by newlines and filters out empty lines
    var nonEmptyLines: [String] {
        self.components(separatedBy: .newlines)
            .map { $0.trimmed }
            .filter { !$0.isEmpty }
    }
}
