//
//  ThemeManager.swift
//  Jour
//
//  Created for DayLog v1.1
//

import SwiftUI

/// Manages the app's theme and provides dynamic color palettes
/// Supports System, Light, Dark, and Sepia themes
class ThemeManager: ObservableObject {
    // MARK: - Published Properties
    
    /// Current theme selection
    @Published var currentTheme: AppTheme {
        didSet {
            saveTheme()
        }
    }
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "app_theme"
    
    // MARK: - Initialization
    
    init() {
        // Load saved theme or default to system
        if let savedTheme = userDefaults.string(forKey: themeKey),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .system
        }
    }
    
    // MARK: - Public Methods
    
    /// Returns the appropriate color scheme for the current theme
    /// - Returns: ColorScheme or nil for system default
    func colorScheme() -> ColorScheme? {
        switch currentTheme {
        case .system:
            return nil // Let system decide
        case .light:
            return .light
        case .dark:
            return .dark
        case .sepia:
            return .light // Sepia uses light mode as base
        }
    }
    
    /// Returns the theme colors for the current theme
    /// - Parameter systemColorScheme: The system's current color scheme
    /// - Returns: ThemeColors struct with all color definitions
    func colors(for systemColorScheme: ColorScheme) -> ThemeColors {
        switch currentTheme {
        case .system:
            return systemColorScheme == .dark ? ThemeColors.dark : ThemeColors.light
        case .light:
            return ThemeColors.light
        case .dark:
            return ThemeColors.dark
        case .sepia:
            return ThemeColors.sepia
        }
    }
    
    // MARK: - Private Methods
    
    /// Saves the current theme to UserDefaults
    private func saveTheme() {
        userDefaults.set(currentTheme.rawValue, forKey: themeKey)
    }
}

// MARK: - AppTheme Enum

/// Available theme options
enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case sepia = "Sepia"
    
    var id: String { rawValue }
    
    /// Icon for each theme
    var icon: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .sepia:
            return "book.fill"
        }
    }
    
    /// Description for each theme
    var description: String {
        switch self {
        case .system:
            return "Matches your device settings"
        case .light:
            return "Bright and clean"
        case .dark:
            return "Easy on the eyes"
        case .sepia:
            return "Warm and nostalgic"
        }
    }
}

// MARK: - ThemeColors Struct

/// Color palette for a specific theme
struct ThemeColors {
    let primaryBackground: Color
    let secondaryBackground: Color
    let tertiaryBackground: Color
    let cardBackground: Color
    let cardBorder: Color
    let primaryText: Color
    let secondaryText: Color
    let tertiaryText: Color
    let accentButton: Color
    let primaryButton: Color
    
    // MARK: - Predefined Themes
    
    /// Light theme colors
    static let light = ThemeColors(
        primaryBackground: Color(UIColor.systemGroupedBackground),
        secondaryBackground: Color(UIColor.secondarySystemGroupedBackground),
        tertiaryBackground: Color(UIColor.tertiarySystemGroupedBackground),
        cardBackground: Color(UIColor.secondarySystemGroupedBackground),
        cardBorder: Color(UIColor.separator),
        primaryText: Color(UIColor.label),
        secondaryText: Color(UIColor.secondaryLabel),
        tertiaryText: Color(UIColor.tertiaryLabel),
        accentButton: Color(red: 0.95, green: 0.6, blue: 0.3), // Warm orange
        primaryButton: Color(red: 0.2, green: 0.2, blue: 0.25) // Dark gray
    )
    
    /// Dark theme colors
    static let dark = ThemeColors(
        primaryBackground: Color(UIColor.systemGroupedBackground),
        secondaryBackground: Color(UIColor.secondarySystemGroupedBackground),
        tertiaryBackground: Color(UIColor.tertiarySystemGroupedBackground),
        cardBackground: Color(UIColor.secondarySystemGroupedBackground),
        cardBorder: Color(UIColor.separator),
        primaryText: Color(UIColor.label),
        secondaryText: Color(UIColor.secondaryLabel),
        tertiaryText: Color(UIColor.tertiaryLabel),
        accentButton: Color(red: 0.95, green: 0.6, blue: 0.3), // Warm orange
        primaryButton: Color(red: 0.8, green: 0.8, blue: 0.85) // Light gray for dark mode
    )
    
    /// Sepia theme colors (warm, nostalgic) - Rich beige aesthetic
    static let sepia = ThemeColors(
        primaryBackground: Color(red: 0.91, green: 0.84, blue: 0.72), // Rich warm beige (#E8D5B7)
        secondaryBackground: Color(red: 0.94, green: 0.90, blue: 0.82), // Lighter beige (#F0E6D2)
        tertiaryBackground: Color(red: 0.88, green: 0.80, blue: 0.68), // Medium beige (#E0CCAD)
        cardBackground: Color(red: 0.94, green: 0.90, blue: 0.82), // Light beige card (#F0E6D2)
        cardBorder: Color(red: 0.78, green: 0.70, blue: 0.58), // Warm tan border (#C7B294)
        primaryText: Color(red: 0.24, green: 0.16, blue: 0.12), // Dark warm brown (#3E2A1F)
        secondaryText: Color(red: 0.45, green: 0.35, blue: 0.28), // Medium brown (#735947)
        tertiaryText: Color(red: 0.58, green: 0.50, blue: 0.42), // Light brown (#94806B)
        accentButton: Color(red: 0.82, green: 0.52, blue: 0.25), // Warm terracotta (#D18540)
        primaryButton: Color(red: 0.35, green: 0.26, blue: 0.20) // Rich brown button (#59422F)
    )
}
