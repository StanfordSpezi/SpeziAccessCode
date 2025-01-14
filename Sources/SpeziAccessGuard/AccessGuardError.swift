//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum AccessGuardError: LocalizedError {
    case wrongPasscode
    case storeCodeError
    case biometricsNotAvailable
    case invalidCodeFormatOnlyNumericAllowed
    case invalidCodeLength
    case invalidMinimumCodeLength
    
    
    var errorDescription: String {
        String(localized: "ACCESS_GUARD_ERROR_TITLE", bundle: .module)
    }
    
    var failureReason: String {
        switch self {
        case .wrongPasscode:
            return String(localized: "ACCESS_GUARD_ERROR_WRONG_PASSCODE_REASON", bundle: .module)
        case .storeCodeError:
            return String(localized: "ACCESS_GUARD_ERROR_STORE_CODE_ERROR_REASON", bundle: .module)
        case .biometricsNotAvailable:
            return String(localized: "ACCESS_GUARD_ERROR_BIOMETRICS_NOT_AVAILABLE", bundle: .module)
        case .invalidCodeFormatOnlyNumericAllowed:
            return String(localized: "ACCESS_GUARD_ERROR_INVALID_CODE_FORMAT_ONLY_NUMERIC_ALLOWED", bundle: .module)
        case .invalidCodeLength:
            return String(localized: "ACCESS_GUARD_ERROR_INVALID_CODE_LENGTH", bundle: .module)
        case .invalidMinimumCodeLength:
            return String(localized: "ACCESS_GUARD_ERROR_INVALID_CODE_LENGTH_TOO_SHORT", bundle: .module)
        }
    }
}
