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
        VStack {
            Image(Asset.usernameHeader.name)
            Text(L10n.Login.whatCallYou)
                .scaledFont(size: 22, weight: .bold)
                .foregroundColor(.white)
            LoginTextInput(placeholder: L10n.username, prefix: "@", icon: EmptyView(), isValid: viewModel.usernameValid, text: $viewModel.username)
                .onChange(of: viewModel.username) { _ in
                    viewModel.verifyUsername()
                }
            Text(L10n.Login.usernameDescription)
                .multilineTextAlignment(.center)
                .scaledFont(size: 15, weight: .semibold)
                .foregroundColor(.purple600)
                .padding(.top, 8)
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
                Text(L10n.Login.termsText)
                    .scaledFont(size: 13)
                    .foregroundColor(.purple600)
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
            .background(Color.purple300.ignoresSafeArea())
    }
}

#Preview("Initial") {
    UsernameScreen()
}
