//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

/// Unique identifier for the ``AccessGuardConfiguration``.
///
/// It is recommended you use reverse DNS notation for these identifiers, in order to reduce the risk of collisions.
/// Furthermore, the underlying raw values used for these should be stable, since they will in some cases be persisted across app launches.
///
/// Example:
///
/// ```swift
/// extension AccessGuardIdentifier {
///     static let accountView = Self("com.myApp.accountView")
/// }
/// ```
public struct AccessGuardIdentifier: Hashable, Sendable {
    let value: String
    
    /// Creates a new access guard
    public init(_ value: String) {
        self.value = value
    }
}
