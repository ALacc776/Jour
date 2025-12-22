//
//  CustomRangeCopyView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// View for selecting a custom date range to copy to clipboard
/// Allows users to export specific date ranges in bullet-list format
struct CustomRangeCopyView: View {
    // MARK: - Properties
    
    /// Reference to the journal manager
    @ObservedObject var journalManager: JournalManager
    
    /// Environment value for dismissing
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    /// Start date for the range
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    
    /// End date for the range
    @State private var endDate = Date()
    
    /// Whether to show success alert
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppConstants.Spacing.xl) {
                // Instructions
                Text("Select date range to copy")
                    .font(.headline)
                    .foregroundColor(AppConstants.Colors.primaryText)
                    .padding(.top, AppConstants.Spacing.xl)
                
                // Date pickers
                VStack(spacing: AppConstants.Spacing.lg) {
                    // Start date
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                        Text("From")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        
                        DatePicker(
                            "Start Date",
                            selection: $startDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                    
                    // End date
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                        Text("To")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        
                        DatePicker(
                            "End Date",
                            selection: $endDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                }
                .padding(.horizontal, AppConstants.Spacing.xl)
                
                // Preview
                VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                    Text("Preview")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                    
                    Text("\(entryCount) \(entryCount == 1 ? "entry" : "entries") found")
                        .font(.body)
                        .foregroundColor(AppConstants.Colors.primaryText)
                }
                .padding(.horizontal, AppConstants.Spacing.xl)
                
                // Copy button
                Button(action: {
                    copyRangeToClipboard()
                }) {
                    HStack(spacing: AppConstants.Spacing.md) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("Copy to Clipboard")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppConstants.Spacing.lg)
                    .primaryButtonStyle()
                }
                .disabled(entryCount == 0)
                .padding(.horizontal, AppConstants.Spacing.xl)
                
                Spacer()
            }
            .cleanBackground()
            .navigationTitle("Copy Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppConstants.Colors.primaryText)
                }
            }
            .alert("Copied!", isPresented: $showingAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Number of entries in selected range
    private var entryCount: Int {
        journalManager.getEntriesInRange(from: startDate, to: endDate).count
    }
    
    // MARK: - Methods
    
    /// Copies entries in selected range to clipboard
    private func copyRangeToClipboard() {
        let entries = journalManager.getEntriesInRange(from: startDate, to: endDate)
        
        guard !entries.isEmpty else { return }
        
        let formatted = journalManager.formatEntriesForClipboard(entries)
        UIPasteboard.general.string = formatted
        
        // Add haptic feedback
        let successFeedback = UINotificationFeedbackGenerator()
        successFeedback.notificationOccurred(.success)
        
        // Show confirmation
        alertMessage = "Copied \(entries.count) \(entries.count == 1 ? "entry" : "entries") to clipboard"
        showingAlert = true
    }
}

#Preview {
    CustomRangeCopyView(journalManager: JournalManager())
}

