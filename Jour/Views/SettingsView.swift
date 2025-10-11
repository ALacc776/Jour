//
//  SettingsView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Settings view for managing app preferences, privacy, and data
/// Provides access to privacy settings, data export, and app information
struct SettingsView: View {
    // MARK: - Properties
    
    /// Reference to the journal manager for data operations
    @ObservedObject var journalManager: JournalManager
    
    /// Reference to the privacy manager for privacy controls
    @ObservedObject var privacyManager: PrivacyManager
    
    /// Environment value for dismissing the modal
    @Environment(\.dismiss) private var dismiss
    
    /// Controls the presentation of the privacy policy sheet
    @State private var showingPrivacyPolicy = false
    
    /// Controls the presentation of the about sheet
    @State private var showingAbout = false
    
    /// Controls the presentation of the data export sheet
    @State private var showingDataExport = false
    
    /// Controls the presentation of the data deletion confirmation
    @State private var showingDeleteConfirmation = false
    
    /// Shows export success/failure alerts
    @State private var showingExportAlert = false
    @State private var exportAlertMessage = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Privacy Section
                Section("Privacy & Security") {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(AppConstants.Colors.accentButton)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Data Encryption")
                                .font(.body)
                                .fontWeight(.medium)
                            Text("Your entries are encrypted locally")
                                .font(.caption)
                                .foregroundColor(AppConstants.Colors.secondaryText)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $privacyManager.isEncryptionEnabled)
                            .onChange(of: privacyManager.isEncryptionEnabled) { _ in
                                privacyManager.savePrivacyPreferences()
                            }
                    }
                    
                    Button(action: {
                        showingPrivacyPolicy = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(AppConstants.Colors.accentButton)
                                .frame(width: 24)
                            
                            Text("Privacy Policy")
                                .foregroundColor(AppConstants.Colors.primaryText)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppConstants.Colors.tertiaryText)
                                .font(.caption)
                        }
                    }
                }
                
                // MARK: - Data Management Section
                Section("Data Management") {
                    Button(action: {
                        showingDataExport = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(AppConstants.Colors.accentButton)
                                .frame(width: 24)
                            
                            Text("Export Data")
                                .foregroundColor(AppConstants.Colors.primaryText)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppConstants.Colors.tertiaryText)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(AppConstants.Colors.errorColor)
                                .frame(width: 24)
                            
                            Text("Delete All Data")
                                .foregroundColor(AppConstants.Colors.errorColor)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppConstants.Colors.tertiaryText)
                                .font(.caption)
                        }
                    }
                }
                
                // MARK: - App Information Section
                Section("App Information") {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(AppConstants.Colors.accentButton)
                                .frame(width: 24)
                            
                            Text("About QuickJournal")
                                .foregroundColor(AppConstants.Colors.primaryText)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppConstants.Colors.tertiaryText)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(AppConstants.Colors.accentButton)
                            .frame(width: 24)
                        
                        Text("Version")
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                }
                
                // MARK: - Statistics Section
                Section("Statistics") {
                    HStack {
                        Image(systemName: "book")
                            .foregroundColor(AppConstants.Colors.accentButton)
                            .frame(width: 24)
                        
                        Text("Total Entries")
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Spacer()
                        
                        Text("\(journalManager.entries.count)")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    
                    HStack {
                        Image(systemName: "flame")
                            .foregroundColor(AppConstants.Colors.accentButton)
                            .frame(width: 24)
                        
                        Text("Current Streak")
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Spacer()
                        
                        Text("\(journalManager.streak.current) days")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    
                    HStack {
                        Image(systemName: "trophy")
                            .foregroundColor(AppConstants.Colors.accentButton)
                            .frame(width: 24)
                        
                        Text("Best Streak")
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Spacer()
                        
                        Text("\(journalManager.streak.longest) days")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppConstants.Colors.accentButton)
                }
            }
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView(journalManager: journalManager)
        }
        .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("This will permanently delete all your journal entries and cannot be undone. Are you sure?")
        }
        .alert("Export Result", isPresented: $showingExportAlert) {
            Button("OK") { }
        } message: {
            Text(exportAlertMessage)
        }
    }
    
    // MARK: - Private Methods
    
    /// Deletes all journal data
    private func deleteAllData() {
        journalManager.entries.removeAll()
        // Trigger save by adding and removing an entry
        let tempEntry = JournalEntry(content: "temp")
        journalManager.saveEntry(tempEntry)
        journalManager.deleteEntry(tempEntry)
        
        // Reset privacy preferences
        privacyManager.resetPrivacyPreferences()
        
        // Show confirmation
        exportAlertMessage = "All data has been deleted successfully."
        showingExportAlert = true
    }
}

