//
//  DataExportView.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import SwiftUI
import UniformTypeIdentifiers

/// View for exporting and importing journal data
/// Provides options to export data in various formats and import from backups
struct DataExportView: View {
    // MARK: - Properties
    
    /// Reference to the journal manager for data operations
    @ObservedObject var journalManager: JournalManager
    
    /// Environment value for dismissing the modal
    @Environment(\.dismiss) private var dismiss
    
    /// Controls the presentation of the document picker for import
    @State private var showingDocumentPicker = false
    
    /// Controls the presentation of the share sheet for export
    @State private var showingShareSheet = false
    
    /// Controls the presentation of alerts
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    /// Selected export format
    @State private var selectedExportFormat: ExportFormat = .json
    
    /// Export file URL to share
    @State private var exportFileURL: URL?
    
    // MARK: - Export Formats
    
    /// Available export formats
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case text = "Text"
        case csv = "CSV"
        
        var fileExtension: String {
            switch self {
            case .json: return "json"
            case .text: return "txt"
            case .csv: return "csv"
            }
        }
        
        var utType: UTType {
            switch self {
            case .json: return .json
            case .text: return .plainText
            case .csv: return .commaSeparatedText
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppConstants.Spacing.xl) {
                // MARK: - Export Section
                VStack(alignment: .leading, spacing: AppConstants.Spacing.lg) {
                    Text("Export Data")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppConstants.Colors.primaryText)
                    
                    Text("Choose a format to export your journal entries")
                        .font(.body)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                    
                    // Export Format Selection
                    VStack(alignment: .leading, spacing: AppConstants.Spacing.sm) {
                        Text("Export Format")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Picker("Format", selection: $selectedExportFormat) {
                            ForEach(ExportFormat.allCases, id: \.self) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Export Button
                    Button(action: {
                        performExport()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.headline)
                            Text("Export \(journalManager.entries.count) Entries")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppConstants.Spacing.lg)
                        .primaryButtonStyle()
                    }
                    .disabled(journalManager.entries.isEmpty)
                }
                .padding(AppConstants.Spacing.xl)
                .background(AppConstants.Colors.secondaryBackground)
                .cornerRadius(AppConstants.CornerRadius.lg)
                .shadow(
                    color: AppConstants.Shadows.card.color,
                    radius: AppConstants.Shadows.card.radius,
                    x: AppConstants.Shadows.card.x,
                    y: AppConstants.Shadows.card.y
                )
                
                // MARK: - Import Section
                VStack(alignment: .leading, spacing: AppConstants.Spacing.lg) {
                    Text("Import Data")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppConstants.Colors.primaryText)
                    
                    Text("Import journal entries from a backup file")
                        .font(.body)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                    
                    // Import Button
                    Button(action: {
                        showingDocumentPicker = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .font(.headline)
                            Text("Import from File")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppConstants.Spacing.lg)
                        .secondaryButtonStyle()
                    }
                }
                .padding(AppConstants.Spacing.xl)
                .background(AppConstants.Colors.secondaryBackground)
                .cornerRadius(AppConstants.CornerRadius.lg)
                .shadow(
                    color: AppConstants.Shadows.card.color,
                    radius: AppConstants.Shadows.card.radius,
                    x: AppConstants.Shadows.card.x,
                    y: AppConstants.Shadows.card.y
                )
                
                // MARK: - Statistics
                VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
                    Text("Your Data")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppConstants.Colors.primaryText)
                    
                    HStack {
                        Text("Total Entries:")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        Spacer()
                        Text("\(journalManager.entries.count)")
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                    }
                    
                    HStack {
                        Text("Current Streak:")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        Spacer()
                        Text("\(journalManager.streak.current) days")
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                    }
                    
