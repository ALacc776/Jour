//
//  SupportView.swift
//  Jour
//
//  Created by andapple on 6/12/2025.
//

import SwiftUI

/// Displays support and contact information
/// Required for App Store compliance
struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppConstants.Spacing.xxxl) {
                    // Header
                    VStack(spacing: AppConstants.Spacing.md) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppConstants.Colors.accentButton)
                        
                        Text("How can we help?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                    }
                    .padding(.top, AppConstants.Spacing.xl)
                    
                    // FAQ Section
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.lg) {
                        Text("Frequently Asked Questions")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        faqItem(
                            question: "Is my data private?",
                            answer: "Yes! All your journal entries are stored only on your device. Nothing is sent to external servers."
                        )
                        
                        faqItem(
                            question: "How do I back up my entries?",
                            answer: "Your entries are automatically included in your iCloud backup if you have it enabled in iOS Settings. You can also use the 'Export Data' feature to create a manual backup."
                        )
                        
                        faqItem(
                            question: "Can I export my journal?",
                            answer: "Yes! Go to Settings → Export Data to save your entries as a text file. You can also use the 'Copy' features to copy entries to your clipboard."
                        )
                        
                        faqItem(
                            question: "How do I set up daily reminders?",
                            answer: "Go to Settings → Enable Notifications, then choose your preferred reminder time."
                        )
                        
                        faqItem(
                            question: "What if I accidentally delete an entry?",
                            answer: "Unfortunately, deleted entries cannot be recovered. We recommend using the Export feature regularly to back up important entries."
                        )
                    }
                    .padding(.horizontal, AppConstants.Spacing.xl)
                    
                    // Contact Section
                    VStack(spacing: AppConstants.Spacing.lg) {
                        Text("Still need help?")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Text("Get in touch with us")
                            .font(.body)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        
                        // Email Button
                        Button(action: {
                            if let url = URL(string: "mailto:support@daylogapp.com?subject=DayLog%20Support") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("Email Support")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppConstants.Spacing.lg)
                            .primaryButtonStyle()
                        }
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        
                        Text("support@daylogapp.com")
                            .font(.caption)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        
                        Text("We typically respond within 48 hours")
                            .font(.caption)
                            .foregroundColor(AppConstants.Colors.tertiaryText)
                    }
                    
                    Spacer()
                }
            }
            .cleanBackground()
            .navigationTitle("Support")
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
    
    /// Creates a formatted FAQ item
    private func faqItem(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
            Text(question)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.primaryText)
            
            Text(answer)
                .font(.subheadline)
                .foregroundColor(AppConstants.Colors.secondaryText)
        }
        .padding(AppConstants.Spacing.lg)
        .background(AppConstants.Colors.secondaryBackground)
        .cornerRadius(AppConstants.CornerRadius.md)
    }
}

#Preview {
    SupportView()
}

