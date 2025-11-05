//
//  NetworkErrorHandler.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Habitica_API_Client

public struct DefaultServerUnavailableErrorMessage: ErrorMessage {
    public let message: String = "The server is unavailable! Try again in a bit. If this keeps happening, please let us know!"
    public let forCode: Int = 503
}

public struct DefaultServerIssueErrorMessage: ErrorMessage {
    public let message: String = "Looks like we're having a problem. Please let us know about it!"
    public let forCode: Int = 500
}

public struct DefaultOfflineErrorMessage: ErrorMessage {
    public let message: String = "Looks like you're offline. Try reconnecting to the internet!"
    public let forCode: Int = -1009
}

class HabiticaNetworkErrorHandler: NetworkErrorHandler {
    public static let errorMessages: [ErrorMessage]? = [DefaultServerUnavailableErrorMessage(), DefaultServerIssueErrorMessage(), DefaultOfflineErrorMessage()]
    let disposable = ScopedDisposable(CompositeDisposable())
    
    private static let dismissingVCs = [
        ChallengeDetailsTableViewController.self,
        SplitSocialViewController.self,
        PartyViewController.self,
        QuestDetailViewController.self,
        UserProfileViewController.self,
        GiftGemsViewController.self,
        GiftSubscriptionViewController.self
    ]
    
    public static func handle(error: NetworkError, messages: [String]) {
        if error.code == 401,
           !error.url.contains("/user/auth/update-password") {
            let combined = messages.joined(separator: "\n")
            let trimmed = combined.trimmingCharacters(in: .whitespacesAndNewlines)
            let lower = trimmed.lowercased()
            
            let shouldLogout =
            trimmed.caseInsensitiveCompare("missingAuthHeaders") == .orderedSame
            || lower.contains("invalidcredentials")
            || lower.contains("missing authentication headers")
            || lower.contains("there is no account that uses those credentials")
            
            if shouldLogout {
                NotificationCenter.default
                    .post(name: .init("userDidBecomeUnauthorized"), object: nil)
                return
            }
        }
        
        if let errorMessage = errorMessageForCode(code: error.code) {
            notify(message: errorMessage.message, code: error.code, url: error.url)
        } else if !messages.isEmpty {
            notify(message: messages.joined(separator: "\n"), code: error.code, url: error.url)
        } else {
            notify(message: error.localizedDescription, code: 0, url: error.url)
        }
    }

    static func errorMessageForCode(code: Int) -> ErrorMessage? {
        if let messages = errorMessages {
            for errorMessage in messages where code == errorMessage.forCode {
                return errorMessage
            }
        }
        return nil
    }
    
    public static func notify(message: String, code: Int, url: String) {
        // Suppress invalid_credentials errors - they're handled by automatic logout
        if message.lowercased().contains("invalid_credentials") {
            return
        }
        // Should not need this check, just in case however, this is handled by automatic logout.
        if message.lowercased().contains("there is no account that uses those credentials") {
           return
        }
        // Suppress SUBSCRIPTION_STILL_VALID notifications
        if message.contains("SUBSCRIPTION_STILL_VALID") {
            return
        }
        
        if code == 400 {
            let alertController = HabiticaAlertController(title: message)
            alertController.addCloseAction()
            alertController.show()
        } else {
            if code == 404 {
                if url.contains("/Saddle") {
                    // We want to handle the saddle error differently
                    return
                }
            }
            var duration: Double?
            if message.count > 200 {
                duration = 4.0
            }
            let toastView = ToastView(title: message, background: .red, duration: duration)
            ToastManager.show(toast: toastView)
        }
        
        if code == 404 {
            if let visibleViewController = UIApplication.topViewController(), dismissingVCs.contains(where: { type(of: visibleViewController) == $0 }) {
                visibleViewController.navigationController?.popViewController(animated: true)
            }
        }
    }
}
