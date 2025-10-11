//
//  PrivacyManagerTests.swift
//  JourTests
//
//  Created by andapple on 16/9/2025.
//

import XCTest
@testable import Jour

/// Unit tests for PrivacyManager functionality
/// Tests encryption, decryption, and privacy preferences
final class PrivacyManagerTests: XCTestCase {
    
    var privacyManager: PrivacyManager!
    
    override func setUpWithError() throws {
        privacyManager = PrivacyManager()
    }
    
    override func tearDownWithError() throws {
        privacyManager = nil
    }
    
    // MARK: - Encryption/Decryption Tests
    
    func testEncryptDecryptText() throws {
        // Given
        let originalText = "This is a test journal entry with sensitive information."
        privacyManager.isEncryptionEnabled = true
        
        // When
        let encryptedData = privacyManager.encryptText(originalText)
        let decryptedText = privacyManager.decryptText(encryptedData!)
        
        // Then
        XCTAssertNotNil(encryptedData)
        XCTAssertNotNil(decryptedText)
        XCTAssertEqual(decryptedText, originalText)
    }
    
    func testEncryptDecryptEmptyText() throws {
        // Given
        let originalText = ""
        privacyManager.isEncryptionEnabled = true
        
        // When
        let encryptedData = privacyManager.encryptText(originalText)
        let decryptedText = privacyManager.decryptText(encryptedData!)
        
        // Then
        XCTAssertNotNil(encryptedData)
        XCTAssertNotNil(decryptedText)
        XCTAssertEqual(decryptedText, originalText)
    }
    
    func testEncryptDecryptSpecialCharacters() throws {
        // Given
        let originalText = "Special chars: 🎉 émojis & symbols! @#$%^&*()"
        privacyManager.isEncryptionEnabled = true
        
        // When
        let encryptedData = privacyManager.encryptText(originalText)
        let decryptedText = privacyManager.decryptText(encryptedData!)
        
        // Then
        XCTAssertNotNil(encryptedData)
        XCTAssertNotNil(decryptedText)
        XCTAssertEqual(decryptedText, originalText)
    }
    
    func testEncryptionDisabled() throws {
        // Given
        let originalText = "Test entry"
        privacyManager.isEncryptionEnabled = false
        
        // When
        let encryptedData = privacyManager.encryptText(originalText)
        let decryptedText = privacyManager.decryptText(encryptedData!)
        
        // Then
        XCTAssertNotNil(encryptedData)
        XCTAssertNotNil(decryptedText)
        XCTAssertEqual(decryptedText, originalText)
    }
    
    // MARK: - Privacy Preferences Tests
    
    func testUserConsent() throws {
        // Given
        XCTAssertFalse(privacyManager.hasUserConsent)
        
        // When
        let consentGiven = privacyManager.requestUserConsent()
        
        // Then
        XCTAssertTrue(consentGiven)
        XCTAssertTrue(privacyManager.hasUserConsent)
    }
    
    func testPrivacyPolicyAcceptance() throws {
        // Given
        XCTAssertFalse(privacyManager.hasAcceptedPrivacyPolicy)
        
        // When
        privacyManager.acceptPrivacyPolicy()
        
        // Then
        XCTAssertTrue(privacyManager.hasAcceptedPrivacyPolicy)
    }
    
    func testResetPrivacyPreferences() throws {
        // Given
        privacyManager.hasUserConsent = true
        privacyManager.hasAcceptedPrivacyPolicy = true
        privacyManager.isEncryptionEnabled = false
        
        // When
        privacyManager.resetPrivacyPreferences()
        
        // Then
        XCTAssertFalse(privacyManager.hasUserConsent)
        XCTAssertFalse(privacyManager.hasAcceptedPrivacyPolicy)
        XCTAssertTrue(privacyManager.isEncryptionEnabled)
    }
    
    // MARK: - Edge Cases
    
    func testEncryptNilText() throws {
        // Given
        privacyManager.isEncryptionEnabled = true
        
        // When
        let encryptedData = privacyManager.encryptText("")
        
        // Then
        XCTAssertNotNil(encryptedData)
    }
    
    func testDecryptInvalidData() throws {
        // Given
        let invalidData = Data([0x00, 0x01, 0x02, 0x03])
        privacyManager.isEncryptionEnabled = true
        
        // When
        let decryptedText = privacyManager.decryptText(invalidData)
        
        // Then
        XCTAssertNil(decryptedText)
    }
    
    func testLargeTextEncryption() throws {
        // Given
        let largeText = String(repeating: "This is a test entry. ", count: 1000)
        privacyManager.isEncryptionEnabled = true
        
        // When
        let encryptedData = privacyManager.encryptText(largeText)
        let decryptedText = privacyManager.decryptText(encryptedData!)
        
        // Then
        XCTAssertNotNil(encryptedData)
        XCTAssertNotNil(decryptedText)
        XCTAssertEqual(decryptedText, largeText)
    }
}
