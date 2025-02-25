//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziAccessGuard
import SwiftUI


struct ContentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AccessGuard.self) private var accessGuard

    // swiftlint:disable closure_body_length
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Access Guarded") {
                    AccessGuarded(.test) {
                        Color.green
                            .overlay {
                                Text("Secured ...")
                            }
                    }
                }
                NavigationLink("Access Guarded Fixed") {
                    AccessGuarded(.testFixed) {
                        Color.green
                            .overlay {
                                Text("Secured with fixed code ...")
                            }
                    }
                }
                NavigationLink("Access Guarded Biometrics") {
                    AccessGuarded(.testBiometrics) {
                        Color.green
                            .overlay {
                                Text("Secured with biometrics ...")
                            }
                    }
                }
                NavigationLink("Set Code") {
                    SetAccessGuard(identifier: .test)
                }
                NavigationLink("Set Biometric Backup Code") {
                    SetAccessGuard(identifier: .testBiometrics)
                }
                NavigationLink("Access Guard Button") {
                    AccessGuardButton(.testFixed) {
                        Text("Unlock me")
                    } unlocked: {
                        Text("Success")
                    }
                }
            }
                .toolbar {
                    ToolbarItem {
                        Button("Lock Access Guards") {
                            Task {
                                let identifiers: [AccessGuardIdentifier] = [.test, .testFixed, .testBiometrics]
                                for identifier in identifiers {
                                    await accessGuard.lock(identifier: identifier)
                                }
                            }
                        }
                    }
                    ToolbarItem {
                        Button("Reset Access Guards") {
                            let identifiers: [AccessGuardIdentifier] = [.test, .testBiometrics]
                            for identifier in identifiers {
                                try? accessGuard.resetAccessCode(for: identifier)
                            }
                        }
                    }
                }
        }
    }
}
