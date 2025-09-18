//
//  JournalEntry.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import Foundation

/// Represents a single journal entry with content, category, and timestamp information.
/// This is the core data model for storing user's daily journal entries.
struct JournalEntry: Identifiable, Codable {
    // MARK: - Properties
    
    /// Unique identifier for the journal entry
    let id = UUID()
    
    /// The main content/text of the journal entry
    let content: String
    
    /// Optional category that helps organize entries (e.g., "Met with", "Learned")
    let category: String?
    
    /// The date when this entry was created
    let date: Date
    
    /// Optional time string for when the event occurred (e.g., "14:30")
    let time: String?
    
    // MARK: - Initializers
    
    /// Creates a new journal entry with the current date
    /// - Parameters:
    ///   - content: The main text content of the entry
    ///   - category: Optional category to classify the entry
    ///   - time: Optional time string for when the event occurred
    init(content: String, category: String? = nil, time: String? = nil) {
        self.content = content
        self.category = category
        self.date = Date()
        self.time = time
    }
    
    /// Creates a new journal entry with a specific date
    /// - Parameters:
    ///   - content: The main text content of the entry
    ///   - category: Optional category to classify the entry
    ///   - date: The specific date for this entry
    ///   - time: Optional time string for when the event occurred
    init(content: String, category: String?, date: Date, time: String? = nil) {
        self.content = content
        self.category = category
        self.date = date
        self.time = time
    }
}

/// Tracks the user's journaling streak statistics
/// This model stores information about consecutive days of journaling
struct JournalStreak: Codable {
    // MARK: - Properties
    
    /// Current consecutive days of journaling
    var current: Int
    
    /// Longest streak ever achieved
    var longest: Int
    
    /// Date of the last entry (stored as string for persistence)
    var lastEntryDate: String?
    
    // MARK: - Initializer
    
    /// Creates a new streak tracker
    /// - Parameters:
    ///   - current: Current consecutive days (default: 0)
    ///   - longest: Longest streak achieved (default: 0)
    ///   - lastEntryDate: Date of last entry (default: nil)
    init(current: Int = 0, longest: Int = 0, lastEntryDate: String? = nil) {
        self.current = current
        self.longest = longest
        self.lastEntryDate = lastEntryDate
    }
}

/// Predefined categories for journal entries to help users organize their thoughts
/// Each category has a human-readable name and an associated emoji for visual representation
enum JournalCategory: String, CaseIterable, Codable {
    // MARK: - Cases
    
    case metWith = "Met with"
    case learned = "Learned"
    case workedOn = "Worked on"
    case wentTo = "Went to"
    case finished = "Finished"
    case felt = "Felt"
    
    // MARK: - Computed Properties
    
    /// Returns the emoji associated with each category for visual representation
    var emoji: String {
        switch self {
        case .metWith: return "👥"
        case .learned: return "📚"
        case .workedOn: return "💼"
        case .wentTo: return "🚀"
        case .finished: return "✅"
        case .felt: return "💭"
        }
    }
}
