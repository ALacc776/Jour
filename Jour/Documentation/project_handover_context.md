PROJECT HANDOVER CONTEXT

This document provides an overview of the Jour (DayLog) application codebase. It summarizes the architecture, key features, and critical implementation details.

PROJECT OVERVIEW

App Name: Jour (displayed as DayLog in some export contexts)
Platform: iOS 16+
Language: Swift 5
Interface: SwiftUI
Persistence: UserDefaults (Encrypted JSON)

CORE ARCHITECTURE

The app follows a standard MVVM (Model-View-ViewModel) pattern.

1. Managers (ViewModels/Services):
   - JournalManager: The central source of truth. It holds the entries array and streak state. It handles CRUD operations, sorting, and persistence.
   - NotificationManager: Manages local notifications. It handles permission requests and scheduling daily reminders.
   - PrivacyManager: Handles encryption and decryption of journal data before saving to disk.

2. Models:
   - JournalEntry: The core data structure. It is Identifiable and Codable. Fields: id, content, date, category, time, location, photoFilename.
   - JournalStreak: Tracks current and longest streaks.
   - ExportData: A container used specifically for JSON export/import to version the data schema.

3. Views:
   - TodayView: The main input interface for adding new entries.
   - StatsView: Displays the heatmap and streak statistics.
   - CalendarHeatMap: A custom component rendering the GitHub-style contribution graph.
   - DataExportView: Handles exporting data to JSON/CSV/Text and importing from backups.

CRITICAL IMPLEMENTATION DETAILS

1. The Heatmap (CalendarHeatMap.swift)
The heatmap visualizes the last 52 weeks of activity.
- Layout: It uses an HStack of VStacks. Each column represents a week.
- Alignment Fix: We encountered an issue where variable month label widths (like "September") caused the grid columns to expand unevenly. The solution was to place month labels inside an overlay on a fixed-width spacer. This ensures every grid column is exactly 10 points wide regardless of the text above it.
- Scrolling: The view uses ScrollViewReader to automatically scroll to the end (the current date) when the view appears.
- Navigation: A gradient overlay on the left edge provides a visual cue that the timeline extends into the past.

2. Data Export (DataExportView.swift)
We initially attempted to use the SwiftUI ShareLink API, but it proved unreliable on the Simulator, often failing to present the share sheet.
- Solution: We replaced it with UIActivityViewController wrapped in a UIViewControllerRepresentable struct called ShareSheet.
- Metadata: We implemented a custom UIActivityItemSource (class ShareActivityItemSource) to explicitly provide file metadata (UTI type and filename) to the system. This prevents errors where the system fails to fetch the item or determine its type.
- Future Proofing: The JSON export includes an appVersion field. Future import logic should check this field to determine if data migration is needed.

3. Streak Logic (JournalManager.swift)
Streak calculation is logic-heavy to ensure accuracy.
- Hardening: We do not rely solely on a cached integer for the current streak. When the app checks "Yesterday," if it finds an entry there but not today, it recalculates the entire streak chain from the raw entry dates. This self-healing logic prevents the streak count from drifting due to cache errors.

4. Persistence & Threading
- Storage: Data is stored in UserDefaults.standard under specific keys defined in AppConstants.
- Encryption: JSON data is stringified and encrypted by PrivacyManager before storage.
- Concurrency: Save operations are dispatched to a background queue (persistenceQueue) to avoid blocking the main UI thread, while published property updates happen on the main thread.

DIRECTORY STRUCTURE NOTES

- Components: Reusable UI elements (CalendarHeatMap, entry cards).
- Managers: Business logic and state holders.
- Extensions: Helper functions for Date formatting and View modifiers.
- Documentation: Contains strategic guides like versioning_strategy.md.

KNOWN CONSTRAINTS
- Images: Photos are stored in the local documents directory. The current export logic (JSON/CSV) exports metadata about the photos (filenames) but does not package the binary image data into the export file.
- iOS 16 Support: The code uses FileRepresentation for data transfer to ensure compatibility with iOS 16, avoiding iOS 17-only APIs.
