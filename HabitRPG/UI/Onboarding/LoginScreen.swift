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
            .foregroundStyle(.gray50)
            .multilineTextAlignment(.center)
            .scaledFont(size: 17, weight: .semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .minHeight(60)
            .background(Color.white)
            .cornerRadius(UIConstants.largeCornerRadius)
    }
}

struct LoginTextFieldStyle<Icon: View>: TextFieldStyle {
    var prefix: String?
    var icon: Icon
    var isValid: Bool?
    var showError: Bool = false
    
    // swiftlint:disable:next identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        let field = HStack {
            if let prefix = prefix {
                Text(prefix)
                    .scaledFont(size: 17)
                    .foregroundStyle(.purple500)
                    .padding(.trailing, 6)
            }
            configuration
            if isValid == true {
                Image(Asset.checkmarkSmall.name)
                    .foregroundStyle(.green100)
            } else if showError {
                Image(Asset.close.name)
                    .foregroundStyle(.red100)
            }
            icon
        }
        .foregroundStyle(Color.white)
        .padding(.horizontal, 21)
        .padding(.vertical, 10)
        .minHeight(60)
        
        if #available(iOS 26.0, *) {
            field.glassEffect(.regular.tint(.purple100), in: .capsule)
        } else {
            field
            .background(.purple100)
            .cornerRadius(UIConstants.largeCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .circular)
                    .stroke(Color.red100, lineWidth: showError ? 1:0)
                    .animation(.easeInOut, value: showError)
                    .scaleEffect(1)
            )
            .animation(.easeInOut, value: isValid)
        }
    }
}

struct LoginTextInput<Icon: View>: View {
    var placeholder: String
    var prefix: String?
    var icon: Icon
    var isSecure: Bool = false
    var isValid: Bool?
    var errorMessage: String?
    
    @Binding var text: String

    @FocusState private var isFocused: Bool
    
    @State private var lastFocusChange = Date()
    @State private var lastInputChange = Date()

    var body: some View {
        VStack {
            let showError = isValid == false && (!isFocused || (isFocused && lastFocusChange > lastInputChange))
            if isSecure {
                SecureField(placeholder, text: $text, prompt: Text(placeholder).foregroundColor(.purple500))
                    .textFieldStyle(LoginTextFieldStyle(prefix: prefix, icon: icon, isValid: isValid, showError: showError))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .onTapGesture {
                        isFocused = true
                    }
            } else {
                TextField(placeholder, text: $text, prompt: Text(placeholder).foregroundColor(.purple500))
                    .textFieldStyle(LoginTextFieldStyle(prefix: prefix, icon: icon, isValid: isValid, showError: showError))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .onTapGesture {
                        isFocused = true
                    }
            }
            if showError, let message = errorMessage {
                Text(message)
                    .scaledFont(size: 15, weight: .semibold)
                    .padding(.bottom, 6)
                    .foregroundStyle(.red500)
            }
        }.onChange(of: isFocused) { _ in
            lastFocusChange = Date()
        }.onChange(of: text) { _ in
            lastInputChange = Date()
        }
    }
}

struct LoginForm: View {
    @Binding fileprivate var viewState: LoginViewState
    
    @Binding var email: String
    @Binding var password: String
    @Binding var repeatPassword: String
    var showLoadingIndicator: Bool
    
    let onLogin: () -> Void
    let onAppleLogin: () -> Void
    let onGoogleLogin: () -> Void
    let onPasswordForgot: () -> Void
    
