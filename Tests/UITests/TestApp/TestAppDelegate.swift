//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziAccessGuard
import SwiftUI


class TestAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration {
            AccessGuardModule(
                [
                    .biometrics(identifier: "TestBiometricsIdentifier"),
                    .code(identifier: "TestIdentifier",
                          codeOptions: [.all],
                          timeout: 10),
                    .fixed(identifier: "TestFixedIdentifier", code: "1234")
                ]
            )
        }
    }
}
