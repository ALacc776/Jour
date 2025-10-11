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
    
    /// Whether the entry is in quick entry mode (multiple entries from lines)
    @State private var isQuickEntry = false
    
    /// Whether a category or entry type has been selected (shows content input)
    @State private var hasSelectedEntryType = false
    
    /// Optional specific date for the entry (if not provided, uses current date)
    @State private var selectedDate: Date?
    
    // MARK: - Constants
    
    /// Number of columns in the category selection grid
    private let categoryGridColumns = AppConstants.Layout.categoryGridColumns
    
    /// Vertical spacing between grid items
    private let categoryGridSpacing = AppConstants.Layout.categoryGridSpacing
    
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
        NavigationStack {
            VStack(spacing: 0) {
                if !hasSelectedEntryType {
                    // MARK: - Initial Selection Screen
                    VStack(spacing: AppConstants.Spacing.xxxl) {
                        // Title
                        Text("What did you do today?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(.top, AppConstants.Spacing.xxxl)
                        
                        // Category Selection Grid
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible()), count: categoryGridColumns),
                            spacing: categoryGridSpacing
                        ) {
                            ForEach(JournalCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectCategory(category)
                                }
                            }
                        }
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        
                        // OR Separator
                        HStack {
                            Rectangle()
                                .fill(AppConstants.Colors.cardBorder)
                                .frame(height: 1)
                            
                            Text("OR")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(AppConstants.Colors.tertiaryText)
                                .padding(.horizontal, AppConstants.Spacing.lg)
                            
                            Rectangle()
                                .fill(AppConstants.Colors.cardBorder)
                                .frame(height: 1)
                        }
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        
                        // Alternative Entry Options
                        VStack(spacing: AppConstants.Spacing.md) {
                            Button(action: {
                                selectFreeForm()
                            }) {
                                HStack {
                                    Text("📝")
                                        .font(.title2)
                                    Text("Free write entry")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppConstants.Colors.primaryText)
                                    Spacer()
                                }
                                .padding(AppConstants.Spacing.lg)
                                .background(AppConstants.Colors.secondaryBackground)
                                .cornerRadius(AppConstants.CornerRadius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                                        .stroke(AppConstants.Colors.cardBorder, lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                selectQuickEntry()
                            }) {
                                HStack {
                                    Text("⚡")
                                        .font(.title2)
                                    Text("Quick entry (one line = one entry)")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppConstants.Colors.primaryText)
                                    Spacer()
                                }
                                .padding(AppConstants.Spacing.lg)
                                .background(AppConstants.Colors.secondaryBackground)
                                .cornerRadius(AppConstants.CornerRadius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                                        .stroke(AppConstants.Colors.cardBorder, lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        
                        Spacer()
                    }
                    .cleanBackground()
                } else {
                    // MARK: - Content Input Screen
                    VStack(spacing: AppConstants.Spacing.xl) {
                        // Back button and title
                        HStack {
                            Button(action: {
                                goBackToSelection()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppConstants.Colors.accentButton)
                            }
                            
                            Spacer()
                            
                            Text(entryTypeTitle)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppConstants.Colors.primaryText)
                            
                            Spacer()
                            
                            // Invisible spacer to center the title
                            Color.clear
                                .frame(width: 20, height: 20)
                        }
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        .padding(.top, AppConstants.Spacing.lg)
                        
                        // Time Input (only for categorized entries)
                        if !isFreeForm && selectedCategory != nil {
                            HStack {
                                Text("Time (optional):")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppConstants.Colors.primaryText)
                                
                                TextField("e.g., 14:30", text: $selectedTime)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numbersAndPunctuation)
                                    .colorScheme(.light)
                            }
                            .padding(.horizontal, AppConstants.Spacing.xl)
                        }
                        
                        // Content Input
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                            Text(contentInputTitle)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(AppConstants.Colors.primaryText)
                                .padding(.horizontal, AppConstants.Spacing.xl)
                            
                            if isQuickEntry {
                                Text("Each line will become a separate entry")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppConstants.Colors.secondaryText)
                                    .padding(.horizontal, AppConstants.Spacing.xl)
                            }
                            
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $entryText)
                                    .padding(AppConstants.Spacing.lg)
                                    .font(.body)
                                    .colorScheme(.light)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                                            .stroke(AppConstants.Colors.cardBorder, lineWidth: 1)
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                                            .fill(AppConstants.Colors.secondaryBackground)
                                    )
                                    .scrollContentBackground(.hidden)
                                    .onSubmit {
                                        // Allow submitting with keyboard
                                        if !entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            saveEntry()
                                        }
                                    }
                                
                                // Placeholder text for quick entry
                                if isQuickEntry && entryText.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Went to sleep")
                                            .foregroundColor(AppConstants.Colors.placeholderText)
                                            .font(.body)
                                        Text("met james")
                                            .foregroundColor(AppConstants.Colors.placeholderText)
                                            .font(.body)
                                        Text("ate food")
                                            .foregroundColor(AppConstants.Colors.placeholderText)
                                            .font(.body)
                                    }
                                    .padding(.horizontal, AppConstants.Spacing.lg)
                                    .padding(.vertical, AppConstants.Spacing.md)
                                    .allowsHitTesting(false)
                                }
                            }
                            .padding(.horizontal, AppConstants.Spacing.xl)
                        }
                        
                        Spacer()
                    }
                    .cleanBackground()
                }
        }
        .navigationTitle("Log Day")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(AppConstants.Colors.primaryText)
            }
            
            if hasSelectedEntryType {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(saveButtonTitle) {
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        saveEntry()
                    }
                    .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundColor(AppConstants.Colors.accentButton)
                    .fontWeight(.semibold)
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
                .foregroundColor(AppConstants.Colors.accentButton)
                .fontWeight(.semibold)
            }
        }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Returns the title for the current entry type
    private var entryTypeTitle: String {
        if isQuickEntry {
            return "Quick Entry"
        } else if isFreeForm {
            return "Free Write Entry"
        } else if let category = selectedCategory {
            return category.rawValue
        } else {
            return "Entry"
        }
    }
    
    /// Returns the title for the content input section
    private var contentInputTitle: String {
        if isQuickEntry {
            return "What did you do today? (one per line)"
        } else {
            return "What happened?"
        }
    }
    
    /// Returns the title for the save button based on entry type
    private var saveButtonTitle: String {
        if isQuickEntry {
            let lineCount = entryText.nonEmptyLines.count
            
            if lineCount <= 1 {
                return "Save"
            } else {
                return "Save \(lineCount) entries"
            }
        } else {
            return "Save"
        }
    }
    
    // MARK: - Private Methods
    
    /// Handles category selection and transitions to content input
    private func selectCategory(_ category: JournalCategory) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        selectedCategory = category
        isFreeForm = false
        isQuickEntry = false
        hasSelectedEntryType = true
    }
    
    /// Handles free form entry selection and transitions to content input
    private func selectFreeForm() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        selectedCategory = nil
        isFreeForm = true
        isQuickEntry = false
        hasSelectedEntryType = true
    }
    
    /// Handles quick entry selection and transitions to content input
    private func selectQuickEntry() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        selectedCategory = nil
        isFreeForm = false
        isQuickEntry = true
        hasSelectedEntryType = true
    }
    
    /// Returns to the initial selection screen
    private func goBackToSelection() {
        hasSelectedEntryType = false
        selectedCategory = nil
        isFreeForm = false
        isQuickEntry = false
        entryText = ""
        selectedTime = ""
    }
    
    /// Saves the current journal entry with all user input
    /// For quick entry mode, creates multiple entries from each line
    private func saveEntry() {
        let content = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        let date = selectedDate ?? Date()
        let time = selectedTime.isEmpty ? nil : selectedTime
        
        if isQuickEntry {
            // Split content by newlines and create separate entries
            let lines = content.nonEmptyLines
            
            for line in lines {
                let entry = JournalEntry(content: line, category: nil, date: date, time: time)
                journalManager.saveEntry(entry)
            }
        } else {
            // Single entry
            let category = isFreeForm ? nil : selectedCategory?.rawValue
            let entry = JournalEntry(content: content, category: category, date: date, time: time)
            journalManager.saveEntry(entry)
        }
        
        dismiss()
    }
}
