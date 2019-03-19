//
//  ToastManager.swift
//  Habitica
//
//  Created by Phillip on 11.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
import Foundation
import UIKit

//swiftlint:disable:next attributes
@objc public enum ToastColor: Int {
    case blue = 0, green, red, gray, yellow, purple
    
    func getUIColor() -> UIColor {
        switch self {
        case .blue:
            return UIColor.blue50()
        case .green:
            return UIColor.green100()
        case .red:
            return UIColor.red10()
        case .gray:
            return UIColor.gray50()
        case .yellow:
            return UIColor.yellow10()
        case .purple:
            return UIColor.purple200()
        }
    }
}

class ToastManager: NSObject {
    
    static let shared = ToastManager()

    var displayQueue: [ToastView] = [ToastView]()
    var showingNotification: Bool {
        return displayQueue.isEmpty == false
    }
    
    private func present(toast: ToastView, completion: (() -> Void)?) {
        if var viewController = UIApplication.topViewController() {
            if let tabbarController = viewController.tabBarController {
                viewController = tabbarController
            }
            if let navigationController = viewController.navigationController {
                viewController = navigationController
            }
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: toast.accessibilityLabel)
            let contentView = toast
            contentView.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.view.frame.size.height)
            contentView.setNeedsLayout()
            contentView.alpha = 0
            viewController.view.addSubview(contentView)
            viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|",
                                                                              options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                              metrics: nil, views: ["view": contentView]))
            viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|",
                                                                              options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                              metrics: nil, views: ["view": contentView]))
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    contentView.alpha = 1
                }, completion: { (_) in
                    if let completionBlock = completion {
                        completionBlock()
                    }
            })
        } else {
            self.displayQueue.removeFirst()
        }
    }
    
    private func dismiss(toast: ToastView, completion: (() -> Void)?) {
        UIView.animate(
            withDuration: 0.2,
            animations: { () -> Void in
                toast.alpha = 0
        }, completion: { (_) in
            toast.removeFromSuperview()
            if let completionBlock = completion {
                completionBlock()
            }
        })
     }
    
    private func display(toast: ToastView) {
        present(toast: toast) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+toast.options.displayDuration) {
                self.dismiss(toast: toast) { () -> Void in
                    if self.displayQueue.isEmpty {
                        return
                    }
                    self.displayQueue.removeFirst()
                    if let toast = self.displayQueue.first {
                        self.display(toast: toast)
                    }
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
    
    @objc
    class func show(toast: ToastView) {
        self.shared.add(toast: toast)
    }
    
    class func show(text: String, color: ToastColor, duration: Double? = nil) {
        ToastManager.show(toast: ToastView(title: text, background: color, duration: duration))
    }
}

struct ToastOptions {
    
    var title: String?
    var subtitle: String?
    
    var leftImage: UIImage?
    
    var displayDuration = 2.0

    var backgroundColor = ToastColor.red
    
    var rightIcon: UIImage?
    var rightText: String?
    var rightTextColor = UIColor.gray50()
}
