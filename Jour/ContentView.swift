//
//  ContentView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Main view of the app that contains the tab navigation and core functionality
/// This view serves as the root container for the journal app's main features
struct ContentView: View {
    // MARK: - State Properties
    
    /// Manages all journal data and business logic
    @StateObject private var journalManager = JournalManager()
    
    /// Controls the presentation of the new entry sheet
    @State private var showingNewEntry = false
    
    // MARK: - Body
    
    var body: some View {
        TabView {
            // MARK: - Timeline Tab
            VStack(spacing: 0) {
                // Header with app title and main action
                VStack(spacing: 16) {
                    // App Title
                    VStack(spacing: AppConstants.Spacing.xs) {
                        Text(AppConstants.appName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .primaryTextStyle()
                        
                        Text(AppConstants.appTagline)
                            .font(.subheadline)
                            .secondaryTextStyle()
                    }
                    .padding(.top, AppConstants.Spacing.xl)
                    
                    // Main Log Day Button
                    Button(action: {
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        showingNewEntry = true
                    }) {
                        HStack(spacing: AppConstants.Spacing.sm) {
                            Image(systemName: "plus")
                                .font(.headline)
                            Text("Log Day")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .primaryTextStyle()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppConstants.Spacing.lg)
                        .buttonGradientStyle()
                    }
                    .accessibilityLabel(AppConstants.Accessibility.logDayButton)
                    .horizontalPadding()
                    .scaleEffect(showingNewEntry ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showingNewEntry)
                    
                    // Streak Display
                    StreakDisplay(streak: journalManager.streak)
                        .horizontalPadding()
                }
                .padding(.bottom, AppConstants.Spacing.xl)
                .primaryGradientBackground()
                
                // Timeline showing all journal entries
                TimelineView(journalManager: journalManager)
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Timeline")
            }
            
            // MARK: - Calendar Tab
            CalendarView(journalManager: journalManager)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingNewEntry) {
            NewEntryView(journalManager: journalManager)
        }
    }
}

#Preview {
    ContentView()
}
