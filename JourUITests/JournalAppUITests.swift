//
//  JournalAppUITests.swift
//  JourUITests
//
//  Created by andapple on 16/9/2025.
//

import XCTest

/// UI tests for the DayLog app
/// Tests user interface interactions and workflows
final class JournalAppUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Basic Navigation Tests
    
    func testAppLaunch() throws {
        // Verify app launches successfully
        XCTAssertTrue(app.navigationBars["Timeline"].exists)
        XCTAssertTrue(app.tabBars.buttons["Timeline"].exists)
        XCTAssertTrue(app.tabBars.buttons["Calendar"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
    }
    
    func testTabNavigation() throws {
        // Test Timeline tab
        app.tabBars.buttons["Timeline"].tap()
        XCTAssertTrue(app.navigationBars["Timeline"].exists)
        
        // Test Calendar tab
        app.tabBars.buttons["Calendar"].tap()
        XCTAssertTrue(app.navigationBars["Calendar"].exists)
        
        // Test Settings tab
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }
    
    // MARK: - Journal Entry Tests
    
    func testCreateJournalEntry() throws {
        // Navigate to Timeline tab
        app.tabBars.buttons["Timeline"].tap()
        
        // Tap Log Day button
        app.buttons["Log Day"].tap()
        
        // Verify NewEntryView is presented
        XCTAssertTrue(app.navigationBars["Log Day"].exists)
        
        // Select a category
        app.buttons["Met with"].tap()
        
        // Enter text
        let textEditor = app.textViews.firstMatch
        textEditor.tap()
        textEditor.typeText("Test journal entry")
        
        // Save entry
        app.buttons["Save"].tap()
        
        // Verify entry was created
        XCTAssertTrue(app.staticTexts["Test journal entry"].exists)
    }
    
    func testCreateFreeFormEntry() throws {
        // Navigate to Timeline tab
        app.tabBars.buttons["Timeline"].tap()
        
        // Tap Log Day button
        app.buttons["Log Day"].tap()
        
        // Select free form entry
        app.buttons["Free write entry"].tap()
        
        // Enter text
        let textEditor = app.textViews.firstMatch
        textEditor.tap()
        textEditor.typeText("Free form journal entry")
        
        // Save entry
        app.buttons["Save"].tap()
        
        // Verify entry was created
        XCTAssertTrue(app.staticTexts["Free form journal entry"].exists)
    }
    
    func testCreateQuickEntry() throws {
        // Navigate to Timeline tab
        app.tabBars.buttons["Timeline"].tap()
        
        // Tap Log Day button
        app.buttons["Log Day"].tap()
        
        // Select quick entry
        app.buttons["Quick entry (one line = one entry)"].tap()
        
        // Enter multiple lines
        let textEditor = app.textViews.firstMatch
        textEditor.tap()
        textEditor.typeText("First entry\nSecond entry\nThird entry")
        
        // Save entries
        app.buttons["Save 3 entries"].tap()
        
        // Verify entries were created
        XCTAssertTrue(app.staticTexts["First entry"].exists)
        XCTAssertTrue(app.staticTexts["Second entry"].exists)
        XCTAssertTrue(app.staticTexts["Third entry"].exists)
    }
    
    // MARK: - Settings Tests
    
    func testSettingsNavigation() throws {
        // Navigate to Settings tab
        app.tabBars.buttons["Settings"].tap()
        
        // Verify settings elements exist
        XCTAssertTrue(app.staticTexts["Privacy & Security"].exists)
        XCTAssertTrue(app.staticTexts["Data Management"].exists)
        XCTAssertTrue(app.staticTexts["App Information"].exists)
        XCTAssertTrue(app.staticTexts["Statistics"].exists)
    }
    
    func testPrivacyPolicyView() throws {
        // Navigate to Settings tab
        app.tabBars.buttons["Settings"].tap()
        
        // Tap Privacy Policy
        app.buttons["Privacy Policy"].tap()
        
        // Verify privacy policy is displayed
        XCTAssertTrue(app.navigationBars["Privacy Policy"].exists)
        XCTAssertTrue(app.staticTexts["Quick Summary"].exists)
        XCTAssertTrue(app.staticTexts["Information We Collect"].exists)
        
        // Dismiss privacy policy
        app.buttons["Done"].tap()
        
        // Verify we're back to settings
        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }
    
    func testAboutView() throws {
        // Navigate to Settings tab
        app.tabBars.buttons["Settings"].tap()
        
        // Tap About DayLog
        app.buttons["About DayLog"].tap()
        
        // Verify about view is displayed
        XCTAssertTrue(app.navigationBars["About"].exists)
        XCTAssertTrue(app.staticTexts["DayLog"].exists)
        XCTAssertTrue(app.staticTexts["Version 1.0.0"].exists)
        
        // Dismiss about view
        app.buttons["Done"].tap()
        
        // Verify we're back to settings
        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }
    
    // MARK: - Data Export Tests
    
    func testDataExport() throws {
        // First create an entry
        app.tabBars.buttons["Timeline"].tap()
        app.buttons["Log Day"].tap()
        app.buttons["Met with"].tap()
        
        let textEditor = app.textViews.firstMatch
        textEditor.tap()
        textEditor.typeText("Test entry for export")
        
        app.buttons["Save"].tap()
        
        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()
        
        // Tap Export Data
        app.buttons["Export Data"].tap()
        
        // Verify export view is displayed
        XCTAssertTrue(app.navigationBars["Data Export"].exists)
        XCTAssertTrue(app.staticTexts["Export Data"].exists)
        XCTAssertTrue(app.staticTexts["Import Data"].exists)
        
        // Dismiss export view
        app.buttons["Done"].tap()
    }
    
    // MARK: - Calendar Tests
    
    func testCalendarView() throws {
        // Navigate to Calendar tab
        app.tabBars.buttons["Calendar"].tap()
        
        // Verify calendar elements exist
        XCTAssertTrue(app.navigationBars["Calendar"].exists)
        XCTAssertTrue(app.staticTexts["Entries for"].exists)
        
        // Test date picker interaction
        let datePicker = app.datePickers.firstMatch
        if datePicker.exists {
            datePicker.tap()
            // Date picker interaction would go here
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() throws {
        // Test that important elements have accessibility labels
        app.tabBars.buttons["Timeline"].tap()
        
        let logDayButton = app.buttons["Log Day"]
        XCTAssertTrue(logDayButton.exists)
        XCTAssertEqual(logDayButton.label, "Log Day Button")
        
        // Test category buttons
        app.buttons["Log Day"].tap()
        let metWithButton = app.buttons["Met with"]
        if metWithButton.exists {
            XCTAssertTrue(metWithButton.label.contains("category"))
        }
    }
    
    // MARK: - Performance Tests
    
    func testAppPerformance() throws {
        // Measure app launch time
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
        
        // Test scrolling performance
        app.tabBars.buttons["Timeline"].tap()
        
        // Create multiple entries to test scrolling
        for i in 1...5 {
            app.buttons["Log Day"].tap()
            app.buttons["Met with"].tap()
            
            let textEditor = app.textViews.firstMatch
            textEditor.tap()
            textEditor.typeText("Performance test entry \(i)")
            
            app.buttons["Save"].tap()
        }
        
        // Test scrolling
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
            scrollView.swipeDown()
        }
    }
}
