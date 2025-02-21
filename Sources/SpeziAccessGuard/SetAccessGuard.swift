//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziKeychainStorage
import SwiftUI


/// Allows a user to set a code for a ``AccessGuarded`` view.
public struct SetAccessGuard: View {
    @Environment(AccessGuard.self) private var accessGuard
    
    private let identifier: AccessGuardIdentifier
    private let action: @MainActor () async -> Void
    
    
    public var body: some View {
        SetCodeView(viewModel: accessGuard.viewModel(for: identifier), action: action)
    }
    
    
    /// - Parameters:
    ///   - identifier: The identifier of the access guard configuration that should be used to guard this view.
    ///   - action: An action that should be performed once the password has been set.
    public init(
        identifier: AccessGuardIdentifier,
        action: @escaping @MainActor () async -> Void = {}
    ) {
        self.identifier = identifier
        self.action = action
    }
}
