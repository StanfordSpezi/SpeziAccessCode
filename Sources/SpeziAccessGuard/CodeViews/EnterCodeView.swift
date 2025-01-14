//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct EnterCodeView: View {
    var viewModel: AccessGuardViewModel
    @State private var wrongCodeCounter: Int = 0
    @State private var errorMessage: String?
    @State private var validationRes: ValidationResult = .none
    
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
            VStack(spacing: 32) {
                if let codeOption = viewModel.codeOption {
                    Text("ACCESS_CODE_PASSCODE_PROMPT", bundle: .module)
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                    CodeView(codeOption: codeOption,
                             toolbarButtonLabel: String(localized: "ENTER_PASSCODE_CONFIRM_BUTTON", bundle: .module)) { code, validationRes in
                        
                        switch validationRes {
                            case .valid:
                                errorMessage = nil
                            case .failure(let upstreamError):
                                errorMessage = String(upstreamError.failureReason)
                            default:
                                errorMessage = nil
                                do {
                                    try await viewModel.checkAccessCode(code)
                                } catch {
                                    wrongCodeCounter += 1
                                    let errorMessageTemplate = NSLocalizedString("ACCESS_CODE_PASSCODE_ERROR %@", bundle: .module, comment: "")
                                    errorMessage = String(format: errorMessageTemplate, "\(wrongCodeCounter)")
                                    throw error // throw error to reset code in CodeView
                                }
                        }
                    }
                } else {
                    Text("ACCESS_CODE_NOT_SET", bundle: .module)
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                }
                ErrorMessageCapsule(errorMessage: $errorMessage)
            }
                .padding(.horizontal)
        }
    }
}
