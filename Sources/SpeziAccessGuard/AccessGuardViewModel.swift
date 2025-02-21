//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import LocalAuthentication
import Observation
import Spezi
import SpeziKeychainStorage
import SwiftUI


@Observable
final class AccessGuardViewModel {
    private struct AccessCode: Codable {
        let codeOption: CodeOptions
        let code: String
    }
    
    
    let configuration: AccessGuardConfiguration
    private let keychainStorage: KeychainStorage
    
    @MainActor private(set) var locked = true
    @MainActor private var accessCode: AccessCode?
    @MainActor private weak var accessGuard: AccessGuard?
    
    
    @MainActor var setup: Bool {
        accessCode != nil || configuration.fixedCode != nil
    }
    
    @MainActor var codeOption: CodeOptions? {
        if configuration.fixedCode != nil {
            return configuration.codeOptions
        } else {
            return accessCode?.codeOption
        }
    }
    
    
    @MainActor
    init(accessGuard: AccessGuard, keychainStorage: KeychainStorage, configuration: AccessGuardConfiguration) {
        self.configuration = configuration
        self.accessGuard = accessGuard
        self.keychainStorage = keychainStorage
        
        if let credentials = try? keychainStorage.retrieveCredentials(withUsername: configuration.identifier.value, for: .accessGuard),
           let accessCode = try? JSONDecoder().decode(AccessCode.self, from: Data(credentials.password.utf8)),
           accessCode.codeOption.verifyStructure(ofCode: accessCode.code) {
            self.accessCode = accessCode
        } else {
            self.accessCode = nil
        }
        
        self.locked = setup
    }
    
    
    @MainActor
    func didEnterBackground() {}
    
    @MainActor
    func willEnterForeground(lastEnteredBackground: Date) {
        if lastEnteredBackground.addingTimeInterval(configuration.timeout) < .now {
            locked = true
        }
    }
    
    @MainActor
    func authenticateWithBiometrics() async throws {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw AccessGuardError.biometricsNotAvailable
        }

        let success = try await context.evaluatePolicyAsync(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: String(localized: "ACCESS_GUARD_BIOMETRICS_REASON", bundle: .module)
        )

        self.locked = !success
    }
    
    @MainActor
    func resetAccessCode() throws {
        guard configuration.fixedCode == nil else {
            return
        }
        
        do {
            try keychainStorage.deleteCredentials(withUsername: configuration.identifier.value, for: .accessGuard)
            accessCode = nil
            self.locked = setup
        } catch {
            print("Error resetting access code: \(error)")
        }
    }
    
    func checkAccessCode(_ code: String) async throws {
        try await MainActor.run {
            if let fixedCode = configuration.fixedCode, code == fixedCode {
                locked = false
                return
            }
            
            guard code == accessCode?.code else {
                throw AccessGuardError.wrongPasscode
            }
            
            locked = false
        }
    }
    
    func lock() async {
        await MainActor.run {
            locked = true
        }
    }
    
    @MainActor
    func setAccessCode(_ code: String, codeOption: CodeOptions) async throws {
        guard configuration.fixedCode == nil else {
            throw AccessGuardError.storeCodeError
        }
        
        accessCode = AccessCode(codeOption: codeOption, code: code)
        
        guard let accessCodeData = try? String(data: JSONEncoder().encode(accessCode), encoding: .utf8) else {
            throw AccessGuardError.storeCodeError
        }
        
        try keychainStorage.store(
            Credentials(username: configuration.identifier.value, password: accessCodeData),
            for: .accessGuard
        )
        
        // Ensure that the model is in a state as if the user has just entered the access code.
        try await checkAccessCode(code)
    }
}


extension CredentialsTag {
    static let accessGuard = Self.genericPassword(forService: "edu.stanford.spezi.accessGuard")
}
