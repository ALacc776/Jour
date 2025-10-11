//
//  JourApp.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Main entry point for the Jour journaling app
/// This is where the app starts and the main window is configured
@main
struct JourApp: App {
    // MARK: - App Body
    
    /// Defines the main scene and root view of the application
    var body: some Scene {
        WindowGroup {
            ContentView()
                .errorHandling()
                .performanceMonitoring()
                .onAppear {
                    // Record app launch completion
                    PerformanceMonitor.shared.recordLaunchCompletion()
                }
        }
    }
}
