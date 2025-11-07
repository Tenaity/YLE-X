//
//  AppleSignInHelper.swift
//  YLE X
//
//  Helper utilities for Apple Sign-In with Firebase
//  Provides cryptographically secure nonce generation and SHA256 hashing
//

import Foundation
import CryptoKit
import Security

// MARK: - Apple Sign-In Utilities
public enum AppleSignInHelper {
    /// Generate a cryptographically secure random nonce string
    /// - Parameter length: Length of nonce string (default: 32)
    /// - Returns: Random nonce string safe for Apple Sign-In
    public static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    /// SHA256 hash a nonce string
    /// Used to create hashed nonce for Apple Sign-In request
    /// - Parameter input: Unhashed nonce string
    /// - Returns: SHA256 hashed hex string
    public static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}
