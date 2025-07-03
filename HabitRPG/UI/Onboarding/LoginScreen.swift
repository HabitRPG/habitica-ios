//
//  LoginScreen.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.07.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models

private enum LoginViewState {
    case initial
    case register
    case login
}

struct LoginScreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .lineLimit(3)
            .foregroundColor(.gray50)
            .multilineTextAlignment(.center)
            .scaledFont(size: 17, weight: .semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .minHeight(60)
            .background(Color.white)
            .cornerRadius(16)
    }
}

struct LoginTextFieldStyle<Icon: View>: TextFieldStyle {
    var icon: Icon
    
    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            configuration
            icon
        }
        .foregroundColor(Color.white)
        .padding(.horizontal, 21)
        .padding(.vertical, 10)
            .minHeight(60)
            .background(.purple100)
            .cornerRadius(16)
    }
}

struct LoginTextInput<Icon: View>: View {
    var placeholder: String
    var icon: Icon
    var isSecure: Bool = false
    
    @Binding fileprivate var text: String
    
    var body: some View {
        if isSecure {
            SecureField(placeholder, text: $text, prompt: Text(placeholder).foregroundColor(.purple500))
                .textFieldStyle(LoginTextFieldStyle(icon: icon))
        } else {
            TextField(placeholder, text: $text, prompt: Text(placeholder).foregroundColor(Color.purple500))
                .textFieldStyle(LoginTextFieldStyle(icon: icon))
        }
    }
}

struct LoginForm: View {
    @Binding fileprivate var viewState: LoginViewState
    
    @Binding var email: String
    @Binding var password: String
    @Binding var repeatPassword: String
    
    let onLogin: () -> Void
    let onAppleLogin: () -> Void
    let onGoogleLogin: () -> Void
    let onPasswordForgot: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                if viewState == .register {
                    viewState = .login
                } else {
                    viewState = .register
                }
            }
        } label: {
            Group {
                if viewState == .register {
                    Text(L10n.Login.alreadyHaveAccount)
                        .foregroundColor(Color.purple600) + Text(" ") + Text(L10n.Login.login)
                        .foregroundColor(Color.white)
                } else {
                    Text(L10n.Login.needAccount)
                        .foregroundColor(Color.purple600) + Text(" ") + Text(L10n.Login.register)
                        .foregroundColor(Color.white)
                }
            }
            .scaledFont(size: 17, weight: .medium)
        }.padding(.bottom, 17)
        LoginTextInput(placeholder: viewState == .register ? L10n.email : L10n.Login.emailUsername, icon: Image(Asset.loginEmail.name), isSecure: false, text: $email)
            .padding(.bottom, 7)
            .submitLabel(.next)
        let passwordField = LoginTextInput(placeholder: L10n.password, icon: Image(Asset.loginPassword.name), isSecure: true, text: $password)
        if viewState != .login {
            passwordField
                .submitLabel(.next)
            LoginTextInput(placeholder: L10n.repeatPassword, icon: Image(Asset.loginPassword.name), isSecure: true, text: $repeatPassword)
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 7)
                .submitLabel(.continue)
                    .onSubmit {
                        onLogin()
                    }
        } else {
            passwordField.submitLabel(.continue)
                .onSubmit {
                    onLogin()
                }
        }
        Button {
            onLogin()
        } label: {
            Text(viewState == .register ? L10n.continue : L10n.Login.login)
        }.buttonStyle(LoginScreenButtonStyle())
            .drawingGroup()
            .padding(.top, 36)
        if viewState != .register {
                Button {
                    onAppleLogin()
                } label: {
                    Label {
                        Text(L10n.Login.continueWithApple)
                    } icon: {
                        Image(Asset.loginApple.name)
                    }
                }.buttonStyle(LoginScreenButtonStyle())
                    .padding(.top, 8)
                Button {
                    onGoogleLogin()
                } label: {
                    Label {
                        Text(L10n.Login.continueWithGoogle)
                    } icon: {
                        Image(Asset.loginGoogle.name)
                    }
                }.buttonStyle(LoginScreenButtonStyle())
                    .padding(.top, 8)
                
                Button {
                    onPasswordForgot()
                } label: {
                    Text(L10n.Login.forgotPassword)
                        .foregroundColor(.white)
                }.padding(.top, 17)
        }
    }
}

