//
//  ContentView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI

// Simple journal entry model
struct JournalEntry: Identifiable, Codable {
    let id = UUID()
    let content: String
    let date: Date
    
    init(content: String) {
        self.content = content
        self.date = Date()
    }
}

// Journal manager to handle saving/loading entries
class JournalManager: ObservableObject {
    @Published var entries: [JournalEntry] = []
    private let userDefaults = UserDefaults.standard
    private let entriesKey = "journal_entries"
    
    init() {
        loadEntries()
    }
    
    func saveEntry(_ entry: JournalEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: entriesKey)
        }
    }
    
    private func loadEntries() {
        if let data = userDefaults.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            entries = decoded
        }
    }
}

struct ContentView: View {
    @StateObject private var journalManager = JournalManager()
    @State private var showingNewEntry = false
    
    var body: some View {
        NavigationView {
            VStack {
                if journalManager.entries.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Your Journal is Empty")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Start writing your first entry")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button("Write First Entry") {
                            showingNewEntry = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    // List of entries
                    List(journalManager.entries.reversed()) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.content)
                                .lineLimit(3)
                                .font(.body)
                            
                            Text(entry.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("My Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Entry") {
                        showingNewEntry = true
                    }
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                NewEntryView(journalManager: journalManager)
            }
        }
    }
}

struct NewEntryView: View {
    @ObservedObject var journalManager: JournalManager
    @Environment(\.dismiss) private var dismiss
    @State private var entryText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $entryText)
                    .padding()
                    .font(.body)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding()
                
                Spacer()
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            let entry = JournalEntry(content: entryText)
                            journalManager.saveEntry(entry)
                            dismiss()
                        }
                    }
                    .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
