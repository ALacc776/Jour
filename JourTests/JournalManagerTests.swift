//
//  JournalManagerTests.swift
//  JourTests
//
//  Created by andapple on 16/9/2025.
//

import XCTest
@testable import Jour

/// Unit tests for JournalManager functionality
/// Tests data persistence, streak calculations, and CRUD operations
final class JournalManagerTests: XCTestCase {
    
    var journalManager: JournalManager!
    
    override func setUpWithError() throws {
        // Create a fresh JournalManager for each test
        journalManager = JournalManager()
        
        // Clear any existing data
        journalManager.entries.removeAll()
        journalManager.streak = JournalStreak()
    }
    
    override func tearDownWithError() throws {
        journalManager = nil
    }
    
    // MARK: - Entry Management Tests
    
    func testSaveEntry() throws {
        // Given
        let entry = JournalEntry(content: "Test entry", category: "Test", time: "10:00")
        
        // When
        journalManager.saveEntry(entry)
        
        // Then
        XCTAssertEqual(journalManager.entries.count, 1)
        XCTAssertEqual(journalManager.entries.first?.content, "Test entry")
        XCTAssertEqual(journalManager.entries.first?.category, "Test")
        XCTAssertEqual(journalManager.entries.first?.time, "10:00")
    }
    
    func testDeleteEntry() throws {
        // Given
        let entry1 = JournalEntry(content: "Entry 1")
        let entry2 = JournalEntry(content: "Entry 2")
        journalManager.saveEntry(entry1)
        journalManager.saveEntry(entry2)
        
        // When
        journalManager.deleteEntry(entry1)
        
        // Then
        XCTAssertEqual(journalManager.entries.count, 1)
        XCTAssertEqual(journalManager.entries.first?.content, "Entry 2")
    }
    
    func testGetEntriesForDate() throws {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        let entry1 = JournalEntry(content: "Today's entry", category: nil, date: today)
        let entry2 = JournalEntry(content: "Yesterday's entry", category: nil, date: yesterday)
        
        journalManager.saveEntry(entry1)
        journalManager.saveEntry(entry2)
        
        // When
        let todayEntries = journalManager.getEntriesForDate(today)
        let yesterdayEntries = journalManager.getEntriesForDate(yesterday)
        
        // Then
        XCTAssertEqual(todayEntries.count, 1)
        XCTAssertEqual(todayEntries.first?.content, "Today's entry")
        
        XCTAssertEqual(yesterdayEntries.count, 1)
        XCTAssertEqual(yesterdayEntries.first?.content, "Yesterday's entry")
    }
    
    // MARK: - Streak Calculation Tests
    
    func testStreakCalculationWithConsecutiveDays() throws {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let dayBeforeYesterday = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        let entry1 = JournalEntry(content: "Day 1", category: nil, date: dayBeforeYesterday)
        let entry2 = JournalEntry(content: "Day 2", category: nil, date: yesterday)
        let entry3 = JournalEntry(content: "Day 3", category: nil, date: today)
        
        // When
        journalManager.saveEntry(entry1)
        journalManager.saveEntry(entry2)
        journalManager.saveEntry(entry3)
        
        // Then
        XCTAssertEqual(journalManager.streak.current, 3)
        XCTAssertEqual(journalManager.streak.longest, 3)
    }
    
    func testStreakCalculationWithGap() throws {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        
        let entry1 = JournalEntry(content: "Old entry", category: nil, date: threeDaysAgo)
        let entry2 = JournalEntry(content: "Recent entry", category: nil, date: yesterday)
        
        // When
        journalManager.saveEntry(entry1)
        journalManager.saveEntry(entry2)
        
        // Then
        XCTAssertEqual(journalManager.streak.current, 1) // Only yesterday counts
        XCTAssertEqual(journalManager.streak.longest, 1)
    }
    
    func testStreakCalculationNoEntries() throws {
        // Given - no entries
        
        // When - streak calculation happens automatically
        
        // Then
        XCTAssertEqual(journalManager.streak.current, 0)
        XCTAssertEqual(journalManager.streak.longest, 0)
    }
    
    func testStreakCalculationLongestStreak() throws {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        let fourDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: today)!
        
        // Create a 4-day streak
        let entry1 = JournalEntry(content: "Day 1", category: nil, date: fourDaysAgo)
        let entry2 = JournalEntry(content: "Day 2", category: nil, date: threeDaysAgo)
        let entry3 = JournalEntry(content: "Day 3", category: nil, date: twoDaysAgo)
        let entry4 = JournalEntry(content: "Day 4", category: nil, date: yesterday)
        
        journalManager.saveEntry(entry1)
        journalManager.saveEntry(entry2)
        journalManager.saveEntry(entry3)
        journalManager.saveEntry(entry4)
        
        // Add a gap and new shorter streak
        let recentEntry = JournalEntry(content: "Recent", category: nil, date: today)
        journalManager.saveEntry(recentEntry)
        
        // Then
        XCTAssertEqual(journalManager.streak.current, 1) // Only today
        XCTAssertEqual(journalManager.streak.longest, 4) // Previous 4-day streak
    }
    
    // MARK: - Data Persistence Tests
    
    func testDataPersistence() throws {
        // Given
        let entry = JournalEntry(content: "Persistent entry", category: "Test")
        journalManager.saveEntry(entry)
        
        // When - Create a new manager (simulates app restart)
        let newManager = JournalManager()
        
        // Then
        XCTAssertEqual(newManager.entries.count, 1)
        XCTAssertEqual(newManager.entries.first?.content, "Persistent entry")
        XCTAssertEqual(newManager.entries.first?.category, "Test")
    }
    
    // MARK: - Edge Cases
    
    func testEmptyContentEntry() throws {
        // Given
        let entry = JournalEntry(content: "", category: "Test")
        
        // When
        journalManager.saveEntry(entry)
        
        // Then
        XCTAssertEqual(journalManager.entries.count, 1)
        XCTAssertEqual(journalManager.entries.first?.content, "")
    }
    
    func testEntryWithSpecialCharacters() throws {
        // Given
        let content = "Special chars: 🎉 émojis & symbols! @#$%^&*()"
        let entry = JournalEntry(content: content, category: "Special")
        
        // When
        journalManager.saveEntry(entry)
        
        // Then
        XCTAssertEqual(journalManager.entries.count, 1)
        XCTAssertEqual(journalManager.entries.first?.content, content)
    }
    
    func testMultipleEntriesSameDate() throws {
        // Given
        let date = Date()
        let entry1 = JournalEntry(content: "First entry", category: nil, date: date, time: "10:00")
        let entry2 = JournalEntry(content: "Second entry", category: nil, date: date, time: "14:00")
        
        // When
        journalManager.saveEntry(entry1)
        journalManager.saveEntry(entry2)
        
        // Then
        XCTAssertEqual(journalManager.entries.count, 2)
        let sameDateEntries = journalManager.getEntriesForDate(date)
        XCTAssertEqual(sameDateEntries.count, 2)
    }
}
