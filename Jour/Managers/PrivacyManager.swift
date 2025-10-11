//
//  PrivacyManager.swift
//  Jour
//
//  Created by andapple on 16/9/2025.
//

import Foundation
import Security
import CryptoKit

/// Manages privacy, encryption, and user consent for the journal app
/// Handles data encryption, user consent tracking, and privacy compliance
class PrivacyManager: ObservableObject {
    // MARK: - Published Properties
    
    /// Whether the user has consented to data collection
    @Published var hasUserConsent = false
    
    /// Whether encryption is enabled
    @Published var isEncryptionEnabled = true
    
    /// Privacy policy acceptance status
    @Published var hasAcceptedPrivacyPolicy = false
    
    // MARK: - Private Properties
    
    /// UserDefaults for storing privacy preferences
    private let userDefaults = UserDefaults.standard
    
    /// Keychain service identifier
    private let keychainService = "com.quickjournal.keychain"
    
    /// Encryption key identifier
    private let encryptionKeyIdentifier = "journal_encryption_key"
    
    // MARK: - Constants
    
    /// Keys for UserDefaults storage
    private enum UserDefaultsKeys {
        static let hasUserConsent = "has_user_consent"
        static let hasAcceptedPrivacyPolicy = "has_accepted_privacy_policy"
        static let isEncryptionEnabled = "is_encryption_enabled"
    }
    
    // MARK: - Initialization
    
    /// Initializes the PrivacyManager and loads existing preferences
    init() {
        loadPrivacyPreferences()
    }
    
    // MARK: - Public Methods
    
    /// Requests user consent for data collection
    /// - Returns: True if user consents, false otherwise
    func requestUserConsent() -> Bool {
        // In a real app, this would show a consent dialog
        // For now, we'll assume consent is given for local-only storage
        hasUserConsent = true
        savePrivacyPreferences()
        return true
    }
    
    /// Accepts the privacy policy
    func acceptPrivacyPolicy() {
        hasAcceptedPrivacyPolicy = true
        savePrivacyPreferences()
    }
    
    /// Encrypts a string using AES encryption
    /// - Parameter text: The text to encrypt
    /// - Returns: Encrypted data or nil if encryption fails
    func encryptText(_ text: String) -> Data? {
        guard isEncryptionEnabled else { return text.data(using: .utf8) }
        
        do {
            let key = try getOrCreateEncryptionKey()
            let data = text.data(using: .utf8)!
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined
        } catch {
            print("Encryption failed: \(error)")
            return nil
        }
    }
    
    /// Decrypts data using AES decryption
    /// - Parameter encryptedData: The encrypted data
    /// - Returns: Decrypted string or nil if decryption fails
    func decryptText(_ encryptedData: Data) -> String? {
        guard isEncryptionEnabled else { return String(data: encryptedData, encoding: .utf8) }
        
        do {
            let key = try getOrCreateEncryptionKey()
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption failed: \(error)")
            return nil
        }
    }
    
    /// Generates a secure encryption key
    /// - Returns: A symmetric encryption key
    private func getOrCreateEncryptionKey() throws -> SymmetricKey {
        // Try to retrieve existing key from Keychain
        if let existingKeyData = retrieveKeyFromKeychain() {
            return SymmetricKey(data: existingKeyData)
        }
        
        // Generate new key
        let newKey = SymmetricKey(size: .bits256)
        let keyData = newKey.withUnsafeBytes { Data($0) }
        
        // Store in Keychain
        try storeKeyInKeychain(keyData)
        
        return newKey
    }
    
    /// Stores encryption key in Keychain
    /// - Parameter keyData: The key data to store
    private func storeKeyInKeychain(_ keyData: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: encryptionKeyIdentifier,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw PrivacyError.keychainStoreFailed
        }
    }
    
    /// Retrieves encryption key from Keychain
    /// - Returns: The key data or nil if not found
    private func retrieveKeyFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: encryptionKeyIdentifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            return nil
        }
        
        return result as? Data
    }
    
    /// Saves privacy preferences to UserDefaults
    private func savePrivacyPreferences() {
        userDefaults.set(hasUserConsent, forKey: UserDefaultsKeys.hasUserConsent)
        userDefaults.set(hasAcceptedPrivacyPolicy, forKey: UserDefaultsKeys.hasAcceptedPrivacyPolicy)
        userDefaults.set(isEncryptionEnabled, forKey: UserDefaultsKeys.isEncryptionEnabled)
    }
    
    /// Loads privacy preferences from UserDefaults
    private func loadPrivacyPreferences() {
        hasUserConsent = userDefaults.bool(forKey: UserDefaultsKeys.hasUserConsent)
        hasAcceptedPrivacyPolicy = userDefaults.bool(forKey: UserDefaultsKeys.hasAcceptedPrivacyPolicy)
        isEncryptionEnabled = userDefaults.object(forKey: UserDefaultsKeys.isEncryptionEnabled) as? Bool ?? true
    }
    
    /// Resets all privacy preferences (for testing or user request)
    func resetPrivacyPreferences() {
        hasUserConsent = false
        hasAcceptedPrivacyPolicy = false
        isEncryptionEnabled = true
        savePrivacyPreferences()
        
        // Remove encryption key from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: encryptionKeyIdentifier
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Privacy Errors

/// Errors that can occur during privacy operations
enum PrivacyError: Error, LocalizedError {
    case keychainStoreFailed
    case keychainRetrieveFailed
    case encryptionFailed
    case decryptionFailed
    
    var errorDescription: String? {
        switch self {
        case .keychainStoreFailed:
            return "Failed to store encryption key in Keychain"
        case .keychainRetrieveFailed:
            return "Failed to retrieve encryption key from Keychain"
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        }
    }
}
