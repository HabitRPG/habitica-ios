//
//  NetworkErrorHandler.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
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
    
    public static func handle(error: NSError, message: String?) {
        if let errorMessage = errorMessageForCode(code: error.code) {
            self.notify(message: errorMessage.message)
        } else if let message = message {
            self.notify(message: message)
        } else {
            self.notify(message: error.localizedDescription)
        }
    }
    
    static func errorMessageForCode(code: Int) -> ErrorMessage? {
        if let messages = self.errorMessages {
            for errorMessage in messages where code == errorMessage.forCode {
                return errorMessage
            }
        }
        return nil
    }
    
    public static func notify(message: String) {
        let toastView = ToastView(title: message, background: .red)
        ToastManager.show(toast: toastView)
    }
}
