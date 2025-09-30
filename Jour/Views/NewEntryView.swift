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
                    VStack(spacing: 24) {
                        // Title
                        Text("What did you do today?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                        
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
                        .padding(.horizontal, 20)
                        
                        // OR Separator
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            
                            Text("OR")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 20)
                        
                        // Alternative Entry Options
                        VStack(spacing: 12) {
                            Button(action: {
                                selectFreeForm()
                            }) {
                                HStack {
                                    Text("📝")
                                        .font(.title2)
                                    Text("Free write entry")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
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
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.indigo.opacity(0.3),
                                Color.purple.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                } else {
                    // MARK: - Content Input Screen
                    VStack(spacing: 20) {
                        // Back button and title
                        HStack {
                            Button(action: {
                                goBackToSelection()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            Text(entryTypeTitle)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Invisible spacer to center the title
                            Color.clear
                                .frame(width: 20, height: 20)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Time Input (only for categorized entries)
                        if !isFreeForm && selectedCategory != nil {
                            HStack {
                                Text("Time (optional):")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                TextField("e.g., 14:30", text: $selectedTime)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numbersAndPunctuation)
                                    .colorScheme(.dark)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Content Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text(contentInputTitle)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            if isQuickEntry {
                                Text("Each line will become a separate entry")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.horizontal, 20)
                            }
                            
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $entryText)
                                    .padding()
                                    .font(.body)
                                    .colorScheme(.dark)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.1))
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
                                            .foregroundColor(.white.opacity(0.5))
                                            .font(.body)
                                        Text("met james")
                                            .foregroundColor(.white.opacity(0.5))
                                            .font(.body)
                                        Text("ate food")
                                            .foregroundColor(.white.opacity(0.5))
                                            .font(.body)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .allowsHitTesting(false)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.indigo.opacity(0.3),
                                Color.purple.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
        }
        .navigationTitle("Log Day")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white)
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
                    .foregroundColor(.white)
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
                .foregroundColor(.white)
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
