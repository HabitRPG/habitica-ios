//
//  ToastManager.swift
//  Habitica
//
//  Created by Phillip on 11.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//
import Foundation
import UIKit

@objc public enum ToastColor: Int {
    case blue = 0, green, red
    
    func getUIColor() -> UIColor {
        switch self {
        case .blue:
            return UIColor.blue50()
        case .green:
            return UIColor.green100()
        case .red:
            return UIColor.red10()
        }
    }
}

class ToastManager: NSObject {
    
    static let shared = ToastManager()

    var displayQueue: [ToastView] = [ToastView]()
    var showingNotification: Bool {
        return displayQueue.count > 0
    }
    
    private func present(toast: ToastView, completion: (() -> Void)?) {
        if let viewController = UIApplication.topViewController()?.tabBarController {
            let contentView = toast
            contentView.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.view.frame.size.height)
            contentView.setNeedsLayout()
            contentView.alpha = 0
            viewController.view.addSubview(contentView)
            viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": contentView]))
            viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": contentView]))
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    contentView.alpha = 1
                }) { (_) in if let completionBlock = completion { completionBlock() } }
            
        }
    }
    
    private func dismiss(toast: ToastView, completion: (() -> Void)?) {
        UIView.animate(
            withDuration: 0.2,
            animations: { () -> Void in
                toast.alpha = 0
        }) { (_) in
            toast.removeFromSuperview()
            if let completionBlock = completion {
                completionBlock()
            }
        }
     }
    
    private func display(toast: ToastView) {
        present(toast: toast) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+toast.options.displayDuration) {
                self.dismiss(toast: toast) { () -> Void in
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
            display(toast: toast)
        } else {
            displayQueue.append((toast))
        }
    }
    
    class func show(toast: ToastView) {
        self.shared.add(toast: toast)
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
