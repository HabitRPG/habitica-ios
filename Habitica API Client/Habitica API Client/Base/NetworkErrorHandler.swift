//
//  NetworkErrorHandler.swift
//  Pods
//
//  Created by Elliot Schrock on 9/11/17.
//
//

import Foundation
import ReactiveSwift

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
    func observe(signal: Signal<NSError, Never>) {
        disposable.inner.add(signal.observeValues({ error in
            Self.handle(error: error, messages: [])
        }))
    }
    func observe(signal: Signal<(NSError, [String]), Never>) {
        disposable.inner.add(signal.observeValues({ (error, response) in
            Self.handle(error: error, messages: response)
        }))
    }
    func observe(signal: Signal<[String], Never>) {
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

extension UIAlertController {
    public func show(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.backgroundColor = UIColor.clear
        window.windowLevel = UIWindow.Level.alert
        
        if let rootViewController = window.rootViewController {
            window.makeKeyAndVisible()
            
            rootViewController.present(self, animated: flag, completion: completion)
        }
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