// MARK: - Privacy Policy View

/// View for displaying the privacy policy
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AppConstants.Spacing.lg) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppConstants.Colors.primaryText)
                    
                    Text("Last updated: January 2025")
                        .font(.caption)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                    
                    Group {
                        Text("Quick Summary")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Text("QuickJournal stores your journal entries locally on your device. We do not collect, store, or transmit your personal data to our servers. Your privacy is our priority.")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                            .padding()
                            .background(AppConstants.Colors.secondaryBackground)
                            .cornerRadius(AppConstants.CornerRadius.md)
                    }
                    
                    Group {
                        Text("Information We Collect")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                            Text("• Journal Entries: Stored locally on your device only")
                            Text("• Usage Data: Basic app statistics stored locally")
                            Text("• No Personal Information: We do not collect names or email addresses")
                        }
                        .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    
                    Group {
                        Text("Data Security")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                            Text("• Local Storage: All data stays on your device")
                            Text("• Encryption: Journal entries are encrypted using iOS Keychain")
                            Text("• No Cloud Sync: We do not sync data to external servers")
                            Text("• No Third-Party Access: Your data is not shared")
                        }
                        .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    
                    Group {
                        Text("Your Rights")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                            Text("• Access: View all your entries within the app")
                            Text("• Export: Export your entries as text or JSON files")
                            Text("• Delete: Delete individual entries or all data")
                            Text("• Backup: Create local backups of your data")
                        }
                        .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    
                    Group {
                        Text("Contact Us")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Text("If you have questions about this privacy policy, please contact us at support@quickjournal.app")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                }
                .padding(AppConstants.Spacing.xl)
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppConstants.Colors.accentButton)
                }
            }
        }
    }
}

// MARK: - About View

/// View for displaying app information
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppConstants.Spacing.xl) {
                    // App Icon Placeholder
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                        .fill(AppConstants.Colors.accentButton)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "book.closed")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: AppConstants.Spacing.sm) {
                        Text("QuickJournal")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Text("Reflect on your day, build mindful habits")
                            .font(.subheadline)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: AppConstants.Spacing.md) {
                        Text("Version 1.0.0")
                            .font(.headline)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Text("Built with SwiftUI")
                            .font(.caption)
                            .foregroundColor(AppConstants.Colors.tertiaryText)
                    }
                    
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
                        Text("About QuickJournal")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Text("QuickJournal is a simple, privacy-focused journaling app designed to help you reflect on your day and build mindful habits. Your thoughts and memories stay with you and you alone.")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        
                        Text("Features:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                            Text("• Local data storage with encryption")
                            Text("• Streak tracking and motivation")
                            Text("• Multiple entry categories")
                            Text("• Calendar and timeline views")
                            Text("• Data export and backup")
                            Text("• Privacy-first design")
                        }
                        .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                        Text("Privacy First")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Text("QuickJournal is built with privacy by design. Your journal entries are stored locally on your device and encrypted using iOS Keychain services. We do not collect, store, or transmit your personal data.")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    
                    Spacer()
                }
                .padding(AppConstants.Spacing.xl)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppConstants.Colors.accentButton)
                }
            }
        }
    }
}

#Preview {
    SettingsView(
        journalManager: JournalManager(),
        privacyManager: PrivacyManager()
    )
}
