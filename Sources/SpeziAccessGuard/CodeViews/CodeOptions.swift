//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import UIKit


/// An [option set](https://developer.apple.com/documentation/swift/optionset) of access code options.
public struct CodeOptions: OptionSet, Codable, CaseIterable, Identifiable {
    public static var allCases: [CodeOptions] = [
        .fourDigitNumeric,
        .sixDigitNumeric,
        .customNumeric,
        .customAlphanumeric
    ]
    
    /// A four digit numeric code.
    public static let fourDigitNumeric = CodeOptions(rawValue: 1 << 0)
    
    /// A six digit numeric code.
    public static let sixDigitNumeric = CodeOptions(rawValue: 1 << 1)
    
    /// A numeric code with at least four digits in length.
    public static let customNumeric = CodeOptions(rawValue: 1 << 2)
    
    /// A alphanumeric code with at least four characters in length.
    public static let customAlphanumeric = CodeOptions(rawValue: 1 << 3)
    
    /// A finite numeric code.
    public static let finiteNumeric: CodeOptions = [.fourDigitNumeric, .sixDigitNumeric]
    
    /// A numeric code.
    public static let numeric: CodeOptions = [.fourDigitNumeric, .sixDigitNumeric, .customNumeric]
    
    /// A numeric or alphanumeric code.
    public static let all: CodeOptions = [.fourDigitNumeric, .sixDigitNumeric, .customNumeric, .customAlphanumeric]
    
    
    @_documentation(visibility: internal) public var id: Int {
        rawValue
    }
    
    var maxLength: Int {
        if self.contains(CodeOptions.customNumeric) || self.contains(CodeOptions.customAlphanumeric) {
            return Int.max
        } else if self.contains(CodeOptions.sixDigitNumeric) {
            return 6
        } else if self.contains(CodeOptions.fourDigitNumeric) {
            return 4
        }
        
        return Int.max
    }
    
    var description: LocalizedStringResource {
        switch self {
        case .fourDigitNumeric:
            return LocalizedStringResource("CODE_OPTIONS_FOUR_DIGIT", bundle: .atURL(from: .module))
        case .sixDigitNumeric:
            return LocalizedStringResource("CODE_OPTIONS_SIX_DIGIT", bundle: .atURL(from: .module))
        case .customNumeric:
            return LocalizedStringResource("CODE_OPTIONS_CUSTOM_NUMERIC_DIGIT", bundle: .atURL(from: .module))
        case .customAlphanumeric:
            return LocalizedStringResource("CODE_OPTIONS_CUSTOM_ALPHANUMERIC_DIGIT", bundle: .atURL(from: .module))
        default:
            return LocalizedStringResource("CODE_OPTIONS_UNKNOWN", bundle: .atURL(from: .module))
        }
    }
    
    var keyBoardType: UIKeyboardType {
        if self == .customAlphanumeric {
            return .default
        } else {
            return .numberPad
        }
    }
    
    @_documentation(visibility: internal) public let rawValue: Int
    
    
    /// Raw initializer for the ``CodeOptions`` option set. Do not use this initializer.
    /// - Parameter rawValue: The raw option set value.
    @_documentation(visibility: internal)
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Verifies that the code is only digits for numeric code types
    private func verifyOnlyDigits(ofCode code: String) -> Bool {
        if (self == .fourDigitNumeric || self == .sixDigitNumeric || self == .customNumeric) {
            return code.isNumeric
        }
        return true
    }
    
    /// Verifies that the code has the correct length
    private func verifyCodeLength(ofCode code: String) -> Bool {
        switch self {
            case .customNumeric, .customAlphanumeric:
                return code.count >= CodeOptions.fourDigitNumeric.maxLength
            case .fourDigitNumeric, .sixDigitNumeric:
                return code.count == self.maxLength
            default:
                return false
        }
    }
    
    ///Performs all possible checks on a given code to verify if it is valid
    func verifyStructure(ofCode code: String) -> Bool {
        return verifyOnlyDigits(ofCode: code) && verifyCodeLength(ofCode: code)
    }
    
    /// Check for correct letters and for auto submission while user is typing
    func continousValidation(ofCode code: String) -> ValidationResult {
        if !verifyOnlyDigits(ofCode: code) {
            return .failure(.invalidCodeFormatOnlyNumericAllowed)
        }
        if shouldAutoSubmit(code) {
            return .submit
        }
        return .valid
    }
    
    /// Function is invoked on button press and checks if the length is correct
    func submissionValidation(ofCode code: String) -> ValidationResult {
        if !self.verifyCodeLength(ofCode: code) {
            return .failure(.invalidMinimumCodeLength)
        }
        return .submit
    }

    /// Check if the code is long enough to auto submit
    func shouldAutoSubmit(_ code: String) -> Bool {
        switch self {
        case .fourDigitNumeric, .sixDigitNumeric:
            return code.count == maxLength
        default:
            return false
        }
    }
    
    ///Tells the caller wether the selected code option can submit automatically
    func willAutoSubmit() -> Bool {
        return self == .fourDigitNumeric || self == .sixDigitNumeric
    }
}

enum ValidationResult {
    case none
    case valid
    case submit
    case failure(AccessGuardError)
}
