//
//  SearchView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Search view for finding entries by text content
/// Provides simple, fast text-based filtering
struct SearchView: View {
    // MARK: - Properties
    
    /// Reference to the journal manager
    @ObservedObject var journalManager: JournalManager
    
    /// Environment value for dismissing
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    /// Search query text
    @State private var searchText = ""
    
    /// Entry being edited
    @State private var editingEntry: JournalEntry?
    
    /// Focus state for search field
    @FocusState private var isSearchFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: AppConstants.Spacing.md) {
                    HStack(spacing: AppConstants.Spacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                            .font(.body)
                        
                        TextField("Search entries...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .focused($isSearchFocused)
                            .autocorrectionDisabled()
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppConstants.Colors.tertiaryText)
                                    .font(.body)
                            }
                        }
                    }
                    .padding(AppConstants.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                            .fill(AppConstants.Colors.secondaryBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                                    .stroke(
                                        isSearchFocused ? AppConstants.Colors.accentButton : AppConstants.Colors.cardBorder,
                                        lineWidth: isSearchFocused ? 2 : 1
                                    )
                            )
                    )
                }
                .padding(.horizontal, AppConstants.Spacing.xl)
                .padding(.vertical, AppConstants.Spacing.md)
                
                // Results
                if searchText.trimmed.isEmpty {
                    // Empty state
                    VStack(spacing: AppConstants.Spacing.lg) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(AppConstants.Colors.tertiaryText)
                        
                        Text("Search your entries")
                            .font(.headline)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Text("Type to find entries by content")
                            .font(.subheadline)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cleanBackground()
                } else if filteredEntries.isEmpty {
                    // No results
                    VStack(spacing: AppConstants.Spacing.lg) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(AppConstants.Colors.tertiaryText)
                        
                        Text("No results found")
                            .font(.headline)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Text("Try different keywords")
                            .font(.subheadline)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cleanBackground()
                } else {
                    // Search results
                    ScrollView {
                        LazyVStack(spacing: AppConstants.Spacing.lg) {
                            ForEach(groupedFilteredEntries, id: \.0) { date, entries in
                                VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
                                    // Date header
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(AppConstants.Colors.accentButton)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        
                                        Text(formatDate(date))
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(AppConstants.Colors.primaryText)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, AppConstants.Spacing.xl)
                                    
                                    // Entries for this date
                                    VStack(spacing: AppConstants.Spacing.sm) {
                                        ForEach(entries) { entry in
                                            EntryRowView(entry: entry)
                                                .onTapGesture {
                                                    editingEntry = entry
                                                }
                                                .swipeActions(edge: .trailing) {
                                                    Button("Delete", role: .destructive) {
                                                        withAnimation(.spring()) {
                                                            journalManager.deleteEntry(entry)
                                                        }
                                                    }
                                                }
                                                .swipeActions(edge: .leading) {
                                                    Button {
                                                        editingEntry = entry
                                                    } label: {
                                                        Label("Edit", systemImage: "pencil")
                                                    }
                                                    .tint(AppConstants.Colors.accentButton)
                                                }
                                        }
                                    }
                                    .padding(.horizontal, AppConstants.Spacing.xl)
                                }
                            }
                        }
                        .padding(.vertical, AppConstants.Spacing.lg)
                    }
                    .cleanBackground()
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppConstants.Colors.accentButton)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EditEntryView(journalManager: journalManager, entry: entry)
            }
            .onAppear {
                isSearchFocused = true
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Filters entries based on search text
    private var filteredEntries: [JournalEntry] {
        let query = searchText.trimmed.lowercased()
        guard !query.isEmpty else { return [] }
        
        return journalManager.entries.filter { entry in
            entry.content.lowercased().contains(query) ||
            (entry.category?.lowercased().contains(query) ?? false)
        }
    }
    
    /// Groups filtered entries by date
    private var groupedFilteredEntries: [(Date, [JournalEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        return grouped.sorted { $0.key > $1.key }
    }
    
    // MARK: - Methods
    
    /// Formats a date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

#Preview {
    SearchView(journalManager: JournalManager())
}

