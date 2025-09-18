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
            VStack {
                // Display current streak information
                StreakDisplay(streak: journalManager.streak)
                    .padding()
                
                // Button to create a new journal entry
                Button("Log Day") {
                    showingNewEntry = true
                }
                .buttonStyle(.borderedProminent)
                .font(.headline)
                .padding(.bottom)
                
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
        .sheet(isPresented: $showingNewEntry) {
            NewEntryView(journalManager: journalManager)
        }
    }
}

#Preview {
    ContentView()
}
