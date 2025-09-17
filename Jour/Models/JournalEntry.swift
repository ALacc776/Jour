//
//  JournalEntry.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import Foundation

struct JournalEntry: Identifiable, Codable {
    let id = UUID()
    let content: String
    let category: String?
    let date: Date
    let time: String?
    
    init(content: String, category: String? = nil, time: String? = nil) {
        self.content = content
        self.category = category
        self.date = Date()
        self.time = time
    }
    
    init(content: String, category: String?, date: Date, time: String? = nil) {
        self.content = content
        self.category = category
        self.date = date
        self.time = time
    }
}

struct JournalStreak: Codable {
    var current: Int
    var longest: Int
    var lastEntryDate: String?
    
    init(current: Int = 0, longest: Int = 0, lastEntryDate: String? = nil) {
        self.current = current
        self.longest = longest
        self.lastEntryDate = lastEntryDate
    }
}

enum JournalCategory: String, CaseIterable, Codable {
    case metWith = "Met with"
    case learned = "Learned"
    case workedOn = "Worked on"
    case wentTo = "Went to"
    case finished = "Finished"
    case felt = "Felt"
    
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
