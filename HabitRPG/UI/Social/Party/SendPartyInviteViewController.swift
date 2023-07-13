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
        let inviteMap: [String: Any] = ["emails": emails, "uuids": uuids, "usernames": usernames]

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
                ToastManager.show(text: L10n.usersInvited, color: .green)
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
                Image(systemName: .xmark).frame(width: 14, height: 14).foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
            }).frame(width: 30, height: 48)
            FocusableTextField(placeholder: "Username or email address", text: $text, isFirstResponder: $isFirstResponder).frame(height: 48)
        }.background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8))
        .transition(.opacity)
    }
}

struct SendPartyInviteView: View {
    @ObservedObject var viewModel: SendPartyInviteViewModel
    @State var focusIndex: Int?
    
    var addButton: some View {
            HStack {
                Image(systemName: .plus).frame(width: 16, height: 16).foregroundColor(Color(ThemeService.shared.theme.primaryTextColor)).width(30)
                Text("Username or email address").font(.system(size: 17))
                    .foregroundColor(Color(ThemeService.shared.theme.dimmedTextColor))
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading).frame(height: 48)
            .background(Color(ThemeService.shared.theme.windowBackgroundColor).cornerRadius(8)).onTapGesture {
                viewModel.invites.append("")
                focusIndex = viewModel.invites.count - 1
            }
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
    
    private func deleteInvite(at index: Int) {
        viewModel.invites.remove(at: index)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                VStack(alignment: .center) {
                    Text("Invite with @username or email").font(.headline)
                    Text("Send an invite directly to players you know").font(.body)
                }.frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 6)
                ForEach(0..<viewModel.invites.count, id: \.self) { index in
                    InviteView(text: getBinding(forIndex: index), index: index, onDelete: {
                        withAnimation {
                            deleteInvite(at: index)
                        }
                    }, focusIndex: focusIndex)
                }
                addButton
                LoadingButton(state: .constant((viewModel.hasValidInvites ? viewModel.buttonState : .disabled)), onTap: {
                    viewModel.invite()
                }, content: Text(L10n.Groups.sendInvite), successContent: Text(L10n.Groups.invited))
                Text("If an email isn't registered yet, we'll invite them to join Habitica.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 14))
                    .foregroundColor(Color(ThemeService.shared.theme.secondaryTextColor))
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            .padding(14)
        }
    }
}

class SendPartyInviteViewController: BaseHostingViewController<SendPartyInviteView> {
    let viewModel = SendPartyInviteViewModel {
        RouterHandler.shared.pop()
    }
    
    init() {
        super.init(rootView: SendPartyInviteView(viewModel: viewModel))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SendPartyInviteView(viewModel: viewModel))
    }
    
    override func viewDidLoad() {
        topHeaderCoordinator?.hideHeader = true
        super.viewDidLoad()
    }
}
