//
//  NewEntryView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Modal view for creating new journal entries
/// Supports both categorized and free-form entry modes with optional time and date selection
struct NewEntryView: View {
    // MARK: - Properties
    
    /// Reference to the journal manager for saving entries
    @ObservedObject var journalManager: JournalManager
    
    /// Environment value for dismissing the modal
    @Environment(\.dismiss) private var dismiss
    
    /// The main text content of the journal entry
    @State private var entryText = ""
    
    /// Selected category for categorized entries
    @State private var selectedCategory: JournalCategory?
    
    /// Optional time string for the entry
    @State private var selectedTime = ""
    
    /// Whether the entry is in free-form mode (no category)
    @State private var isFreeForm = false
    
    /// Optional specific date for the entry (if not provided, uses current date)
    @State private var selectedDate: Date?
    
    // MARK: - Constants
    
    /// Number of columns in the category selection grid
    private let categoryGridColumns = 2
    
    /// Vertical spacing between grid items
    private let categoryGridSpacing: CGFloat = 12
    
    /// Vertical padding for category buttons
    private let categoryButtonPadding: CGFloat = 12
    
    // MARK: - Initialization
    
    /// Creates a new entry view with optional pre-selected date
    /// - Parameters:
    ///   - journalManager: The journal manager instance
    ///   - selectedDate: Optional date to pre-fill for the entry
    init(journalManager: JournalManager, selectedDate: Date? = nil) {
        self.journalManager = journalManager
        self.selectedDate = selectedDate
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // MARK: - Entry Mode Selection
                Picker("Entry Mode", selection: $isFreeForm) {
                    Text("Category").tag(false)
                    Text("Free Form").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if !isFreeForm {
                    // MARK: - Category Selection Grid
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: categoryGridColumns),
                        spacing: categoryGridSpacing
                    ) {
                        ForEach(JournalCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - Time Input
                HStack {
                    Text("Time (optional):")
                        .font(.headline)
                    
                    TextField("e.g., 14:30", text: $selectedTime)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numbersAndPunctuation)
                }
                .padding(.horizontal)
                
                // MARK: - Content Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("What happened?")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextEditor(text: $entryText)
                        .padding()
                        .font(.body)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Log Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Saves the current journal entry with all user input
    /// Validates content, creates a JournalEntry object, and saves it through the journal manager
    private func saveEntry() {
        let content = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        let category = isFreeForm ? nil : selectedCategory?.rawValue
        let time = selectedTime.isEmpty ? nil : selectedTime
        let date = selectedDate ?? Date()
        
        let entry = JournalEntry(content: content, category: category, date: date, time: time)
        journalManager.saveEntry(entry)
        dismiss()
    }
}