struct LoginScreen: View {
    
    init(viewModel: LoginViewModel) {
        self.viewState = .initial
        self.viewModel = viewModel
    }
    
    fileprivate init(initialViewState: LoginViewState = .initial) {
        self.viewState = initialViewState
        self.viewModel = LoginViewModel()
    }
    
    @ObservedObject var viewModel: LoginViewModel
    @State fileprivate var viewState: LoginViewState
    @State var isShowingForm = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                Spacer()
                    .frame(maxHeight: .infinity)
                Color.clear
                    .overlay {
                        Image(Asset.loginBackground.name)
                    }
                    .frame(height: 318)
                LinearGradient(gradient: Gradient(colors: [Color(UIColor("#A995EAFF")), .purple400]))
                    .frame(maxWidth: .infinity)
                    .frame(height: viewState == .initial ? 212 : 0)
            }
            .animation(.bouncy, value: viewState)
            .ignoresSafeArea()
            VStack(spacing: 0) {
                Image(Asset.loginLogo.name)
                    .scaleEffect(x: viewState == .initial ? 1.0 : 0.67, y: viewState == .initial ? 1.0 : 0.67)
                    .padding(.top, viewState == .initial ? 65 : 0)
                if viewState == .initial {
                    Text(L10n.Login.tagline)
                        .scaledFont(size: 26, weight: .bold)
                        .foregroundStyle(Color.purple500)
                        .multilineTextAlignment(.center)
                        .lineLimit(5)
                        .padding(.top, 29)
                } else {
                    LoginForm(viewState: $viewState, email: $viewModel.email, password: $viewModel.password, repeatPassword: $viewModel.repeatPassword, onLogin: {
                        
                    }, onAppleLogin: {
                        viewModel.appleLoginButtonPressed()
                    }, onGoogleLogin: {
                        viewModel.googleLoginButtonPressed()
                    }, onPasswordForgot: {
                        viewModel.viewController?.forgotPasswordButtonPressed()
                    })
                    .animation(.bouncy, value: viewState)
                    .transition(.asymmetric(insertion: .push(from: .top), removal: .push(from: .bottom)).combined(with: .opacity))
                }
                Spacer()
                    .frame(maxHeight: .infinity)
                if viewState == .initial {
                    Group {
                        Button {
                            viewModel.appleLoginButtonPressed()
                        } label: {
                            Label {
                                Text(L10n.Login.continueWithApple)
                            } icon: {
                                Image(Asset.loginApple.name)
                            }
                        }.buttonStyle(LoginScreenButtonStyle())
                        Button {
                            viewModel.googleLoginButtonPressed()
                        } label: {
                            Label {
                                Text(L10n.Login.continueWithGoogle)
                            } icon: {
                                Image(Asset.loginGoogle.name)
                            }
                        }.buttonStyle(LoginScreenButtonStyle())
                            .padding(.top, 8)
                        Button {
                            withAnimation {
                                viewState = .register
                            }
                        } label: {
                            Label {
                                Text(L10n.Login.continueWithEmail)
                            } icon: {
                                Image(Asset.loginEmailInitial.name)
                            }
                        }.buttonStyle(LoginScreenButtonStyle())
                            .padding(.top, 8)
                        Button {
                            withAnimation {
                                viewState = .login
                            }
                        } label: {
                            Group {
                                Text(L10n.Login.alreadyHaveAccount)
                                    .foregroundColor(Color.purple600) + Text(" ") + Text(L10n.Login.login)
                                    .foregroundColor(Color.white)
                            }
                            .scaledFont(size: 17, weight: .medium)
                        }.padding(.top, 17)
                    }
                    .animation(.bouncy, value: viewState)
                    .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                }
            }.padding(.horizontal, 20)
            if viewState != .initial {
                Button {
                    withAnimation {
                        viewState = .initial
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.white)
                        .font(.headline.bold())
                        .padding()
                }
            }

        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Initial") {
    LoginScreen()
        .background(Color.purple300.ignoresSafeArea())
}

#Preview("Register") {
    LoginScreen(initialViewState: .register)
        .background(Color.purple300.ignoresSafeArea())
}

#Preview("Login") {
    LoginScreen(initialViewState: .login)
        .background(Color.purple300.ignoresSafeArea())
}
