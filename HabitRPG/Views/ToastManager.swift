//
//  ToastManager.swift
//  Habitica
//
//  Created by Phillip on 11.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//
import Foundation
import UIKit

enum ToastColor {
    case blue, green, red
    
    func getUIColor() -> UIColor {
        switch self {
        case .blue:
            return UIColor.blue10()
        case .green:
            return UIColor.green10()
        case .red:
            return UIColor.red10()
        }
    }
}

class ToastManager {
    
    lazy var window: UIWindow = {
        var window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.clear
        window.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.windowLevel = UIWindowLevelStatusBar
        window.rootViewController = UIViewController()
        return window
    }()
    
    class var sharedManager: ToastManager {
        struct Static {
            static let instance: ToastManager = ToastManager()
        }
        return Static.instance
    }
    
    var displayQueue: [ToastView] = [ToastView]()
    var showingNotification: Bool {
        return displayQueue.count > 0
    }
    
    private func present(toast: ToastView, completion: ((_ contentView: UIView) -> Void)?) {
        window.isHidden = false
        if let viewController = window.rootViewController {
            let contentView = toast
            contentView.frame = CGRect(x: 0, y: -100, width: viewController.view.frame.size.width, height: 100)
            viewController.view.addSubview(contentView)
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        contentView.frame = contentView.frame.replaceX(newValue: 0).replaceY(newValue: 0)
                }) { (_) in if let completionBlock = completion { completionBlock(contentView) } }
            
        }
    }
    
    private func dismiss(toast: ToastView, contentView: UIView, completion: (() -> Void)?) {
        if let viewController = window.rootViewController {
            UIView.animate(
            withDuration: 0.5,
            animations: { () -> Void in
                contentView.frame = CGRect(x: 0, y: -100, width: viewController.view.frame.size.width, height: 100)
        }) { (_) in if let completionBlock = completion { completionBlock() } }
        }
    }
    
    private func display(toast: ToastView) {
        present(toast: toast) { contentView in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+toast.options.displayDuration) {
                self.dismiss(toast: toast, contentView: contentView) { () -> Void in
                    if self.displayQueue.count == 0 {
                        return
                    }
                    self.display(toast: self.displayQueue.removeFirst())
                }
            }
        }
    }
    
    private func add(toast: ToastView) {
        if !showingNotification {
            displayQueue.append((toast))
            display(toast: toast)
        } else {
            displayQueue.append((toast))
        }
    }
    
    class func show(toast: ToastView) {
        self.sharedManager.add(toast: toast)
    }
    
    class func show(text: String, color: ToastColor) {
        
    }
}

struct ToastOptions {
    
    var title: String?
    var subtitle: String?
    
    var leftImage: UIImage?
    var rightImage: UIImage?
    
    var displayDuration = 2.0

    var backgroundColor = ToastColor.red
}
