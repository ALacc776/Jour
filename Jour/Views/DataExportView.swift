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
    
    /// Controls the presentation of alerts
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    /// Selected export format
    @State private var selectedExportFormat: ExportFormat = .json
    
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
    
    /// Controls the presentation of the share sheet
    @State private var showingShareSheet = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
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
                    if let _ = exportURL { // Check if URL is ready
                        Button(action: {
                            showingShareSheet = true
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
                    } else {
                        // Loading state
                        Button(action: {}) {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Preparing...")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppConstants.Spacing.lg)
                            .primaryButtonStyle()
                        }
                        .disabled(true)
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
                            .accessibilityLabel("Total Entries Count")
                        Spacer()
                        Text("\(journalManager.entries.count)")
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                    }
                    
                    HStack {
                        Text("Current Streak:")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                            .accessibilityLabel("Current Streak Count")
                        Spacer()
                        Text("\(journalManager.streak.current) days")
                            .fontWeight(.semibold)
                            .foregroundColor(AppConstants.Colors.primaryText)
                    }
                    
                    HStack {
                        Text("Best Streak:")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                            .accessibilityLabel("Best Streak Count")
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
        .onAppear {
            generateExportFile()
        }
        .onChange(of: selectedExportFormat) { _ in
            generateExportFile()
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(
                allowedContentTypes: [.json, .plainText, .commaSeparatedText],
                onDocumentPicked: { url in
                    importData(from: url)
                }
            )
        }
        // Share Sheet Presentation
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    /// The URL of the generated export file (temp)
    @State private var exportURL: URL?
    
    /// Generates the export file based on current selection
    private func generateExportFile() {
        let exportable = ExportableJournal(
            entries: journalManager.entries,
            streak: journalManager.streak,
            format: selectedExportFormat
        )
        
        do {
            let data: Data
            switch selectedExportFormat {
            case .json: data = try exportable.generateJSON()
            case .text: data = try exportable.generateText()
            case .csv: data = try exportable.generateCSV()
            }
            
            // Clean up old temp file if exists?
            // Actually, just generate a new one.
            exportURL = try exportable.saveToTemp(data: data, ext: selectedExportFormat.fileExtension)
        } catch {
            print("Failed to generate export file: \(error)")
            // Fallback or alert? For now silent failure means button stays loading or disabled.
        }
    }
    
    // MARK: - Private Methods
    
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
            
            // Add haptic feedback
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        } catch {
            showAlert(title: "Import Failed", message: "Failed to import data: \(error.localizedDescription)")
            
            // Add haptic feedback
            let errorFeedback = UINotificationFeedbackGenerator()
            errorFeedback.notificationOccurred(.error)
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
    
    /// Imports data from text format (simple fallback)
    private func importFromText(_ data: Data) throws {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ImportError.invalidData
        }
        
        // Simple text parsing
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
        
        var lines: [String] = []
        
        // Smart CSV parsing handling quoted newlines
        // This is a basic state machine parser
        var currentLine = ""
        var inQuotes = false
        
        for char in csv {
            if char == "\"" {
                inQuotes.toggle()
                currentLine.append(char)
            } else if char == "\n" && !inQuotes {
                lines.append(currentLine)
                currentLine = ""
            } else {
                currentLine.append(char)
            }
        }
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        guard lines.count > 1 else {
            throw ImportError.invalidData
        }
        
        // Skip header line
        for line in lines.dropFirst() {
            guard !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            
            let fields = parseCSVLine(line)
            guard fields.count >= 4 else { continue }
            
            let dateString = fields[0]
            let timeString = fields[1]
            let categoryString = fields[2]
            let contentString = fields[3]
            
            // Parse date
            let formatter = DateFormatter()
            formatter.dateStyle = .short
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

// MARK: - Transferable Implementation

struct ExportableJournal {
    let entries: [JournalEntry]
    let streak: JournalStreak
    let format: DataExportView.ExportFormat
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    enum ExportError: Error {
        case wrongFormat
    }
    
    // Helper to create temp file for sharing
    func saveToTemp(data: Data, ext: String) throws -> URL {
        let fileName = "DayLog_Export_\(dateString).\(ext)"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: url)
        return url
    }
    
    // Generator Methods
    
    func generateJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let exportData = ExportData(
            entries: entries,
            streak: streak,
            exportDate: Date(),
            appVersion: "1.0.0"
        )
        
        return try encoder.encode(exportData)
    }
    
    func generateText() throws -> Data {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        var text = "DayLog Export\n"
        text += "Exported on: \(dateFormatter.string(from: Date()))\n"
        text += "Total Entries: \(entries.count)\n"
        text += "Current Streak: \(streak.current) days\n\n"
        
        text += "Journal Entries:\n"
        text += String(repeating: "=", count: 50) + "\n\n"
        
        for entry in entries.sorted(by: { $0.date > $1.date }) {
            text += "Date: \(dateFormatter.string(from: entry.date))\n"
            if let category = entry.category {
                text += "Category: \(category)\n"
            }
            text += "Content: \(entry.content)\n"
            text += String(repeating: "-", count: 30) + "\n\n"
        }
        
        return text.data(using: .utf8) ?? Data()
    }
    
    func generateCSV() throws -> Data {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        var csv = "Date,Time,Category,Content,Has Photo\n"
        
        for entry in entries.sorted(by: { $0.date > $1.date }) {
            let date = dateFormatter.string(from: entry.date)
            let time = entry.time ?? ""
            let category = entry.category ?? ""
            // CSV Escape: double quotes for quotes
            let content = entry.content.replacingOccurrences(of: "\"", with: "\"\"")
            let hasPhoto = entry.photoFilename != nil ? "Yes" : "No"
            
            csv += "\"\(date)\",\"\(time)\",\"\(category)\",\"\(content)\",\"\(hasPhoto)\"\n"
        }
        
        return csv.data(using: .utf8) ?? Data()
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

// MARK: - Share Sheet Helper

// MARK: - Share Sheet Helper

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Wrap URL in item source to provide metadata and correct handling
        let items = activityItems.map { item -> Any in
            if let url = item as? URL {
                return ShareActivityItemSource(url: url)
            }
            return item
        }
        
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

/// Proxy to correctly handle file URL sharing metadata
class ShareActivityItemSource: NSObject, UIActivityItemSource {
    let url: URL
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return url
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return url
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return url.lastPathComponent
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        // Explicitly declare type to avoid system guessing
        if url.pathExtension == "json" { return "public.json" }
        if url.pathExtension == "csv" { return "public.comma-separated-values-text" }
        return "public.plain-text"
    }
}

#Preview {
    DataExportView(journalManager: JournalManager())
}
