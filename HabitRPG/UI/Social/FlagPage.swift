//
//  ReportPage.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.11.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftUI
import Habitica_Models
import ReactiveSwift

enum FlagType {
    case chatMessage
    case inboxMessage
    case member
    case challenge
}

class FlagViewModel: ObservableObject {
    let type: FlagType
    let offendingItem: Any
    
    var onFlagged: (() -> Void)?
    
    @Published var reason: String = ""
    
    private let socialRepository = SocialRepository()
    
    init(type: FlagType, offendingItem: Any) {
        self.type = type
        self.offendingItem = offendingItem
    }
    
    var offendingText: String {
        if let item = offendingItem as? ChatMessageProtocol {
            return item.text ?? ""
        }
        if let item = offendingItem as? InboxMessageProtocol {
            return item.text ?? ""
        }
        if let item = offendingItem as? MemberProtocol {
            return item.username ?? ""
        }
        if let item = offendingItem as? ChallengeProtocol {
            return item.name ?? ""
        }
        if let item = offendingItem as? String {
            return item
        }
        return ""
    }
    
    var typeText: String {
        switch type {
        case .chatMessage:
            return L10n.message
        case .inboxMessage:
            return L10n.message
        case .member:
            return L10n.player
        case .challenge:
            return L10n.challenge
        }
    }
    
    func sendReport() {
        var flagCall: Signal<EmptyResponseProtocol?, Never>?
        switch type {
        case .chatMessage:
            if let chatMessage = offendingItem as? ChatMessageProtocol {
                flagCall = socialRepository.flag(groupID: "", chatMessage: chatMessage, reason: reason)
            }
        case .inboxMessage:
            if let inboxMessage = offendingItem as? InboxMessageProtocol {
                flagCall = socialRepository.flag(message: inboxMessage, reason: reason)
            }
        case .member:
            if let member = offendingItem as? MemberProtocol {
                flagCall = socialRepository.flag(memberID: member.id ?? "", reason: reason)
                    .flatMap(.latest, { _ in
                        return self.socialRepository.blockMember(userID: member.id ?? "")
                    }).map({ _ -> EmptyResponseProtocol? in
                        return nil
                    })
            }
        case .challenge:
            if let challenge = offendingItem as? ChallengeProtocol {
                flagCall = socialRepository.flag(challengeID: challenge.id ?? "", reason: reason)
            }
        }
        
        if let call = flagCall {
            call.observeCompleted {
                if let action = self.onFlagged {
                    action()
                }
            }
        }
    }
}

struct FlagPage: View {
    @ObservedObject var viewModel: FlagViewModel
    @State var isFirstResponder = true
    var body: some View {
        let theme = ThemeService.shared.theme
        let typeText = viewModel.typeText
        VStack(alignment: .leading, spacing: 0) {
            Rectangle().fill().foregroundColor(Color(UIColor.gray400)).frame(width: 22, height: 3).cornerRadius(1.5)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, 10)
            HStack {
                Text(L10n.reportX(typeText)).foregroundColor(Color(theme.primaryTextColor)).font(.system(size: 20, weight: .medium))
                Spacer()
                Button(L10n.report) {
                    viewModel.sendReport()
                }.buttonStyle(.plain).foregroundColor(Color(UIColor.red100))
            }.padding(.vertical, 32)
            VStack {
                Text(viewModel.offendingText).font(.system(size: 16, weight: .medium)).frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(theme.separatorColor), lineWidth: 1)
            )
            Text(L10n.reportXQuestion(typeText)).font(.system(size: 16, weight: .medium)).padding(.top, 20)
            FocusableTextField(placeholder: L10n.reasonForReport, text: $viewModel.reason, isFirstResponder: $isFirstResponder)
                .padding(16).background(Color(UIColor.gray400).opacity(0.12)).cornerRadius(8)
                .padding(.top, 12).padding(.bottom, 15)
            if viewModel.type == .member {
                Text(L10n.thisWillAlsoBlockX(viewModel.offendingText)).font(.system(size: 14, weight: .medium)).foregroundColor(Color(theme.ternaryTextColor))
            }
            Text(L10n.reportingDisclaimer(typeText)).font(.system(size: 14)).foregroundColor(Color(theme.ternaryTextColor)).padding(.bottom, 12)
        }.padding(.horizontal, 32).foregroundColor(Color(theme.primaryTextColor))
    }
}

private struct Preview: PreviewProvider {
    static var previews: some View {
        FlagPage(viewModel: FlagViewModel(type: .chatMessage, offendingItem: "Message with some bad words"))
        FlagPage(viewModel: FlagViewModel(type: .inboxMessage, offendingItem: "Inbox message that is mean"))
        FlagPage(viewModel: FlagViewModel(type: .member, offendingItem: "@baduser"))
        FlagPage(viewModel: FlagViewModel(type: .challenge, offendingItem: "Challenge about something bad"))
    }
}

class FlagViewController: HostingBottomSheetController<FlagPage> {
    let viewModel: FlagViewModel
    
    init(type: FlagType, offendingItem: Any, name: String? = nil) {
        self.viewModel = FlagViewModel(type: type, offendingItem: offendingItem)
        super.init(rootView: FlagPage(viewModel: viewModel))
        self.viewModel.onFlagged = {
            self.dismiss()
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
