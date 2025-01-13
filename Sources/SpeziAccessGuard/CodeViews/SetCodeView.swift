//
// This source file is part of the Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SetCodeView: View {
    enum SetCodeState {
        case oldCode
        case setCode
        case repeatCode
        case success
    }
    
    let action: @MainActor () async -> Void
    
    var viewModel: AccessGuardViewModel
    @State private var selectedCode: CodeOptions = .fourDigitNumeric
    @State private var firstCode: String = ""
    @State private var state: SetCodeState = .oldCode
    @State private var errorMessage: String?
    @State private var upstreamError: String?
    @State private var validationRes: ValidationResult = .none
    @State private var shouldSubmit: Bool = false
    
    
    private var codeOptions: [CodeOptions] {
        CodeOptions.allCases.filter { codeOption in
            viewModel.configuration.codeOptions.contains(codeOption)
        }
    }
    
    
    var body: some View {
        switch state {
        case .oldCode:
            EnterCodeView(viewModel: viewModel)
                .onChange(of: viewModel.locked) {
                    print("viewModel.locked status change: \($0)")
                    // problem: if the user is already unlocked, the view will not change to .setCode
                    if !viewModel.locked {
                        withAnimation {
                            state = .setCode
                        }
                    }
                }
                .task {
                    if !viewModel.setup {
                        state = .setCode
                    }
                }
                .transition(.opacity)
        case .setCode:
            VStack(spacing: 32) {
                Text("SET_PASSCODE_PROMPT", bundle: .module)
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                CodeView(codeOption: $selectedCode,
                         toolbarButtonLabel: String(localized: "SET_PASSCODE_NEXT_BUTTON", bundle: .module)) {
                    code, validationRes, shouldSubmit in
                    
                    if shouldSubmit {
                        firstCode = code
                        print(".setCode firstCode: \(firstCode)")
                        withAnimation {
                            state = .repeatCode
                        }
                    } else {
                        print("Code: \(code) Validation: \(validationRes) ShouldSubmit: \(shouldSubmit)")
                        switch validationRes {
                        case .failure(let upstreamError):
                            errorMessage = String(upstreamError.failureReason)
                        default:
                            errorMessage = nil
                        }
                    }
                }
                VStack {
                    ErrorMessageCapsule(errorMessage: $errorMessage)
                    if codeOptions.count > 1 {
                        Menu(selectedCode.description.localizedString()) {
                            ForEach(codeOptions) { codeOption in
                                Button(codeOption.description.localizedString()) {
                                    selectedCode = codeOption
                                }
                            }
                        }
                    } else {
                        Rectangle()
                            .foregroundStyle(.clear)
                    }
                }
                    .frame(height: 80)
            }
            .transition(.opacity)
        case .repeatCode:
            VStack(spacing: 32) {
                Text("SET_PASSCODE_REPEAT_PROMPT", bundle: .module)
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                CodeView(codeOption: $selectedCode,
                         toolbarButtonLabel: String(localized: "SET_PASSCODE_CONFIRM_BUTTON", bundle: .module)) { code, validationRes, shouldSubmit in
                    
                    if shouldSubmit {
                        if code == firstCode {
                            do {
                                try await viewModel.setAccessCode(code, codeOption: selectedCode)
                                errorMessage = nil
                                await action()
                                try await Task.sleep(for: .seconds(0.2))
                                withAnimation {
                                    state = .success
                                }
                            } catch let error as AccessGuardError {
                                errorMessage = error.failureReason
                            }
                        } else {
                            errorMessage = String(localized: "SET_PASSCODE_REPEAT_NOT_EQUAL", bundle: .module)
                        }
                    } else {
                        switch validationRes {
                        case .failure(let upstreamError):
                            errorMessage = String(upstreamError.failureReason)
                        default:
                            errorMessage = nil
                            
                        }
                    }
                }
                VStack {
                    ErrorMessageCapsule(errorMessage: $errorMessage)
                    Button(
                        action: {
                            withAnimation {
                                state = .setCode
                                firstCode = ""
                                errorMessage = nil
                            }
                        }, label: {
                            Text("SET_PASSCODE_BACK_BUTTON", bundle: .module)
                        }
                    )
                }
                .frame(height: 80)
            }
            .transition(.opacity)
            .navigationBarBackButtonHidden()
            
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
                .frame(height: 100)
                .foregroundStyle(.green)
                .transition(.slide)
                .accessibilityLabel(Text("PASSCODE_SET_SUCCESS", bundle: .module))
        }
    }
    
    init(viewModel: AccessGuardViewModel, action: @MainActor @escaping () async -> Void) {
        self.viewModel = viewModel
        self.action = action
    }
}
