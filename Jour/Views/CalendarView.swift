//
//  CalendarView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Displays a calendar interface for viewing and adding journal entries by date
/// Allows users to select specific dates and view/add entries for those dates
struct CalendarView: View {
    // MARK: - Properties
    
    /// Reference to the journal manager for accessing entries
    @ObservedObject var journalManager: JournalManager
    
    /// Currently selected date in the calendar
    @State private var selectedDate = Date()
    
    /// Controls the presentation of the new entry sheet
    @State private var showingEntryModal = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Calendar Picker
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                
                // MARK: - Entries for Selected Date
                VStack(alignment: .leading) {
                    HStack {
                        Text("Entries for \(formatDate(selectedDate))")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Add Entry") {
                            showingEntryModal = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)
                    
                    if entriesForSelectedDate.isEmpty {
                        // MARK: - Empty State for Selected Date
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("No entries for this date")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        // MARK: - List of Entries
                        List(entriesForSelectedDate) { entry in
                            EntryRowView(entry: entry)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Calendar")
            .sheet(isPresented: $showingEntryModal) {
                NewEntryView(journalManager: journalManager, selectedDate: selectedDate)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Returns all journal entries for the currently selected date
    private var entriesForSelectedDate: [JournalEntry] {
        journalManager.getEntriesForDate(selectedDate)
    }
    
    // MARK: - Private Methods
    
    /// Formats a date for display in the calendar view
    /// - Parameter date: The date to format
    /// - Returns: Formatted date string using full date style
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}