                    HStack {
                        Text("Best Streak:")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        Spacer()
                        Text("\(journalManager.streak.longest) days")
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                    }
                }
                .padding(AppConstants.Spacing.xl)
                .background(AppConstants.Colors.secondaryBackground)
                .cornerRadius(AppConstants.CornerRadius.lg)
                .shadow(
                    color: AppConstants.Shadows.card.color,
                    radius: AppConstants.Shadows.card.radius,
                    x: AppConstants.Shadows.card.x,
                    y: AppConstants.Shadows.card.y
                )
                
                Spacer()
            }
            .padding(AppConstants.Spacing.xl)
            .navigationTitle("Data Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppConstants.Colors.accentButton)
                }
            }
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(
                allowedContentTypes: [.json, .plainText, .commaSeparatedText],
                onDocumentPicked: { url in
                    importData(from: url)
                }
            )
        }
        .sheet(isPresented: $showingShareSheet) {
            if let fileURL = exportFileURL {
                ShareSheet(activityItems: [fileURL])
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Private Methods
    
    /// Exports journal data in the selected format
    private func performExport() {
        // Create timestamp for filename
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        let fileName = "DayLog_Export_\(timestamp).\(selectedExportFormat.fileExtension)"
        
        do {
            // Get data based on format
            let data: Data
            switch selectedExportFormat {
            case .json:
                data = try exportAsJSON()
            case .text:
                data = try exportAsText()
            case .csv:
                data = try exportAsCSV()
            }
            
            // Create temporary file
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            // Write data to file
            try data.write(to: fileURL)
            
            // Store URL for sharing
            exportFileURL = fileURL
            
            // Add haptic feedback
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
            
            // Show share sheet
            showingShareSheet = true
        } catch {
            // Add haptic feedback for error
            let errorFeedback = UINotificationFeedbackGenerator()
            errorFeedback.notificationOccurred(.error)
            
            showAlert(title: "Export Failed", message: "Failed to export data: \(error.localizedDescription)")
        }
    }
    
    /// Exports data as JSON format
    private func exportAsJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let exportData = ExportData(
            entries: journalManager.entries,
            streak: journalManager.streak,
            exportDate: Date(),
            appVersion: "1.0.0"
        )
        
        return try encoder.encode(exportData)
    }
    
    /// Exports data as plain text format
    private func exportAsText() throws -> Data {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        var text = "DayLog Export\n"
        text += "Exported on: \(dateFormatter.string(from: Date()))\n"
        text += "Total Entries: \(journalManager.entries.count)\n"
        text += "Current Streak: \(journalManager.streak.current) days\n"
        text += "Best Streak: \(journalManager.streak.longest) days\n\n"
        
        text += "Journal Entries:\n"
        text += String(repeating: "=", count: 50) + "\n\n"
        
        for entry in journalManager.entries.sorted(by: { $0.date > $1.date }) {
            text += "Date: \(dateFormatter.string(from: entry.date))\n"
            if let category = entry.category {
                text += "Category: \(category)\n"
            }
            if let time = entry.time {
                text += "Time: \(time)\n"
            }
            text += "Content: \(entry.content)\n"
            if entry.photoFilename != nil {
                text += "[Photo attached]\n"
            }
            text += String(repeating: "-", count: 30) + "\n\n"
        }
        
        return text.data(using: .utf8) ?? Data()
    }
    
    /// Exports data as CSV format
    private func exportAsCSV() throws -> Data {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        var csv = "Date,Time,Category,Content,Has Photo\n"
        
        for entry in journalManager.entries.sorted(by: { $0.date > $1.date }) {
            let date = dateFormatter.string(from: entry.date)
            let time = entry.time ?? ""
            let category = entry.category ?? ""
            let content = entry.content.replacingOccurrences(of: "\"", with: "\"\"")
            let hasPhoto = entry.photoFilename != nil ? "Yes" : "No"
            
            csv += "\"\(date)\",\"\(time)\",\"\(category)\",\"\(content)\",\"\(hasPhoto)\"\n"
        }
        
        return csv.data(using: .utf8) ?? Data()
    }
    
    /// Imports data from a file URL
    private func importData(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            
            if url.pathExtension.lowercased() == "json" {
                try importFromJSON(data)
            } else if url.pathExtension.lowercased() == "txt" {
                try importFromText(data)
            } else if url.pathExtension.lowercased() == "csv" {
                try importFromCSV(data)
            } else {
                throw ImportError.unsupportedFormat
            }
            
            showAlert(title: "Import Successful", message: "Successfully imported data from file.")
        } catch {
            showAlert(title: "Import Failed", message: "Failed to import data: \(error.localizedDescription)")
        }
    }
    
    /// Imports data from JSON format
    private func importFromJSON(_ data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let exportData = try decoder.decode(ExportData.self, from: data)
        
        // Add imported entries to existing ones
        for entry in exportData.entries {
            journalManager.saveEntry(entry)
        }
        
        // Update streak if imported data has higher values
        if exportData.streak.longest > journalManager.streak.longest {
            journalManager.streak.longest = exportData.streak.longest
        }
    }
    
    /// Imports data from text format (basic implementation)
    private func importFromText(_ data: Data) throws {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ImportError.invalidData
        }
        
        // Simple text parsing - in a real app, you'd want more robust parsing
        let lines = text.components(separatedBy: .newlines)
        var currentEntry: JournalEntry?
        
        for line in lines {
            if line.hasPrefix("Date:") {
                // Process previous entry
                if let entry = currentEntry {
                    journalManager.saveEntry(entry)
                }
                currentEntry = nil
            } else if line.hasPrefix("Content:") {
                let content = String(line.dropFirst(8)).trimmingCharacters(in: .whitespacesAndNewlines)
                if currentEntry == nil {
                    currentEntry = JournalEntry(content: content)
                }
            }
        }
        
        // Process last entry
        if let entry = currentEntry {
            journalManager.saveEntry(entry)
        }
    }
    
    /// Imports data from CSV format
    private func importFromCSV(_ data: Data) throws {
        guard let csv = String(data: data, encoding: .utf8) else {
            throw ImportError.invalidData
        }
        
        let lines = csv.components(separatedBy: .newlines)
        guard lines.count > 1 else {
            throw ImportError.invalidData
        }
        
        // Skip header line
        for line in lines.dropFirst() {
            guard !line.isEmpty else { continue }
            
            let fields = parseCSVLine(line)
            guard fields.count >= 4 else { continue }
            
            let dateString = fields[0]
            let timeString = fields[1]
            let categoryString = fields[2]
            let contentString = fields[3]
            
            // Parse date
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            guard let date = formatter.date(from: dateString) else { continue }
            
            // Create entry
            let category = categoryString.isEmpty ? nil : categoryString
            let time = timeString.isEmpty ? nil : timeString
            
            let entry = JournalEntry(content: contentString, category: category, date: date, time: time)
            journalManager.saveEntry(entry)
        }
    }
    
    /// Parses a CSV line handling quoted fields
    private func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                fields.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        fields.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
        return fields
    }
    
    /// Shows an alert with the given title and message
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

// MARK: - Export Data Model

/// Data model for exporting journal data
struct ExportData: Codable {
    let entries: [JournalEntry]
    let streak: JournalStreak
    let exportDate: Date
    let appVersion: String
}

// MARK: - Import Errors

/// Errors that can occur during data import
enum ImportError: Error, LocalizedError {
    case unsupportedFormat
    case invalidData
    case parsingFailed
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFormat:
            return "Unsupported file format"
        case .invalidData:
            return "Invalid data format"
        case .parsingFailed:
            return "Failed to parse data"
        }
    }
}

// MARK: - Document Picker

/// Document picker for selecting files to import
struct DocumentPicker: UIViewControllerRepresentable {
    let allowedContentTypes: [UTType]
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onDocumentPicked(url)
        }
    }
}

// MARK: - Share Sheet

/// Share sheet for exporting data
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    DataExportView(journalManager: JournalManager())
}
