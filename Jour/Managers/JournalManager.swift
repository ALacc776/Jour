//
//  JournalManager.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import Foundation
import SwiftUI

class JournalManager: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var streak: JournalStreak = JournalStreak()
    
    private let userDefaults = UserDefaults.standard
    private let entriesKey = "journal_entries"
    private let streakKey = "journal_streak"
    
    init() {
        loadEntries()
        loadStreak()
        updateStreak()
    }
    
    func saveEntry(_ entry: JournalEntry) {
        entries.append(entry)
        entries.sort { $0.date > $1.date } // Sort by date, newest first
        saveEntries()
        updateStreak()
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
        updateStreak()
    }
    
    func getEntriesForDate(_ date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get all unique dates with entries, sorted by date
        let entryDates = Set(entries.map { calendar.startOfDay(for: $0.date) })
            .sorted()
        
        guard !entryDates.isEmpty else {
            streak.current = 0
            saveStreak()
            return
        }
        
        // Check if we have an entry today or yesterday
        let hasEntryToday = entryDates.contains(today)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let hasEntryYesterday = entryDates.contains(yesterday)
        
        if hasEntryToday {
            // Calculate current streak from today backwards
            var currentStreak = 0
            var checkDate = today
            
            while entryDates.contains(checkDate) {
                currentStreak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            }
            
            streak.current = currentStreak
            streak.longest = max(streak.longest, currentStreak)
            streak.lastEntryDate = formatDate(today)
        } else if hasEntryYesterday {
            // If no entry today but had entry yesterday, streak continues
            streak.current = max(1, streak.current)
        } else {
            // No entry today or yesterday, streak resets
            streak.current = 0
        }
        
        saveStreak()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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
    
    private func saveStreak() {
        if let encoded = try? JSONEncoder().encode(streak) {
            userDefaults.set(encoded, forKey: streakKey)
        }
    }
    
    private func loadStreak() {
        if let data = userDefaults.data(forKey: streakKey),
           let decoded = try? JSONDecoder().decode(JournalStreak.self, from: data) {
            streak = decoded
        }
    }
}
