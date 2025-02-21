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
                    .biometrics(identifier: .testBiometrics),
                    .code(identifier: .test, timeout: 10),
                    .fixed(identifier: .testFixed, code: "1234")
                ]
            )
        }
    }
}


extension AccessGuardIdentifier {
    static let test = Self("edu.stanford.spezi.accessguardtests.1.test")
    static let testFixed = Self("edu.stanford.spezi.accessguardtests.1.testFixed")
    static let testBiometrics = Self("edu.stanford.spezi.accessguardtests.1.testBiometrics")
}
