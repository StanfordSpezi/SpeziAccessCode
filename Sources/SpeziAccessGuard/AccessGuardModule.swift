//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Combine
import Spezi
import SpeziKeychainStorage
import SwiftUI


/// Enforces a code or biometrics-based access guard to SwiftUI views.
///
/// > Important: If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/setup) setup the core Spezi infrastructure.
///
/// The module needs to be registered in a Spezi-based application using the [`configuration`](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/speziappdelegate/configuration)
/// in a [`SpeziAppDelegate`](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/speziappdelegate):
/// ```swift
/// class ExampleAppDelegate: SpeziAppDelegate {
///     override var configuration: Configuration {
///         Configuration {
///             AccessGuardModule([
///                 .code(identifier: .exampleAccessGuard)
///             ])
///             // ...
///         }
///     }
/// }
/// ```
/// > Tip: You can learn more about a [`Module` in the Spezi documentation](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/module).
///
///
/// ## Usage
///
/// You can use the ``AccessGuarded`` SwiftUI [`View`](https://developer.apple.com/documentation/swiftui/view) in your SwiftUI application to
/// enforce a code or biometrics-based access guard to SwiftUI views.
public final class AccessGuardModule: Module, DefaultInitializable, LifecycleHandler {
    @Dependency(KeychainStorage.self) private var keychainStorage
    /// Shared ``AccessGuard`` type used to lock, reset, and inspect access control mechanisms.
    @Model public private(set) var accessGuard: AccessGuard
    
    private let configurations: [AccessGuardConfiguration]
    
    
    public convenience init() {
        self.init([])
    }
    
    public init(_ configurations: [AccessGuardConfiguration]) {
        self.configurations = configurations
    }
    
    
    @_documentation(visibility: internal)
    public func configure() {
        accessGuard = AccessGuard(keychainStorage: keychainStorage, configurations)
    }
    
    
    @_documentation(visibility: internal)
    public func sceneDidEnterBackground(_ scene: UIScene) {
        accessGuard.sceneDidEnterBackground(scene)
    }
    
    @_documentation(visibility: internal)
    public func sceneWillEnterForeground(_ scene: UIScene) {
        accessGuard.sceneWillEnterForeground(scene)
    }
}
