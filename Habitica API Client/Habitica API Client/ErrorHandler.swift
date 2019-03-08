//
//  ErrorHandler.swift
//  Habitica API Client
//
//  Created by Phillip Thelen on 08.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public protocol ErrorMessage {
    var message: String { get }
    var forCode: Int { get }
}

public protocol NetworkErrorHandler {
    var disposable: ScopedDisposable<CompositeDisposable> { get }
    static var errorMessages: [ErrorMessage]? { get }
    static func handle(error: NSError, messages: [String])
}

public extension NetworkErrorHandler {
    public func observe(signal: Signal<NSError, NoError>) {
        disposable.inner.add(signal.observeValues({ error in
            Self.handle(error: error, messages: [])
        }))
    }
    public func observe(signal: Signal<(NSError, [String]), NoError>) {
        disposable.inner.add(signal.observeValues({ (error, response) in
            Self.handle(error: error, messages: response)
        }))
    }
    public func observe(signal: Signal<[String], NoError>) {
        disposable.inner.add(signal.observeValues({ messages in
            Self.handle(error: NetworkError(message: messages.first ?? ""), messages: messages)
        }))
    }
}

public class PrintNetworkErrorHandler: NetworkErrorHandler {
    public let disposable = ScopedDisposable(CompositeDisposable())
    public static var errorMessages: [ErrorMessage]?
    
    public static func handle(error: NSError, messages: [String] = []) {
        for message in messages {
            print(message)
        }
        print(error.localizedDescription)
    }
}

class NetworkError: NSError {
    var message: String
    
    init(message: String) {
        self.message = message
        super.init(domain: "NetworkError", code: -1000, userInfo: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var localizedDescription: String {
        return message
    }
}
