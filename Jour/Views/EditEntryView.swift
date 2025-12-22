//
//  EditEntryView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Simple view for editing existing journal entries
/// Replaces the complex NewEntryView for editing purposes
struct EditEntryView: View {
    // MARK: - Properties
    
    /// Reference to the journal manager
    @ObservedObject var journalManager: JournalManager
    
    /// The entry being edited
    let entry: JournalEntry
    
    /// Environment value for dismissing
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    /// Editable content
    @State private var editedContent: String
    
    /// Editable category
    @State private var editedCategory: String?
    
    /// Editable time
    @State private var editedTime: String
    
    /// Focus state for text editor
    @FocusState private var isTextFocused: Bool
    
    // MARK: - Initialization
    
    init(journalManager: JournalManager, entry: JournalEntry) {
        self.journalManager = journalManager
        self.entry = entry
        _editedContent = State(initialValue: entry.content)
        _editedCategory = State(initialValue: entry.category)
        _editedTime = State(initialValue: entry.time ?? "")
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.xl) {
                        // Date info (read-only)
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                            Text("Entry Date")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(AppConstants.Colors.secondaryText)
                                .textCase(.uppercase)
                            
                            Text(entry.date.displayFormat)
                                .font(.subheadline)
                                .foregroundColor(AppConstants.Colors.primaryText)
                        }
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        .padding(.top, AppConstants.Spacing.lg)
                        
                        // Content editor
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                            Text("Content")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppConstants.Colors.primaryText)
                            
                            TextEditor(text: $editedContent)
                                .frame(minHeight: 150)
                                .padding(AppConstants.Spacing.md)
                                .font(.body)
                                .focused($isTextFocused)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                                        .stroke(
                                            isTextFocused ? AppConstants.Colors.accentButton : AppConstants.Colors.cardBorder,
                                            lineWidth: isTextFocused ? 2 : 1
                                        )
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.md)
                                        .fill(AppConstants.Colors.secondaryBackground)
                                )
                        }
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        
                        // Category (optional)
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                            Text("Category (optional)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppConstants.Colors.primaryText)
                            
                            TextField("e.g., Work, Personal", text: Binding(
                                get: { editedCategory ?? "" },
                                set: { editedCategory = $0.isEmpty ? nil : $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                        }
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        
                        // Time (optional)
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                            Text("Time (optional)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppConstants.Colors.primaryText)
                            
                            TextField("e.g., 2:30 PM", text: $editedTime)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numbersAndPunctuation)
                                .font(.body)
                        }
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        
                        Spacer()
                        
                        // Delete Button
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Entry")
                            }
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.85)) // Slightly softer red
                            .cornerRadius(AppConstants.CornerRadius.md)
                        }
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        .padding(.top, AppConstants.Spacing.lg)
                    }
                    .padding(.bottom, AppConstants.Spacing.xl)
                }
                .cleanBackground()
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppConstants.Colors.primaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(editedContent.trimmed.isEmpty)
                    .foregroundColor(AppConstants.Colors.accentButton)
                    .fontWeight(.semibold)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isTextFocused = false
                    }
                    .foregroundColor(AppConstants.Colors.accentButton)
                    .fontWeight(.semibold)
                }
            }
            .alert("Delete Entry?", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteEntry()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This cannot be undone. Are you sure?")
            }
        }
    }
    
    // MARK: - State (Confirmation)
    
    @State private var showingDeleteConfirmation = false
    
    // MARK: - Methods
    
    /// Delete the entry
    private func deleteEntry() {
        journalManager.deleteEntry(entry)
        dismiss()
    }
    
    /// Saves the edited entry
    private func saveChanges() {
        let content = editedContent.trimmed
        guard !content.isEmpty else { return }
        
        let time = editedTime.trimmed.isEmpty ? nil : editedTime.trimmed
        
        journalManager.updateEntry(
            entry,
            content: content,
            category: editedCategory,
            time: time
        )
        
        dismiss()
    }
}

