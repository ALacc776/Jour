//
//  ContentView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI
struct ContentView: View {
    @StateObject private var journalManager = JournalManager()
    @State private var showingNewEntry = false
    
    var body: some View {
        TabView {
            // Timeline Tab
            VStack {
                StreakDisplay(streak: journalManager.streak)
                    .padding()
                
                Button("Log Day") {
                    showingNewEntry = true
                }
                .buttonStyle(.borderedProminent)
                .font(.headline)
                .padding(.bottom)
                
                TimelineView(journalManager: journalManager)
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Timeline")
            }
            
            // Calendar Tab
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
