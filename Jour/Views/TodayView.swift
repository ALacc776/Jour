//
//  TodayView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

/// Main "Today" view with instant input and today's entries
/// Provides the fastest way to log daily activities
struct TodayView: View {
    // MARK: - Properties
    
    /// Reference to the journal manager
    @ObservedObject var journalManager: JournalManager
    
    /// Reference to the theme manager
    @EnvironmentObject var themeManager: ThemeManager
    
    // MARK: - State
    
    /// Controls whether to show settings
    @State private var showingSettings = false
    
    /// Text being typed in the input field
    @State private var inputText = ""
    
    /// Controls whether to show edit sheet
    @State private var editingEntry: JournalEntry?
    
    /// Controls whether to show search
    @State private var showingSearch = false
    
    /// Controls whether to show camera
    @State private var showingCamera = false
    
    /// Controls whether to show photo library
    @State private var showingPhotoLibrary = false
    
    /// Controls whether to show stats (streak + heatmap)
    @State private var showingStats = false
    
    /// Trigger for confetti animation (increments to trigger)
    @State private var confettiCounter = 0
    
    /// Focus state for the text field
    @FocusState private var isInputFocused: Bool
    
    /// Entry from a previous year to display as flashback
    @State private var flashbackEntry: JournalEntry?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header
                HStack(spacing: 12) {
                    // Combined Streak & Heatmap Pill
                    HStack(spacing: 16) {
                        // 1. Streak Count
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppConstants.Colors.accentButton)
                            Text("\(journalManager.streak.current)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppConstants.Colors.primaryText)
                        }
                        
                        // 2. Tiny GitHub-style Heatmap
                        HStack(spacing: 4) {
                            ForEach(0..<7) { dayOffset in
                                let date = Calendar.current.date(byAdding: .day, value: dayOffset - 6, to: Date()) ?? Date()
                                let isToday = dayOffset == 6
                                let hasEntry = journalManager.hasEntry(on: date)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(
                                        hasEntry ? AppConstants.Colors.duoGreen : // Active
                                        (isToday ? AppConstants.Colors.duoGreen.opacity(0.3) : Color.gray.opacity(0.2)) // Today/Empty
                                    )
                                    .frame(width: 12, height: 12) // Tiny size
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(AppConstants.Colors.cardBackground)
                            .shadow(color: AppConstants.Colors.cardShadow, radius: 4, x: 0, y: 2)
                    )
                    .onTapGesture {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        showingStats = true
                    }
                    
                    Spacer()
                    
                    // Search button
                    Button(action: {
                        showingSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.headline)
                            .foregroundColor(AppConstants.Colors.primaryText)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Search entries")
                    .accessibilityHint("Opens search to find journal entries")
                    
                    // Settings button
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.headline)
                            .foregroundColor(AppConstants.Colors.primaryText)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Menu")
                    .accessibilityHint("Opens settings and options menu")
                }
                .padding(.horizontal, AppConstants.Spacing.xl)
                .padding(.top, AppConstants.Spacing.lg)
                .padding(.bottom, AppConstants.Spacing.md)
                
                // MARK: - Main Content
                List {
                    // Date header & Input Section
                    Section {
                        VStack(spacing: AppConstants.Spacing.xl) {
                            // Date header
                            VStack(spacing: AppConstants.Spacing.xs) {
                                Text("Today")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppConstants.Colors.primaryText)
                                
                                Text(Date().displayFormat)
                                    .font(.subheadline)
                                    .foregroundColor(AppConstants.Colors.secondaryText)
                            }
                            .padding(.top, AppConstants.Spacing.md)
                            
                            // MARK: - Input Section
                            VStack(spacing: AppConstants.Spacing.md) {
                                // Text input field - always visible
                                HStack(alignment: .top, spacing: AppConstants.Spacing.md) {
                                    let placeholder = flashbackEntry != nil 
                                        ? "On this day: \(flashbackEntry!.content)" 
                                        : "What did you do today?"
                                        
                                    TextField(placeholder, text: $inputText, axis: .vertical)
                                        .lineLimit(1...5)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .font(.body)
                                        .focused($isInputFocused)
                                        .onSubmit {
                                            if !inputText.trimmed.isEmpty {
                                                saveQuickEntry()
                                            }
                                        }
                                    
                                    // Quick save button (only shows when there's text)
                                    if !inputText.trimmed.isEmpty {
                                        Button(action: saveQuickEntry) {
                                            Image(systemName: "arrow.up.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(AppConstants.Colors.accentButton)
                                        }
                                        .accessibilityLabel("Save entry")
                                        .accessibilityHint("Saves your journal entry")
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding(AppConstants.Spacing.lg)
                                .background(
                                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                                        .fill(AppConstants.Colors.secondaryBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.lg)
                                                .stroke(
                                                    isInputFocused ? AppConstants.Colors.accentButton : AppConstants.Colors.cardBorder,
                                                    lineWidth: isInputFocused ? 2 : 1
                                                )
                                        )
                                )
                                .animation(.easeInOut(duration: 0.2), value: isInputFocused)
                                .animation(.spring(response: 0.3), value: inputText.isEmpty)
                                
                                // Quick-add buttons - Camera and Gallery only
                                HStack(spacing: AppConstants.Spacing.xl) {
                                    QuickAddButton(
                                        emoji: "📸", 
                                        label: "Camera",
                                        color: AppConstants.Colors.duoBlue,
                                        shadowColor: AppConstants.Colors.duoBlueDark
                                    ) {
                                        showCamera()
                                    }
                                    
                                    QuickAddButton(
                                        emoji: "🖼️", 
                                        label: "Gallery",
                                        color: AppConstants.Colors.duoGreen,
                                        shadowColor: AppConstants.Colors.duoGreenDark
                                    ) {
                                        showGallery()
                                    }
                                }
                                .padding(.horizontal, AppConstants.Spacing.xl)
                                .padding(.bottom, AppConstants.Spacing.md)
                            }
                            .padding(.horizontal, AppConstants.Spacing.xl)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    
                    // MARK: - Today's Entries
                    if !todayEntries.isEmpty {
                        Section {
                            VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
                                HStack {
                                    Text("Earlier Today")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppConstants.Colors.primaryText)
                                    
                                    Spacer()
                                    
                                    Text("\(todayEntries.count)")
                                        .font(.subheadline)
                                        .foregroundColor(AppConstants.Colors.secondaryText)
                                }
                                .padding(.horizontal, AppConstants.Spacing.xl)
                            }
                            .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 8, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            
                            ForEach(todayEntries) { entry in
                                EntryRowView(entry: entry)
                                    .padding(.horizontal, AppConstants.Spacing.xl)
                                    .padding(.vertical, AppConstants.Spacing.xs)
                                    .onTapGesture {
                                        editingEntry = entry
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            entryToDelete = entry
                                            showingDeleteConfirmation = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button {
                                            editingEntry = entry
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(AppConstants.Colors.accentButton)
                                    }
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                            }
                        }
                    } else {
                        // Empty state for today
                        Section {
                            VStack(spacing: AppConstants.Spacing.lg) {
                                Image(systemName: "sun.max")
                                    .font(.system(size: 50))
                                    .foregroundColor(AppConstants.Colors.tertiaryText)
                                
                                Text("Nothing logged yet today")
                                    .font(.subheadline)
                                    .foregroundColor(AppConstants.Colors.secondaryText)
                                
                                Text("Type above or tap a quick-add button")
                                    .font(.caption)
                                    .foregroundColor(AppConstants.Colors.tertiaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppConstants.Spacing.xxxxl)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(AppConstants.Colors.primaryBackground)
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $editingEntry) { entry in
                EditEntryView(journalManager: journalManager, entry: entry)
                    .environmentObject(themeManager)
            }
            .sheet(isPresented: $showingSearch) {
                SearchView(journalManager: journalManager)
                    .environmentObject(themeManager)
            }
            .sheet(isPresented: $showingCamera) {
                if isCameraAvailable() {
                    ImagePickerView(
                        sourceType: .camera,
                        onImagePicked: { image in
                            handlePhotoSelected(image, saveToLibrary: true)
                        },
                        onDismiss: {
                            showingCamera = false
                        }
                    )
                } else {
                    Text("Camera not available")
                }
            }
            .sheet(isPresented: $showingPhotoLibrary) {
                ImagePickerView(
                    sourceType: .photoLibrary,
                    onImagePicked: { image in
                        handlePhotoSelected(image, saveToLibrary: false)
                    },
                    onDismiss: {
                        showingPhotoLibrary = false
                    }
                )
            }
            .sheet(isPresented: $showingSettings) {
                MenuView(journalManager: journalManager)
                    .environmentObject(themeManager)
            }
            .sheet(isPresented: $showingStats) {
                StatsView(journalManager: journalManager)
                    .environmentObject(themeManager)
            }
        }
        .confetti(counter: $confettiCounter)
        .confirmationDialog(
            "Delete this entry?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let entry = entryToDelete {
                    withAnimation(.spring()) {
                        journalManager.deleteEntry(entry)
                    }
                }
                entryToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                entryToDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .onAppear {
            checkForFlashback()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Returns all entries for today, sorted newest first
    private var todayEntries: [JournalEntry] {
        journalManager.getEntriesForDate(Date())
            .sorted { $0.date > $1.date }
    }
    
    // MARK: - Methods
    
    /// Saves the text from the input field as a new entry
    private func saveQuickEntry() {
        let content = inputText.trimmed
        guard !content.isEmpty else { return }
        
        let entry = JournalEntry(
            content: content,
            category: nil,
            time: nil,
            photoFilename: nil,
            location: nil
        )
        journalManager.saveEntry(entry)
        
        // Clear input and animate
        withAnimation(.spring()) {
            inputText = ""
            confettiCounter += 1 // Trigger confetti
        }
        
        // Optional: unfocus keyboard
        isInputFocused = false
    }
    
    /// Checks for entries from this day in previous years
    private func checkForFlashback() {
        // Simple check for any entry from exactly 1 year ago (can be expanded)
        let calendar = Calendar.current
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: Date()) else { return }
        
        let entries = journalManager.getEntriesForDate(oneYearAgo)
        if let first = entries.first {
            flashbackEntry = first
        }
    }
    
    /// Shows camera for taking a photo
    private func showCamera() {
        showingCamera = true
    }
    
    /// Shows photo library for selecting a photo
    private func showGallery() {
        showingPhotoLibrary = true
    }
    
    /// Handles a photo being selected from camera or library
    private func handlePhotoSelected(_ image: UIImage, saveToLibrary: Bool) {
        // Save to Camera Roll if requested (for camera captures)
        if saveToLibrary {
            PhotoManager.shared.saveToPhotoLibrary(image) { success in
                if !success {
                    print("Failed to save photo to library")
                }
            }
        }
        
        // Save photo to app storage asynchronously
        PhotoManager.shared.savePhoto(image) { filename in
            guard let filename = filename else {
                print("Failed to save photo by PhotoManager")
                return
            }
            
            // Create entry with photo
            // FIX: Don't default to "Photo" text, allow empty text so user can just edit directly
            // If they want to add text, they can just type. If not, the photo speaks for itself.
            let content = self.inputText.trimmed
            let entry = JournalEntry(
                content: content,
                category: nil,
                time: nil,
                photoFilename: filename,
                location: nil
            )
            
            withAnimation(.spring()) {
                self.journalManager.saveEntry(entry)
                self.inputText = ""
                self.confettiCounter += 1 // Trigger confetti
            }
        }
    }
    
    /// Returns the first letter of the day of the week
    private func getDayLetter(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE" // Single letter day (e.g. "M", "T")
        return formatter.string(from: date)
    }
    
    // MARK: - Deletion Logic
    
    @State private var entryToDelete: JournalEntry?
    @State private var showingDeleteConfirmation = false
}

#Preview {
    TodayView(journalManager: JournalManager())
        .environmentObject(ThemeManager())
}

