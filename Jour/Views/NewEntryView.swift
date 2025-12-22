//
//  NewEntryView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Ultra-minimal modal view for creating new journal entries
/// Simple, clean design with time-based prompts and entry modes
struct NewEntryView: View {
    // MARK: - Properties
    
    /// Reference to the journal manager for saving entries
    @ObservedObject var journalManager: JournalManager
    
    /// Environment value for dismissing the modal
    @Environment(\.dismiss) private var dismiss
    
    /// The main text content of the journal entry
    @State private var entryText = ""
    
    /// Selected time period for time-based entries
    @State private var selectedTimePeriod: TimePeriod?
    
    /// Optional time string for the entry
    @State private var selectedTime = ""
    
    /// Whether the entry is in free-form mode (no prompt)
    @State private var isFreeForm = false
    
    /// Whether the entry is in quick entry mode (multiple entries from lines)
    @State private var isQuickEntry = false
    
    /// Whether a time period or entry type has been selected (shows content input)
    @State private var hasSelectedEntryType = false
    
    /// Optional specific date for the entry (if not provided, uses current date)
    private let selectedDate: Date?
    
    /// Callback when view is dismissed
    var onDismiss: (() -> Void)?
    
    @State private var showingDiscardAlert = false
    
    /// Trigger for confetti animation
    @State private var confettiCounter = 0
    
    /// Focus state for the text editor
    @FocusState private var isInputFocused: Bool
    
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
                    // MARK: - Ultra-Minimal Selection Screen
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 60)
                        
                        // Simple title
                        Text("What did you do?")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Spacer()
                            .frame(height: 60)
                        
                        // Time periods - clean buttons
                        VStack(spacing: 20) {
                            ForEach(TimePeriod.allCases, id: \.self) { period in
                                Button(action: {
                                    // Add haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    selectTimePeriod(period)
                                }) {
                                    HStack(spacing: 16) {
                                        Text(period.emoji)
                                            .font(.title)
                                        Text(period.rawValue)
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.headline)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    .padding()
                                    .background(
                                        ZStack {
                                            // 3D Lip
                                            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                                                .fill(AppConstants.Colors.duoBlueDark)
                                                .offset(y: 6)
                                            
                                            // Face
                                            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                                                .fill(AppConstants.Colors.duoBlue)
                                        }
                                    )
                                    .padding(.bottom, 6) // Compensate for lip
                                }
                                .buttonStyle(PlayfulButtonStyle())
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        // Minimal divider
                        Rectangle()
                            .fill(AppConstants.Colors.cardBorder)
                            .frame(height: 1)
                            .frame(width: 100)
                            .padding(.vertical, 40)
                        
                        // Alternative entry options - clean buttons
                        VStack(spacing: 20) {
                            Button(action: {
                                // Add haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                selectFreeForm()
                            }) {
                                HStack(spacing: 16) {
                                    Text("📝")
                                        .font(.title)
                                    Text("Free write")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding()
                                .background(
                                    ZStack {
                                        // 3D Lip
                                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                                            .fill(AppConstants.Colors.duoPurpleDark)
                                            .offset(y: 6)
                                        
                                        // Face
                                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                                            .fill(AppConstants.Colors.duoPurple)
                                    }
                                )
                                .padding(.bottom, 6)
                            }
                            .buttonStyle(PlayfulButtonStyle())
                            
                            Button(action: {
                                // Add haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                selectQuickEntry()
                            }) {
                                HStack(spacing: 16) {
                                    Text("⚡")
                                        .font(.title)
                                    Text("Quick entry")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding()
                                .background(
                                    ZStack {
                                        // 3D Lip
                                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                                            .fill(AppConstants.Colors.duoYellowDark)
                                            .offset(y: 6)
                                        
                                        // Face
                                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                                            .fill(AppConstants.Colors.duoYellow)
                                    }
                                )
                                .padding(.bottom, 6)
                            }
                            .buttonStyle(PlayfulButtonStyle())
                        }
                        .padding(.horizontal, 40)
                        
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
                                    .focused($isInputFocused)
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
                                    .onAppear {
                                        // Auto-focus when text editor appears
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            isInputFocused = true
                                        }
                                    }
                                
                                // Placeholder text for quick entry
                                if isQuickEntry && entryText.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("went to lunch")
                                            .foregroundColor(AppConstants.Colors.placeholderText)
                                            .font(.body)
                                        Text("called mom")
                                            .foregroundColor(AppConstants.Colors.placeholderText)
                                            .font(.body)
                                        Text("worked out")
                                            .foregroundColor(AppConstants.Colors.placeholderText)
                                            .font(.body)
                                    }
                                    .padding(.leading, AppConstants.Spacing.lg + 5)
                                    .padding(.top, AppConstants.Spacing.lg + 8)
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
            return "Free Write"
        } else if let period = selectedTimePeriod {
            return period.rawValue
        } else {
            return "Entry"
        }
    }
    
    /// Returns the title for the content input section
    private var contentInputTitle: String {
        if isQuickEntry {
            return "What did you do today? (one per line)"
        } else if let period = selectedTimePeriod {
            return period.prompt
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
    
    /// Handles time period selection and transitions to content input
    private func selectTimePeriod(_ period: TimePeriod) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        selectedTimePeriod = period
        isFreeForm = false
        isQuickEntry = false
        hasSelectedEntryType = true
    }
    
    /// Handles free form entry selection and transitions to content input
    private func selectFreeForm() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        selectedTimePeriod = nil
        isFreeForm = true
        isQuickEntry = false
        hasSelectedEntryType = true
    }
    
    /// Handles quick entry selection and transitions to content input
    private func selectQuickEntry() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        selectedTimePeriod = nil
        isFreeForm = false
        isQuickEntry = true
        hasSelectedEntryType = true
    }
    
    /// Returns to the initial selection screen
    private func goBackToSelection() {
        hasSelectedEntryType = false
        selectedTimePeriod = nil
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
            // Single entry - store time period as category if selected
            let category = selectedTimePeriod?.rawValue
            let entry = JournalEntry(content: content, category: category, date: date, time: time)
            journalManager.saveEntry(entry)
        }
        
        // Trigger confetti then close
        confettiCounter += 1
        // returnToPrevious() // No delay needed, confetti is on top, but maybe a slight delay to see it before sheet closes? 
        // Actually, since the sheet closes, the confetti might disappear.
        // Good point. It's better to trigger confetti on the PARENT view or delay dismissal.
        // For now, let's delay dismissal slightly.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            onDismiss?()
            dismiss()
        }
    }
}
