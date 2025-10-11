//
//  PerformanceMonitor.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import Foundation
import SwiftUI

/// Monitors app performance and memory usage
/// Provides insights into app performance and helps identify issues
class PerformanceMonitor: ObservableObject {
    // MARK: - Published Properties
    
    /// Current memory usage in MB
    @Published var memoryUsage: Double = 0
    
    /// App launch time in seconds
    @Published var launchTime: Double = 0
    
    /// Number of journal entries loaded
    @Published var entryCount: Int = 0
    
    // MARK: - Private Properties
    
    /// Timer for monitoring performance
    private var monitoringTimer: Timer?
    
    /// App launch start time
    private var launchStartTime: Date?
    
    // MARK: - Singleton
    
    static let shared = PerformanceMonitor()
    
    private init() {
        startLaunchTimer()
    }
    
    // MARK: - Public Methods
    
    /// Starts monitoring app performance
    func startMonitoring() {
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.updatePerformanceMetrics()
        }
    }
    
    /// Stops monitoring app performance
    func stopMonitoring() {
        monitoringTimer?.invalidate()
        monitoringTimer = nil
    }
    
    /// Records app launch completion
    func recordLaunchCompletion() {
        if let startTime = launchStartTime {
            launchTime = Date().timeIntervalSince(startTime)
            launchStartTime = nil
        }
    }
    
    /// Updates entry count
    /// - Parameter count: The current number of entries
    func updateEntryCount(_ count: Int) {
        entryCount = count
    }
    
    /// Gets current memory usage
    /// - Returns: Memory usage in MB
    func getCurrentMemoryUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024.0 / 1024.0
        } else {
            return 0
        }
    }
    
    /// Checks if app performance is within acceptable limits
    /// - Returns: True if performance is good, false otherwise
    func isPerformanceGood() -> Bool {
        return memoryUsage < 100.0 && launchTime < 3.0
    }
    
    /// Gets performance report
    /// - Returns: Formatted performance report
    func getPerformanceReport() -> String {
        var report = "Performance Report\n"
        report += "==================\n"
        report += "Memory Usage: \(String(format: "%.2f", memoryUsage)) MB\n"
        report += "Launch Time: \(String(format: "%.2f", launchTime)) seconds\n"
        report += "Entry Count: \(entryCount)\n"
        report += "Performance Status: \(isPerformanceGood() ? "Good" : "Needs Attention")\n"
        return report
    }
    
    // MARK: - Private Methods
    
    /// Starts the launch timer
    private func startLaunchTimer() {
        launchStartTime = Date()
    }
    
    /// Updates performance metrics
    private func updatePerformanceMetrics() {
        DispatchQueue.main.async {
            self.memoryUsage = self.getCurrentMemoryUsage()
        }
    }
}

// MARK: - Performance View

/// View for displaying performance information (debug only)
struct PerformanceView: View {
    @ObservedObject var performanceMonitor = PerformanceMonitor.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
            Text("Performance Monitor")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppConstants.Colors.primaryText)
            
            HStack {
                Text("Memory Usage:")
                    .foregroundColor(AppConstants.Colors.secondaryText)
                Spacer()
                Text("\(String(format: "%.2f", performanceMonitor.memoryUsage)) MB")
                    .foregroundColor(AppConstants.Colors.primaryText)
            }
            
            HStack {
                Text("Launch Time:")
                    .foregroundColor(AppConstants.Colors.secondaryText)
                Spacer()
                Text("\(String(format: "%.2f", performanceMonitor.launchTime))s")
                    .foregroundColor(AppConstants.Colors.primaryText)
            }
            
            HStack {
                Text("Entry Count:")
                    .foregroundColor(AppConstants.Colors.secondaryText)
                Spacer()
                Text("\(performanceMonitor.entryCount)")
                    .foregroundColor(AppConstants.Colors.primaryText)
            }
            
            HStack {
                Text("Status:")
                    .foregroundColor(AppConstants.Colors.secondaryText)
                Spacer()
                Text(performanceMonitor.isPerformanceGood() ? "Good" : "Needs Attention")
                    .foregroundColor(performanceMonitor.isPerformanceGood() ? 
                                   AppConstants.Colors.successColor : 
                                   AppConstants.Colors.warningColor)
            }
        }
        .padding(AppConstants.Spacing.lg)
        .background(AppConstants.Colors.secondaryBackground)
        .cornerRadius(AppConstants.CornerRadius.md)
        .shadow(
            color: AppConstants.Shadows.card.color,
            radius: AppConstants.Shadows.card.radius,
            x: AppConstants.Shadows.card.x,
            y: AppConstants.Shadows.card.y
        )
    }
}

// MARK: - Performance Modifier

/// View modifier for adding performance monitoring
struct PerformanceMonitoringModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                PerformanceMonitor.shared.startMonitoring()
            }
            .onDisappear {
                PerformanceMonitor.shared.stopMonitoring()
            }
    }
}

// MARK: - View Extension

extension View {
    /// Adds performance monitoring to the view
    /// - Returns: The view with performance monitoring
    func performanceMonitoring() -> some View {
        self.modifier(PerformanceMonitoringModifier())
    }
}
