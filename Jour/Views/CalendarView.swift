//
//  CalendarView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var journalManager: JournalManager
    @State private var selectedDate = Date()
    @State private var showingEntryModal = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Calendar
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                
                // Entries for selected date
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
    
    private var entriesForSelectedDate: [JournalEntry] {
        journalManager.getEntriesForDate(selectedDate)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}
