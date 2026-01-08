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
    
    /// Reference to the theme manager
    @EnvironmentObject var themeManager: ThemeManager
    
    /// Currently selected date in the calendar
    @State private var selectedDate = Date()
    
    /// Controls the presentation of the new entry sheet
    @State private var showingEntryModal = false
    
    /// Controls whether to show copy confirmation alert
    @State private var showingCopyAlert = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Calendar Picker
                VStack(spacing: AppConstants.Spacing.lg) {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
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
                            
                            // Copy Day button
                            Button(action: {
                                copyDayToClipboard()
                            }) {
                                Image(systemName: "doc.on.clipboard")
                                    .font(.headline)
                                    .foregroundColor(AppConstants.Colors.primaryText)
                                    .frame(width: 44, height: 44)
                            }
                            
                            // Add Entry button
                            Button(action: {
                                showingEntryModal = true
                            }) {
                                HStack(spacing: AppConstants.Spacing.xs) {
                                    Image(systemName: "plus")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Text("Add")
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
                            List {
                                ForEach(entriesForSelectedDate) { entry in
                                    EntryRowView(entry: entry)
                                        .onTapGesture {
                                            editingEntry = entry
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                entryToDelete = entry
                                                showingDeleteConfirmation = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button {
                                                editingEntry = entry
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            .tint(AppConstants.Colors.accentButton)
                                        }
                                        .listRowInsets(EdgeInsets())
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)) // Match AppConstants.Spacing.xl
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
            }
            .background(AppConstants.Colors.primaryBackground)
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEntryModal) {
                NewEntryView(journalManager: journalManager, selectedDate: selectedDate)
                    .environmentObject(themeManager)
            }
            .sheet(item: $editingEntry) { entry in
                EditEntryView(journalManager: journalManager, entry: entry)
                    .environmentObject(themeManager)
            }
            .alert("Copied to Clipboard", isPresented: $showingCopyAlert) {
                Button("OK") { }
            } message: {
                Text("Entries for \(formatDateShort(selectedDate)) copied to clipboard")
            }
            .confirmationDialog(
                "Delete this entry?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let entry = entryToDelete {
                        withAnimation(.spring()) {
                            journalManager.deleteEntry(entry)
                        }
                    }
                    entryToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    entryToDelete = nil
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Returns all journal entries for the currently selected date
    private var entriesForSelectedDate: [JournalEntry] {
        journalManager.getEntriesForDate(selectedDate)
    }
    
    // MARK: - State Properties
    @State private var editingEntry: JournalEntry?
    @State private var entryToDelete: JournalEntry?
    @State private var showingDeleteConfirmation = false
    
    // MARK: - Private Methods
    
    /// Formats a date for display in the calendar view
    /// - Parameter date: The date to format
    /// - Returns: Formatted date string using full date style
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    /// Formats a date for short display (e.g., "Dec 6")
    /// - Parameter date: The date to format
    /// - Returns: Short formatted date string
    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    /// Copies the selected day's entries to clipboard
    private func copyDayToClipboard() {
        let entries = entriesForSelectedDate
        
        guard !entries.isEmpty else {
            // No entries to copy
            return
        }
        
        let formatted = journalManager.formatEntriesForClipboard(entries)
        UIPasteboard.general.string = formatted
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Show confirmation
        showingCopyAlert = true
    }
}
