//
//  JournalEntry.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import Foundation

/// Location information for a journal entry
/// Stores coordinates and human-readable location details
struct LocationData: Codable, Equatable {
    /// Latitude coordinate
    let latitude: Double
    
    /// Longitude coordinate
    let longitude: Double
    
    /// Human-readable place name (e.g., "Starbucks")
    let placeName: String?
    
    /// Full address (e.g., "123 Main St, San Francisco, CA")
    let address: String?
}

/// Represents a single journal entry with content, category, and timestamp information.
/// This is the core data model for storing user's daily journal entries.
struct JournalEntry: Identifiable, Codable {
    // MARK: - Properties
    
    /// Unique identifier for the journal entry
    let id: UUID
    
    /// The main content/text of the journal entry
    let content: String
    
    /// Optional category that helps organize entries (e.g., "Met with", "Learned")
    let category: String?
    
    /// The date when this entry was created
    let date: Date
    
    /// Optional time string for when the event occurred (e.g., "14:30")
    let time: String?
    
    /// Filename of attached photo (stored in Documents/photos/)
    let photoFilename: String?
    
    /// Location data (automatically captured)
    let location: LocationData?
    
    // MARK: - Initializers
    
    /// Creates a new journal entry with the current date
    /// - Parameters:
    ///   - content: The main text content of the entry
    ///   - category: Optional category to classify the entry
    ///   - time: Optional time string for when the event occurred
    ///   - photoFilename: Optional photo filename
    ///   - location: Optional location data
    ///   - id: Optional UUID to preserve when updating entries
    init(content: String, category: String? = nil, time: String? = nil, photoFilename: String? = nil, location: LocationData? = nil, id: UUID = UUID()) {
        self.id = id
        self.content = content
        self.category = category
        self.date = Date()
        self.time = time
        self.photoFilename = photoFilename
        self.location = location
    }
    
    /// Creates a new journal entry with a specific date
    /// - Parameters:
    ///   - content: The main text content of the entry
    ///   - category: Optional category to classify the entry
    ///   - date: The specific date for this entry
    ///   - time: Optional time string for when the event occurred
    ///   - photoFilename: Optional photo filename
    ///   - location: Optional location data
    ///   - id: Optional UUID to preserve when updating entries
    init(content: String, category: String?, date: Date, time: String? = nil, photoFilename: String? = nil, location: LocationData? = nil, id: UUID = UUID()) {
        self.id = id
        self.content = content
        self.category = category
        self.date = date
        self.time = time
        self.photoFilename = photoFilename
        self.location = location
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

/// Time periods for organizing journal entries by part of day
/// Simple, universal prompts that help users recall their activities
enum TimePeriod: String, CaseIterable, Codable {
    // MARK: - Cases
    
    case morning = "Morning"
    case afternoon = "Afternoon"
    case night = "Night"
    
    // MARK: - Computed Properties
    
    /// Returns the emoji associated with each time period
    var emoji: String {
        switch self {
        case .morning: return "🌅"
        case .afternoon: return "☀️"
        case .night: return "🌙"
        }
    }
    
    /// Returns the prompt text for the time period
    var prompt: String {
        switch self {
        case .morning: return "What did you do in the morning?"
        case .afternoon: return "What did you do in the afternoon?"
        case .night: return "What did you do at night?"
        }
    }
}
