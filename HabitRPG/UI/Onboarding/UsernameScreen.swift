//
//  UsernameScreen.swift
//  Habitica
//
//  Created by Phillip Thelen on 15.07.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

public struct UsernameScreen: View {
    @ObservedObject var viewModel: LoginViewModel
    @FocusState private var isFocused: Bool
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
    
    fileprivate init() {
        self.viewModel = LoginViewModel()
    }
    
    private var formattedTermsText: AttributedString {
        var result = (try? AttributedString(markdown: L10n.Login.termsText)) ?? AttributedString("")
        if let linkRange = result.range(of: L10n.termsOfService) {
            result[linkRange].underlineStyle = Text.LineStyle(pattern: .solid)
        }
        if let linkRange = result.range(of: L10n.privacyPolicy) {
            result[linkRange].underlineStyle = Text.LineStyle(pattern: .solid)
        }
        
        return result
    }
    
    public var body: some View {
        let canSubmit = viewModel.acceptedTerms && viewModel.usernameValid == true
        ZStack(alignment: .topLeading) {
                VStack {
                    ScrollView {
                        VStack(spacing: 0) {
                            Image(Asset.usernameHeader.name)
                            Text(L10n.Login.whatCallYou)
                                .scaledFont(size: 22, weight: .bold)
                                .foregroundColor(.white)
                            Text(L10n.Login.usernameDescription)
                                .multilineTextAlignment(.center)
                                .scaledFont(size: 15, weight: .semibold)
                                .foregroundColor(.purple600)
                                .padding(.horizontal, 16)
                                .padding(.top, 5)
                                .padding(.bottom, 16)
                            LoginTextInput(placeholder: L10n.username, prefix: "@", icon: EmptyView(), isValid: viewModel.usernameValid, text: $viewModel.username)
                                .focused($isFocused)
                                .onChange(of: viewModel.username) { _ in
                                    viewModel.verifyUsername()
                                }
                            VStack(spacing: 4) {
                                ForEach(viewModel.usernameIssues, id: \.self) { issue in
                                    Text(issue)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.red500)
                                        .scaledFont(size: 15, weight: .semibold)
                                        .padding(.horizontal, 30)
                                        .transition(.push(from: .top))
                                }
                            }.padding(.top, 5)
                                .padding(.bottom, 4)
                        }
                        .padding(.top, isFocused ? 0 : 44)
                        .animation(.easeInOut, value: isFocused)
                    }.frame(maxHeight: .infinity)
                    HStack {
                        ZStack {
                            if viewModel.acceptedTerms {
                                Image(Asset.checkmark.name)
                            } else {
                                EmptyView()
                            }
                        }.frame(width: 30, height: 30)
                            .background(.purple100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.trailing, 6)
                        Text(formattedTermsText)
                            .scaledFont(size: 13)
                            .lineSpacing(4)
                            .foregroundColor(.purple600)
                            .tint(.white)
                    }
                    .onTapGesture {
                        viewModel.acceptedTerms.toggle()
                    }
                    .padding(.bottom, 13)
                    Button {
                        viewModel.completeRegistration()
                    } label: {
                        Text(L10n.joinHabitica)
                    }.buttonStyle(LoginScreenButtonStyle())
                        .opacity(canSubmit ? 1 : 0.5)
                        .disabled(!canSubmit)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 13)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.purple300.ignoresSafeArea())
            Button {
                withAnimation {
                    viewModel.showUsernameView = false
                }
            } label: {
                Image(systemName: "chevron.backward")
                    .foregroundColor(.white)
                    .font(.headline.bold())
                    .padding()
            }
        }
    }
}

#Preview("Initial") {
    UsernameScreen()
}
