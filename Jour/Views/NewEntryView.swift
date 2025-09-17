//
//  NewEntryView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

struct NewEntryView: View {
    @ObservedObject var journalManager: JournalManager
    @Environment(\.dismiss) private var dismiss
    @State private var entryText = ""
    @State private var selectedCategory: JournalCategory?
    @State private var selectedTime = ""
    @State private var isFreeForm = false
    @State private var selectedDate: Date?
    
    init(journalManager: JournalManager, selectedDate: Date? = nil) {
        self.journalManager = journalManager
        self.selectedDate = selectedDate
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Entry mode selection
                Picker("Entry Mode", selection: $isFreeForm) {
                    Text("Category").tag(false)
                    Text("Free Form").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if !isFreeForm {
                    // Category selection
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(JournalCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Time input
                HStack {
                    Text("Time (optional):")
                        .font(.headline)
                    
                    TextField("e.g., 14:30", text: $selectedTime)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numbersAndPunctuation)
                }
                .padding(.horizontal)
                
                // Content input
                VStack(alignment: .leading, spacing: 8) {
                    Text("What happened?")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextEditor(text: $entryText)
                        .padding()
                        .font(.body)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Log Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveEntry() {
        let content = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        let category = isFreeForm ? nil : selectedCategory?.rawValue
        let time = selectedTime.isEmpty ? nil : selectedTime
        let date = selectedDate ?? Date()
        
        let entry = JournalEntry(content: content, category: category, date: date, time: time)
        journalManager.saveEntry(entry)
        dismiss()
    }
}
