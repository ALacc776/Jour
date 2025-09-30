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
            VStack(spacing: 0) {
                // MARK: - Calendar Picker
                VStack(spacing: 16) {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .colorScheme(.dark)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // MARK: - Entries for Selected Date
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Entries for \(formatDate(selectedDate))")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                showingEntryModal = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.caption)
                                    Text("Add Entry")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.8),
                                            Color.blue.opacity(0.6)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if entriesForSelectedDate.isEmpty {
                            // MARK: - Empty State for Selected Date
                            VStack(spacing: 16) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text("No entries for this date")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            // MARK: - List of Entries
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(entriesForSelectedDate) { entry in
                                        EntryRowView(entry: entry)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.indigo.opacity(0.1),
                            Color.purple.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                Spacer()
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
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
