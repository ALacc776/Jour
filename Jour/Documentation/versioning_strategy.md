DATA VERSIONING AND FUTURE PROOFING STRATEGY

GOAL
Ensure that data exported from Version 1.0.0 of DayLog can still be imported into Version 2.0, 3.0, etc., even if the underlying data model changes.

1. THE CORE CONTRACT: ExportData Struct

Currently, your export structure looks like this:

struct ExportData: Codable {
    let entries: [JournalEntry]
    let streak: JournalStreak
    let exportDate: Date
    let appVersion: String // CRITICAL FIELD
}

Rule 1: Never Rename or Delete Existing Fields
In future versions of ExportData or JournalEntry:
- DO NOT rename id, content, date, category.
- DO NOT change the data type of an existing field (e.g., String to Int).

Rule 2: Only Add Optional Fields
If you add a new feature (e.g., "Mood Tracking"), add it as an optional field.

// Future JournalEntry
struct JournalEntry: Codable {
    // ... old fields ...
    let mood: String? // New Optional Field
}

By making it optional (?), the JSON decoder will trigger:
- Old Exports (v1.0): Will simply have nil for mood. The import succeeds.
- New Exports (v2.0): Will have the mood data.

2. HANDLING BREAKING CHANGES (The appVersion Check)

If you MUST make a breaking change (e.g., completely restructuring how locations are stored), use the appVersion field in your import logic to run a "migration."

Example Implementation in importFromJSON:

private func importFromJSON(_ data: Data) throws {
    // 1. Decode generic container first to check version
    let metadata = try JSONDecoder().decode(ExportMetadata.self, from: data)
    
    if metadata.appVersion.hasPrefix("1.") {
        // Use v1 Decoder logic
        let v1Data = try JSONDecoder().decode(ExportDataV1.self, from: data)
        // Convert V1 objects to Current objects...
        for entry in v1Data.entries {
             let newEntry = JournalEntry(content: entry.content, date: entry.date, ...)
             journalManager.saveEntry(newEntry)
        }
    } else {
        // Standard decode for current version
        let exportData = try JSONDecoder().decode(ExportData.self, from: data)
        // ...
    }
}

// Helper for checking version only
struct ExportMetadata: Codable {
    let appVersion: String
}

3. CSV AND TEXT FUTURE PROOFING

These formats are "lossy" (they don't store everything).
- Text: Purely for human reading. Do not rely on it for full restore.
- CSV: Similar rule applies. Add new columns to the END of the CSV header.
  - Old App: Date,Time,Content
  - New App: Date,Time,Content,Mood
  - Your parser should be robust enough to handle missing columns (index out of bounds checks).

SUMMARY CHECKLIST FOR UPDATES

1. Add New Fields as Optionals (?).
2. Never rename existing JSON keys.
3. Bump appVersion string in DataExportView.swift.
4. Test Import: Always test importing a file from v1.0 into your new dev build before releasing.
