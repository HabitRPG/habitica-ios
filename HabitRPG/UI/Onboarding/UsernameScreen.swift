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

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
    
    fileprivate init() {
        self.viewModel = LoginViewModel()
    }
    
    public var body: some View {
        let canSubmit = viewModel.acceptedTerms && viewModel.usernameValid == true
        ZStack(alignment: .topLeading) {
            VStack {
                Image(Asset.usernameHeader.name)
                Text(L10n.Login.whatCallYou)
                    .scaledFont(size: 22, weight: .bold)
                    .foregroundColor(.white)
                Text(L10n.Login.usernameDescription)
                    .multilineTextAlignment(.center)
                    .scaledFont(size: 15, weight: .semibold)
                    .foregroundColor(.purple600)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)
                LoginTextInput(placeholder: L10n.username, prefix: "@", icon: EmptyView(), isValid: viewModel.usernameValid, text: $viewModel.username)
                    .onChange(of: viewModel.username) { _ in
                        if viewModel.username.count >= 3 {
                            viewModel.verifyUsername()
                        } else {
                            viewModel.usernameValid = nil
                        }
                    }
                ForEach(viewModel.usernameIssues, id: \.self) { issue in
                    Text(issue)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red100)
                        .scaledFont(size: 15, weight: .semibold)
                        .padding(.bottom, 4)
                        .padding(.horizontal, 16)
                        .transition(.push(from: .top))
                }
                Spacer().frame(maxHeight: .infinity)
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
                    Text((try? AttributedString(markdown: L10n.Login.termsText)) ?? AttributedString(""))
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
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 44)
                .padding(.bottom, 13)
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
