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
                VStack(spacing: AppConstants.Spacing.lg) {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .colorScheme(.light)
                        .padding(AppConstants.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                                .fill(AppConstants.Colors.secondaryBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                                        .stroke(AppConstants.Colors.cardBorder, lineWidth: 1)
                                )
                        )
                        .shadow(
                            color: AppConstants.Shadows.card.color,
                            radius: AppConstants.Shadows.card.radius,
                            x: AppConstants.Shadows.card.x,
                            y: AppConstants.Shadows.card.y
                        )
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        .padding(.top, AppConstants.Spacing.xl)
                    
                    // MARK: - Entries for Selected Date
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.lg) {
                        HStack {
                            Text("Entries for \(formatDate(selectedDate))")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppConstants.Colors.primaryText)
                            
                            Spacer()
                            
                            Button(action: {
                                showingEntryModal = true
                            }) {
                                HStack(spacing: AppConstants.Spacing.xs) {
                                    Image(systemName: "plus")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Text("Add Entry")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, AppConstants.Spacing.lg)
                                .padding(.vertical, AppConstants.Spacing.sm)
                                .primaryButtonStyle()
                            }
                        }
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        
                        if entriesForSelectedDate.isEmpty {
                            // MARK: - Empty State for Selected Date
                            VStack(spacing: AppConstants.Spacing.lg) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(AppConstants.Colors.tertiaryText)
                                
                                Text("No entries for this date")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppConstants.Colors.secondaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppConstants.Spacing.xxxxl)
                        } else {
                            // MARK: - List of Entries
                            ScrollView {
                                LazyVStack(spacing: AppConstants.Spacing.md) {
                                    ForEach(entriesForSelectedDate) { entry in
                                        EntryRowView(entry: entry)
                                    }
                                }
                                .padding(.horizontal, AppConstants.Spacing.xl)
                                .padding(.bottom, AppConstants.Spacing.xl)
                            }
                        }
                    }
                }
                .cleanBackground()
                
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
