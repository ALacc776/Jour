//
//  ErrorManager.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import Foundation
import SwiftUI

/// Manages error handling and user feedback throughout the app
/// Provides centralized error reporting and user-friendly error messages
class ErrorManager: ObservableObject {
    // MARK: - Published Properties
    
    /// Current error to display to the user
    @Published var currentError: AppError?
    
    /// Whether an error is currently being displayed
    @Published var isShowingError = false
    
    // MARK: - Singleton
    
    static let shared = ErrorManager()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Shows an error to the user
    /// - Parameter error: The error to display
    func showError(_ error: AppError) {
        DispatchQueue.main.async {
            self.currentError = error
            self.isShowingError = true
        }
    }
    
    /// Shows an error with a custom message
    /// - Parameters:
    ///   - title: The error title
    ///   - message: The error message
    ///   - type: The error type
    func showError(title: String, message: String, type: AppErrorType = .general) {
        let error = AppError(title: title, message: message, type: type)
        showError(error)
    }
    
    /// Dismisses the current error
    func dismissError() {
        DispatchQueue.main.async {
            self.isShowingError = false
            self.currentError = nil
        }
    }
    
    /// Handles a generic error and shows appropriate message
    /// - Parameter error: The error to handle
    func handleError(_ error: Error) {
        let appError: AppError
        
        if let privacyError = error as? PrivacyError {
            appError = AppError(
                title: "Privacy Error",
                message: privacyError.localizedDescription,
                type: .privacy
            )
        } else if let importError = error as? ImportError {
            appError = AppError(
                title: "Import Error",
                message: importError.localizedDescription,
                type: .data
            )
        } else {
            appError = AppError(
                title: "Error",
                message: error.localizedDescription,
                type: .general
            )
        }
        
        showError(appError)
    }
}

// MARK: - App Error Model

/// Represents an application error with user-friendly information
struct AppError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let type: AppErrorType
    let timestamp = Date()
    
    init(title: String, message: String, type: AppErrorType = .general) {
        self.title = title
        self.message = message
        self.type = type
    }
}

// MARK: - Error Types

/// Types of errors that can occur in the app
enum AppErrorType {
    case general
    case network
    case data
    case privacy
    case validation
    case system
    
    var icon: String {
        switch self {
        case .general: return "exclamationmark.triangle"
        case .network: return "wifi.exclamationmark"
        case .data: return "externaldrive.badge.exclamationmark"
        case .privacy: return "lock.shield"
        case .validation: return "checkmark.circle.badge.xmark"
        case .system: return "gear.badge.exclamationmark"
        }
    }
    
    var color: Color {
        switch self {
        case .general: return AppConstants.Colors.warningColor
        case .network: return AppConstants.Colors.errorColor
        case .data: return AppConstants.Colors.errorColor
        case .privacy: return AppConstants.Colors.accentButton
        case .validation: return AppConstants.Colors.warningColor
        case .system: return AppConstants.Colors.errorColor
        }
    }
}

// MARK: - Error View

/// View for displaying errors to the user
struct ErrorView: View {
    let error: AppError
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            // Error Icon
            Image(systemName: error.type.icon)
                .font(.system(size: 50))
                .foregroundColor(error.type.color)
            
            // Error Title
            Text(error.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppConstants.Colors.primaryText)
                .multilineTextAlignment(.center)
            
            // Error Message
            Text(error.message)
                .font(.body)
                .foregroundColor(AppConstants.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            // Dismiss Button
            Button("OK") {
                onDismiss()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppConstants.Spacing.md)
            .background(error.type.color)
            .cornerRadius(AppConstants.CornerRadius.md)
        }
        .padding(AppConstants.Spacing.xl)
        .background(AppConstants.Colors.secondaryBackground)
        .cornerRadius(AppConstants.CornerRadius.lg)
        .shadow(
            color: AppConstants.Shadows.elevated.color,
            radius: AppConstants.Shadows.elevated.radius,
            x: AppConstants.Shadows.elevated.x,
            y: AppConstants.Shadows.elevated.y
        )
    }
}

// MARK: - Error Alert Modifier

/// View modifier for showing error alerts
struct ErrorAlertModifier: ViewModifier {
    @ObservedObject var errorManager: ErrorManager
    
    func body(content: Content) -> some View {
        content
            .alert(
                errorManager.currentError?.title ?? "Error",
                isPresented: $errorManager.isShowingError
            ) {
                Button("OK") {
                    errorManager.dismissError()
                }
            } message: {
                if let error = errorManager.currentError {
                    Text(error.message)
                }
            }
    }
}

// MARK: - View Extension

extension View {
    /// Adds error handling to the view
    /// - Parameter errorManager: The error manager to use
    /// - Returns: The view with error handling
    func errorHandling(_ errorManager: ErrorManager = ErrorManager.shared) -> some View {
        self.modifier(ErrorAlertModifier(errorManager: errorManager))
    }
}
