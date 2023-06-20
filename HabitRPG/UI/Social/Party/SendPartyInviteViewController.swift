//
//  SendPartyInviteViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.06.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftUI
import Habitica_Models

class SendPartyInviteViewModel: ObservableObject {
    let onInvited: () -> Void
    let socialRepository = SocialRepository()
    
    init(onInvited: @escaping () -> Void) {
        self.onInvited = onInvited
    }

    @Published var buttonState = LoadingButtonState.content
    @Published var invites = [String]()
    
    var hasValidInvites: Bool {
        return invites.contains(where: { invite in
            return !invite.isEmpty
        })
    }
    
    func invite() {
        buttonState = .loading
        var emails = [[String: String]]()
        var uuids = [String]()
        var usernames = [String]()
        for invite in invites {
            if invite.isValidEmail() {
                emails.append([
                    "name": "",
                    "email": invite
                ])
            } else if UUID(uuidString: invite) != nil {
                uuids.append(invite)
            } else {
                usernames.append(invite)
            }
        }
        var inviteMap: [String: Any] = ["emails": emails, "uuids": uuids, "usernames": usernames]

        socialRepository.invite(toGroup: "party", members: inviteMap).on(completed: {
            if self.buttonState == .success {
                return
            }
            self.buttonState = .failed
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.buttonState = .content
            }
        }).observeValues { result in
            if result != nil {
                self.buttonState = .success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.onInvited()
                }
            } else {
                self.buttonState = .failed
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.buttonState = .content
                }
            }
        }
    }

}

struct InviteView: View {
    @Binding var text: String
    let onDelete: () -> Void
    
    @State private var isFirstResponder: Bool
    
    init(text: Binding<String>, index: Int, onDelete: @escaping () -> Void, focusIndex: Int?) {
        self._text = text
        self.onDelete = onDelete
        self._isFirstResponder = State(initialValue: index == focusIndex)
    }
    
    var body: some View {
        HStack {
            Button(action: {
                onDelete()
            }, label: {
                Rectangle().fill(Color.white).frame(width: 9, height: 2)
                    .background(Circle().fill(Color.accentColor).frame(width: 21, height: 21))
                    .frame(width: 48, height: 48)
            })
            FocusableTextField(placeholder: "Username or email address", text: $text, isFirstResponder: $isFirstResponder)
        }.background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
        .transition(.opacity)
    }
}

struct SendPartyInviteView: View {
    @ObservedObject var viewModel: SendPartyInviteViewModel
    @State var focusIndex: Int?
    
    var addButton: some View { Button(action: {
        viewModel.invites.append("")
        focusIndex = viewModel.invites.count - 1
        }, label: {
            Text("Username or email address").font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(ThemeService.shared.theme.ternaryTextColor))
                .frame(maxWidth: .infinity).frame(height: 48)
                .background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
        })
    }
    
    func getBinding(forIndex index: Int) -> Binding<String> {
        return Binding<String>(get: {
            if viewModel.invites.count > index {
                return viewModel.invites[index]
            } else {
                return ""
            }
            },
                               set: { viewModel.invites[index] = $0 })
        }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(0..<viewModel.invites.count, id: \.self) { index in
                    InviteView(text: getBinding(forIndex: index), index: index, onDelete: {
                        viewModel.invites.remove(at: index)
                    }, focusIndex: focusIndex)
                }
                addButton
                LoadingButton(state: .constant((viewModel.hasValidInvites ? viewModel.buttonState : .disabled)), onTap: {
                    viewModel.invite()
                }, content: Text(L10n.Groups.sendInvite))
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            .padding(14)
        }
    }
}

class SendPartyInviteViewController: UIHostingController<SendPartyInviteView> {
    let viewModel = SendPartyInviteViewModel {
    }
    
    init() {
        super.init(rootView: SendPartyInviteView(viewModel: viewModel))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SendPartyInviteView(viewModel: viewModel))
    }
}
