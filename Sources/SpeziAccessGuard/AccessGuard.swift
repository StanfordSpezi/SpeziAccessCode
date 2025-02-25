//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Observation
import Spezi
import SpeziKeychainStorage
import SwiftUI


/// Provides access to manage, lock, and reset and access guard from Swift UI views.
///
/// The ``AccessGuard`` is injected in the SwiftUI environment and can be accessed using the [`@Environment`](https://developer.apple.com/documentation/swiftui/environment) property wrapper.
///
/// ### Locking an Access Guard
///
/// The access guard will lock automatically when it times out. However, we can also lock an access guard directly using the ``AccessGuard/lock(identifier:)`` method. Here, we add a toolbar item with a button that will lock the access guard.
/// 
/// ```swift
/// struct ProtectedContent: View {
///     @Environment(AccessGuard.self) private var accessGuard
///     
///     var body: some View {
///         AccessGuarded(.myAccessGuard) {
///             Text("Secured content...")
///         }
///         .toolbar {
///             ToolbarItem {
///                 Button("Lock Access Guard") {
///                     try? accessGuard.lock(identifier: .myAccessGuard)
///                 }
///             }
///         }
///     }
/// }
///
/// extension AccessGuardIdentifier {
///     static let myAccessGuard = Self("edu.stanford.spezi.myAccessGuard")
/// }
/// ```
/// 
/// ### Resetting an Access Guard
/// 
/// To remove the access code and all information from an access guard, we can use the ``AccessGuard/resetAccessCode(for:)`` method. Here, we add a toolbar item with a button that will lock the access guard.
/// 
/// ```swift
/// struct ProtectedContent: View {
///     @Environment(AccessGuard.self) private var accessGuard
///     
///     var body: some View {
///         AccessGuarded(.myAccessGuard) {
///             Text("Secured content...")
///         }
///         .toolbar {
///             ToolbarItem {
///                 Button("Reset Access Guard") {
///                     try? accessGuard.resetAccessCode(for: .myAccessGuard)
///                 }
///             }
///         }
///     }
/// }
/// ```
@Observable
public final class AccessGuard {
    private let keychainStorage: KeychainStorage
    
    private(set) var inTheBackground = true
    private(set) var lastEnteredBackground: Date = .now
    private let configurations: [AccessGuardConfiguration]
    private var viewModels: [AccessGuardIdentifier: AccessGuardViewModel] = [:]
    
    
    init(keychainStorage: KeychainStorage, _ configurations: [AccessGuardConfiguration]) {
        self.keychainStorage = keychainStorage
        self.configurations = configurations
    }
    
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        Task { @MainActor in
            inTheBackground = true
            lastEnteredBackground = .now
            
            for viewModel in viewModels.values {
                viewModel.didEnterBackground()
            }
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        Task { @MainActor in
            inTheBackground = false
            
            for viewModel in viewModels.values {
                viewModel.willEnterForeground(lastEnteredBackground: lastEnteredBackground)
            }
        }
    }
    
    
    /// Resets the access guard for an identifier.
    ///
    /// The function removes the code and all stored information.
    /// - Parameter identifier: The identifier of the access guard.
    @MainActor
    public func resetAccessCode(for identifier: AccessGuardIdentifier) throws {
        try viewModel(for: identifier).resetAccessCode()
    }
    
    /// Determine the setup state of an access lock.
    ///
    /// Use the ``SetAccessGuard`` view to setup an access guard.
    /// - Parameter identifier: The identifier of the access guard.
    /// - Returns: Returns `true` of the access guard is successfully setup. False if no access guard is setup.
    @MainActor
    public func setupComplete(for identifier: AccessGuardIdentifier) -> Bool {
        viewModel(for: identifier).setup
    }
    
    /// Locks an access guard.
    /// - Parameter identifier: The identifier of the access guard that should be locked.
    @MainActor
    public func lock(identifier: AccessGuardIdentifier) async {
        await viewModel(for: identifier).lock()
    }
    
    /// Checks is the `AccessGuard` associated with the given identifier is currently locked.
    @MainActor
    public func isLocked(identifier: AccessGuardIdentifier) -> Bool {
        viewModel(for: identifier).locked
    }
    
    @MainActor
    func viewModel(for identifier: AccessGuardIdentifier) -> AccessGuardViewModel {
        guard let configuration = configurations.first(where: { $0.identifier == identifier }) else {
            preconditionFailure(
            """
            Did not find a AccessGuardConfiguration with the identifier `\(identifier)`.
            
            Please ensure that you have defined an AccessGuardConfiguration with the identifier in your `AccessGuard` configuration.
            """
            )
        }
        
        guard let viewModel = viewModels[identifier] else {
            let viewModel = AccessGuardViewModel(accessGuard: self, keychainStorage: keychainStorage, configuration: configuration)
            viewModels[identifier] = viewModel
            return viewModel
        }
        
        return viewModel
    }
}
