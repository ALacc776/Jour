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
    
    /// Focus state for the text field
    @FocusState private var isInputFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Header with Streak
                HStack {
                    // Streak badge
                    HStack(spacing: AppConstants.Spacing.xs) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(AppConstants.Colors.accentButton)
                            .font(.headline)
                        Text("\(journalManager.streak.current)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        Text("day\(journalManager.streak.current == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    .padding(.horizontal, AppConstants.Spacing.md)
                    .padding(.vertical, AppConstants.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(AppConstants.Colors.accentButton.opacity(0.1))
                    )
                    
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
                    
                    // Settings button
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.headline)
                            .foregroundColor(AppConstants.Colors.primaryText)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, AppConstants.Spacing.xl)
                .padding(.top, AppConstants.Spacing.lg)
                .padding(.bottom, AppConstants.Spacing.md)
                
                // MARK: - Main Content
                ScrollView {
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
                                TextField("What did you do today?", text: $inputText, axis: .vertical)
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
                            HStack(spacing: AppConstants.Spacing.md) {
                                QuickAddButton(emoji: "📸", label: "Camera") {
                                    showCamera()
                                }
                                
                                QuickAddButton(emoji: "🖼️", label: "Gallery") {
                                    showGallery()
                                }
                            }
                            .padding(.horizontal, AppConstants.Spacing.xl)
                        }
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        
                        // MARK: - Today's Entries
                        if !todayEntries.isEmpty {
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
                                
                                VStack(spacing: AppConstants.Spacing.sm) {
                                    ForEach(todayEntries) { entry in
                                        EntryRowView(entry: entry)
                                            .onTapGesture {
                                                editingEntry = entry
                                            }
                                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                Button("Delete", role: .destructive) {
                                                    withAnimation(.spring()) {
                                                        journalManager.deleteEntry(entry)
                                                    }
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
                                    }
                                }
                                .padding(.horizontal, AppConstants.Spacing.xl)
                            }
                        } else {
                            // Empty state for today
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
                            .padding(.vertical, AppConstants.Spacing.xxxxl)
                        }
                    }
                    .padding(.bottom, AppConstants.Spacing.xl)
                }
                .cleanBackground()
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $editingEntry) { entry in
                EditEntryView(journalManager: journalManager, entry: entry)
            }
            .sheet(isPresented: $showingSearch) {
                SearchView(journalManager: journalManager)
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
            }
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
        }
        
        // Optional: unfocus keyboard
        isInputFocused = false
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
        
        // Save photo to app storage
        guard let filename = PhotoManager.shared.savePhoto(image) else {
            print("Failed to save photo")
            return
        }
        
        // Create entry with photo
        let content = inputText.trimmed.isEmpty ? "📷 Photo" : inputText.trimmed
        let entry = JournalEntry(
            content: content,
            category: nil,
            time: nil,
            photoFilename: filename,
            location: nil
        )
        
        withAnimation(.spring()) {
            journalManager.saveEntry(entry)
            inputText = ""
        }
    }
}

#Preview {
    TodayView(journalManager: JournalManager())
}

