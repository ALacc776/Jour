//
//  JournalManager.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import Foundation
import SwiftUI

/// Manages all journal entries and streak data for the app
/// This class handles data persistence, streak calculations, and provides methods for CRUD operations
class JournalManager: ObservableObject {
    // MARK: - Published Properties
    
    /// Array of all journal entries, sorted by date (newest first)
    @Published var entries: [JournalEntry] = []
    
    /// Current streak information including current and longest streaks
    @Published var streak: JournalStreak = JournalStreak()
    
    // MARK: - Private Properties
    
    /// UserDefaults instance for data persistence
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Constants
    
    /// Key for storing journal entries in UserDefaults
    private let entriesKey = AppConstants.UserDefaultsKeys.journalEntries
    
    /// Key for storing streak data in UserDefaults
    private let streakKey = AppConstants.UserDefaultsKeys.journalStreak
    
    // MARK: - Initialization
    
    /// Initializes the JournalManager and loads existing data
    init() {
        loadEntries()
        loadStreak()
        updateStreak()
    }
    
    // MARK: - Public Methods
    
    /// Saves a new journal entry and updates the streak
    /// - Parameter entry: The journal entry to save
    func saveEntry(_ entry: JournalEntry) {
        entries.append(entry)
        entries.sort { $0.date > $1.date } // Sort by date, newest first
        saveEntries()
        updateStreak()
        
        // Add haptic feedback for successful save
        let successFeedback = UINotificationFeedbackGenerator()
        successFeedback.notificationOccurred(.success)
    }
    
    /// Deletes a journal entry and updates the streak
    /// - Parameter entry: The journal entry to delete
    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
        updateStreak()
        
        // Add haptic feedback for deletion
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    /// Returns all journal entries for a specific date
    /// - Parameter date: The date to filter entries by
    /// - Returns: Array of journal entries for the specified date
    func getEntriesForDate(_ date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    // MARK: - Private Methods
    
    /// Updates the current streak based on journal entries
    /// Calculates consecutive days of journaling and updates both current and longest streaks
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get all unique dates with entries, sorted by date (optimized)
        let entryDates = Set(entries.map { calendar.startOfDay(for: $0.date) })
        
        // If no entries exist, reset streak
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
            // Calculate current streak from today backwards (optimized)
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
    
    /// Formats a date to a string for storage
    /// - Parameter date: The date to format
    /// - Returns: Formatted date string in "yyyy-MM-dd" format
    private func formatDate(_ date: Date) -> String {
        date.storageFormat
    }
    
    /// Saves journal entries to UserDefaults
    /// Encodes the entries array to JSON and stores it persistently
    private func saveEntries() {
        do {
            let encoded = try JSONEncoder().encode(entries)
            userDefaults.set(encoded, forKey: entriesKey)
        } catch {
            print("Failed to save journal entries: \(error.localizedDescription)")
        }
    }
    
    /// Loads journal entries from UserDefaults
    /// Decodes the stored JSON data back into the entries array
    private func loadEntries() {
        guard let data = userDefaults.data(forKey: entriesKey) else { return }
        
        do {
            let decoded = try JSONDecoder().decode([JournalEntry].self, from: data)
            entries = decoded
        } catch {
            print("Failed to load journal entries: \(error.localizedDescription)")
        }
    }
    
    /// Saves streak data to UserDefaults
    /// Encodes the streak object to JSON and stores it persistently
    private func saveStreak() {
        do {
            let encoded = try JSONEncoder().encode(streak)
            userDefaults.set(encoded, forKey: streakKey)
        } catch {
            print("Failed to save streak data: \(error.localizedDescription)")
        }
    }
    
    /// Loads streak data from UserDefaults
    /// Decodes the stored JSON data back into the streak object
    private func loadStreak() {
        guard let data = userDefaults.data(forKey: streakKey) else { return }
        
        do {
            let decoded = try JSONDecoder().decode(JournalStreak.self, from: data)
            streak = decoded
        } catch {
            print("Failed to load streak data: \(error.localizedDescription)")
        }
    }
}
