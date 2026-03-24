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
    var errorMessages: [ErrorMessage]? { get }
    func handle(error: NetworkError, messages: [String])
}

public extension NetworkErrorHandler {
    func observe(signal: Signal<NSError, Never>) {
        disposable.inner.add(signal.observeValues({ error in
            self.handle(error: NetworkError(message: error.localizedDescription, url: "", code: error.code), messages: [])
        }))
    }
    func observe(signal: Signal<(NetworkError, [String]), Never>) {
        disposable.inner.add(signal.observeValues({ (error, response) in
            self.handle(error: error, messages: response)
        }))
    }
    func observe(signal: Signal<[NetworkError], Never>) {
        disposable.inner.add(signal.observeValues({ messages in
            self.handle(error: messages.first ?? NetworkError(message: "", url: ""), messages: messages.map({ error in
                return error.message
            }))
        }))
    }
}

public struct PrintNetworkErrorHandler: NetworkErrorHandler {
    public let disposable = ScopedDisposable(CompositeDisposable())
    public var errorMessages: [ErrorMessage]?
    
    public func handle(error: NetworkError, messages: [String] = []) {
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

public struct CallbackNetworkErrorHandler: NetworkErrorHandler {
    let onError: (NetworkError) -> Void
    
    public let disposable = ScopedDisposable(CompositeDisposable())
    public var errorMessages: [ErrorMessage]?
    
    public func handle(error: NetworkError, messages: [String] = []) {
        onError(error)
    }
}

public class NetworkError: NSError, @unchecked Sendable {
    public var url: String
    var message: String
    
    init(message: String, url: String, code: Int = -1000) {
        self.message = message
        self.url = url
        super.init(domain: "NetworkError", code: code, userInfo: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var localizedDescription: String {
        return message
    }
}
