//
//  PrivacyPolicyView.swift
//  Jour
//
//  Created by andapple on 6/12/2025.
//

import SwiftUI

/// Displays the app's comprehensive privacy policy
/// Required for App Store compliance
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppConstants.Spacing.xl) {
                    // Last Updated
                    Text("Last Updated: December 6, 2025")
                        .font(.caption)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                        .padding(.bottom, AppConstants.Spacing.md)
                    
                    // Introduction
                    policySection(
                        title: "Your Privacy Matters",
                        content: "DayLog is designed with your privacy as a top priority. Your personal journal entries are private and stored securely on your device. We believe your thoughts and memories belong to you."
                    )
                    
                    // Data Collection
                    policySection(
                        title: "What We Collect",
                        content: """
                        DayLog does NOT collect, transmit, or share any of your personal data. Specifically:
                        
                        • Journal entries are stored locally on your device only
                        • Photos you attach are saved to your device
                        • No data is sent to external servers
                        • No analytics or tracking
                        • No user accounts required
                        • No personal information collected
                        """
                    )
                    
                    // Data Storage
                    policySection(
                        title: "How Your Data is Stored",
                        content: """
                        All data is stored locally on your device using:
                        
                        • UserDefaults for journal entries and preferences
                        • Local file storage for photos
                        • Your data never leaves your device
                        • Backup to iCloud is managed by your iOS settings
                        
                        If you enable iCloud Backup on your device, your journal data may be included in your iCloud backup. This is controlled by iOS, not by DayLog.
                        """
                    )
                    
                    // Permissions
                    policySection(
                        title: "Permissions We Request",
                        content: """
                        DayLog may request the following permissions:
                        
                        • Camera: To take photos for journal entries
                        • Photo Library: To select existing photos or save photos you take
                        • Notifications: To remind you to journal daily (optional)
                        
                        All permissions are optional. You can use the core journaling features without granting any permissions.
                        """
                    )
                    
                    // Third Party Services
                    policySection(
                        title: "Third-Party Services",
                        content: "DayLog does not use any third-party services, analytics, or advertising networks. Your data is never shared with third parties."
                    )
                    
                    // Data Security
                    policySection(
                        title: "Data Security",
                        content: """
                        Your journal entries are protected by:
                        
                        • Device-level encryption provided by iOS
                        • No network transmission of data
                        • Local storage only
                        
                        Your data is as secure as your device. We recommend:
                        • Using a strong device passcode
                        • Enabling Face ID or Touch ID
                        • Keeping your device updated
                        """
                    )
                    
                    // Your Rights
                    policySection(
                        title: "Your Rights",
                        content: """
                        You have complete control over your data:
                        
                        • Export: Copy your entries at any time using the export feature
                        • Delete: Remove individual entries or all data from Settings
                        • No Account: No registration means no forgotten passwords
                        • Full Ownership: Your entries belong to you
                        """
                    )
                    
                    // Data Deletion
                    policySection(
                        title: "Deleting Your Data",
                        content: """
                        To delete all your data:
                        
                        1. Go to Settings in the app
                        2. Tap "Delete All Data"
                        3. Confirm the deletion
                        
                        Or simply delete the app from your device. All data will be removed. There's no server-side data to worry about.
                        """
                    )
                    
                    // Children's Privacy
                    policySection(
                        title: "Children's Privacy",
                        content: "DayLog does not knowingly collect any information from users of any age. The app is suitable for ages 4+ as it contains no inappropriate content and collects no personal data."
                    )
                    
                    // Changes to Policy
                    policySection(
                        title: "Changes to This Policy",
                        content: "If we make changes to this privacy policy, we will update this page with the new policy. The \"Last Updated\" date will reflect when changes were made."
                    )
                    
                    // Contact
                    policySection(
                        title: "Contact Us",
                        content: """
                        If you have questions about this privacy policy or DayLog, you can contact us:
                        
                        Email: support.and@proton.me
                        
                        We typically respond within 48 hours.
                        """
                    )
                    
                    // Summary
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
                        Text("In Summary")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Text("DayLog is a privacy-first journaling app. Everything stays on your device. We don't collect, transmit, or sell your data. Your journal is yours alone.")
                            .font(.body)
                            .foregroundColor(AppConstants.Colors.primaryText)
                            .padding(AppConstants.Spacing.lg)
                            .background(AppConstants.Colors.secondaryBackground)
                            .cornerRadius(AppConstants.CornerRadius.md)
                    }
                }
                .padding(AppConstants.Spacing.xl)
            }
            .cleanBackground()
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.large)
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
    
    // MARK: - Helper Views
    
    /// Creates a formatted policy section
    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.primaryText)
            
            Text(content)
                .font(.body)
                .foregroundColor(AppConstants.Colors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    PrivacyPolicyView()
}