    var body: some View {
        let isEmailValid = email.isEmpty ? nil : email.isValidEmail()
        let isPasswordValid = password.isEmpty ? nil : password.count >= 8
        let isPasswordRepeatValid = repeatPassword.isEmpty ? nil : repeatPassword == password
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
        LoginTextInput(placeholder: viewState == .register ? L10n.email : L10n.Login.emailUsername,
                       icon: Image(Asset.loginEmail.name),
                       isValid: viewState == .login ? nil : isEmailValid,
                       text: $email)
            .padding(.bottom, 7)
            .submitLabel(.next)
            .keyboardType(.emailAddress)
        let passwordField = LoginTextInput(placeholder: L10n.password,
                                           icon: Image(Asset.loginPassword.name),
                                           isSecure: true,
                                           isValid: viewState == .login ? nil : isPasswordValid,
                                           errorMessage: viewState == .register && password.count < 8 ? L10n.Login.passwordLengthError : nil,
                                           text: $password)
        if viewState != .login {
            passwordField
                .submitLabel(.next)
            LoginTextInput(placeholder: L10n.repeatPassword,
                           icon: Image(Asset.loginPassword.name),
                           isSecure: true,
                           isValid: isPasswordRepeatValid,
                           errorMessage: isPasswordRepeatValid == false ? L10n.Login.passwordConfirmError : nil,
                           text: $repeatPassword)
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
        if showLoadingIndicator {
            HabiticaProgressView()
                .padding(.top, 40)
                .padding(.bottom, 12)
        } else {
            let isFormValid = viewState == .login ? !email.isEmpty && isPasswordValid == true
                : isEmailValid == true && isPasswordValid == true && isPasswordRepeatValid == true
            LoginButton {
                onLogin()
            } label: {
                Text(viewState == .register ? L10n.continue : L10n.Login.login)
            }
                .padding(.top, 36)
                .opacity(isFormValid ? 1 : 0.5)
                .disabled(!isFormValid)
        }
        if viewState != .register {
            LoginButton {
                onAppleLogin()
            } label: {
                Label {
                    Text(L10n.Login.continueWithApple)
                } icon: {
                    Image(Asset.loginApple.name)
                }
            }
                .padding(.top, 8)
            LoginButton {
                onGoogleLogin()
            } label: {
                Label {
                    Text(L10n.Login.continueWithGoogle)
                } icon: {
                    Image(Asset.loginGoogle.name)
                }
            }
                .padding(.top, 8)
            
            Button {
                onPasswordForgot()
            } label: {
                Text(L10n.Login.forgotPassword)
                    .foregroundStyle(.white)
            }.padding(.top, 17)
        }
    }
}

struct LoginButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: Label
    
    var body: some View {
        let button = Button(action: {
            action()
        }, label: label
            .foregroundStyle(.gray50)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44))
        
        if #available(iOS 26.0, *) {
            button
                .buttonStyle(.glass(.clear.tint(.white.opacity(0.7))))
        } else {
            button.buttonStyle(LoginScreenButtonStyle())
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
    
    @AppStorage("chosenServer")
    var chosenServer: String = "production"
    
    var body: some View {
        let isSmallDevice = UIApplication.shared.firstKeyWindow?.frame.height ?? 812 < 896
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                Spacer()
                    .frame(maxHeight: .infinity)
                Color.clear
                    .overlay {
                        Image(Asset.loginBackground.name)
                    }
                    .frame(height: 318)
                LinearGradient(gradient: Gradient(colors: [Color(hexadecimal: "#A995EAFF"), .purple400]))
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
                        .foregroundStyle(isSmallDevice ? .white : .purple500)
                        .multilineTextAlignment(.center)
                        .shadow(color: Color(hexadecimal: "#36205D"), x: 0, y: 0, blur: 4)
                        .lineLimit(5)
                        .padding(.top, 29)
                    Spacer()
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            LoginForm(viewState: $viewState,
                                      email: $viewModel.email,
                                      password: $viewModel.password,
                                      repeatPassword: $viewModel.repeatPassword,
                                      showLoadingIndicator: viewModel.showLoadingIndicator,
                                      onLogin: {
                                if viewState == .register {
                                    viewModel.beginRegistration()
                                } else {
                                    viewModel.login()
                                }
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
                    }
                    .frame(maxHeight: .infinity)
                }
                if viewState == .initial {
                    Group {
                        LoginButton {
                            viewModel.appleLoginButtonPressed()
                        } label: {
                            Label {
                                Text(L10n.Login.continueWithApple)
                            } icon: {
                                Image(Asset.loginApple.name)
                            }
                        }
                        LoginButton {
                            viewModel.googleLoginButtonPressed()
                        } label: {
                            Label {
                                Text(L10n.Login.continueWithGoogle)
                            } icon: {
                                Image(Asset.loginGoogle.name)
                            }
                        }
                            .padding(.top, 8)
                        LoginButton {
                            withAnimation {
                                viewState = .register
                            }
                        } label: {
                            Label {
                                Text(L10n.Login.continueWithEmail)
                            } icon: {
                                Image(Asset.loginEmailInitial.name)
                            }
                        }
                            .padding(.top, 8)
                        
                        let loginButton = Button {
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
                        
                        if UIApplication.shared.firstKeyWindow?.safeAreaInsets.bottom == 0 {
                            loginButton.padding(.bottom, 13)
                        } else {
                            loginButton
                        }
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
                        .foregroundStyle(.white)
                        .font(.headline.bold())
                        .padding()
                }
            } else {
                if ConfigRepository.shared.testingLevel.isTrustworthy {
                    Picker(selection: $chosenServer) {
                        ForEach(Servers.allServers) { server in
                            Text(server.niceName).tag(server.rawValue)
                        }
                    }.pickerStyle(.menu)
                        .onChange(of: chosenServer) { _ in
                            let appDelegate = UIApplication.shared.delegate as? HabiticaAppDelegate
                            appDelegate?.updateServer()
                        }
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
