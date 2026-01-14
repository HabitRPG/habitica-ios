//
//  ToastManager.swift
//  Habitica
//
//  Created by Phillip on 11.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
import UIKit
import SwiftUI
import SwiftUIX

// swiftlint:disable:next attributes
@objc public enum ToastColor: Int {
    case blue = 0, green, red, gray, yellow, purple, black, subscriberPerk
    
    func getUIColor() -> UIColor {
        switch self {
        case .blue:
            return UIColor.blue50
        case .green:
            return UIColor.green100
        case .red:
            return UIColor.red10
        case .gray:
            return UIColor.gray50
        case .yellow:
            return UIColor.yellow10
        case .purple:
            return UIColor.purple200
        case .subscriberPerk:
            return UIColor.teal100
        case .black:
            return UIColor.black
        }
    }
    
    func getColor() -> Color {
        switch self {
        case .blue:
            return .blue50
        case .green:
            return .green100
        case .red:
            return .red10
        case .gray:
            return .gray50
        case .yellow:
            return .yellow10
        case .purple:
            return .purple200
        case .subscriberPerk:
            return .teal100
        case .black:
            return .black
        }
    }
}

class ToastManager: NSObject {
    
    static let shared = ToastManager()

    var displayQueue: [UIHostingView<ToastView>] = [UIHostingView<ToastView>]()
    var showingNotification: Bool {
        return displayQueue.isEmpty == false
    }
    
    private func present(toast: UIHostingView<ToastView>, completion: (() -> Void)?) {
        if var viewController = UIApplication.topViewController() {
            if let tabbarController = viewController.tabBarController {
                viewController = tabbarController
            }
            if let navigationController = viewController.navigationController {
                viewController = navigationController
            }
            let contentView = toast
            contentView.frame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: viewController.view.frame.size.height)
            contentView.setNeedsLayout()
            viewController.view.addSubview(contentView)
            let bottomOffset = KeyboardManager.height > 0 ? KeyboardManager.height - 44 : 0
            viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-\(bottomOffset)-|",
                                                                              options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                              metrics: nil, views: ["view": contentView]))
            viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|",
                                                                              options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                              metrics: nil, views: ["view": contentView]))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                if #available(iOS 17.0, *) {
                    withAnimation {
                        contentView.rootView.options.isVisible = true
                    } completion: {
                        if let completionBlock = completion {
                            completionBlock()
                        }
                    }
                } else {
                    withAnimation {
                        contentView.rootView.options.isVisible = true
                    }
                    if let completionBlock = completion {
                        completionBlock()
                    }
                }
            })
        } else {
            displayQueue.removeFirst()
        }
    }
    
    private func dismiss(toast: UIHostingView<ToastView>, completion: (() -> Void)?) {
        if #available(iOS 17.0, *) {
            withAnimation {
                toast.rootView.options.isVisible = false
            } completion: {
                toast.removeFromSuperview()
                if let completionBlock = completion {
                    completionBlock()
                }
            }
        } else {
            toast.removeFromSuperview()
            if let completionBlock = completion {
                completionBlock()
            }
        }
     }
    
    private func display(toast: UIHostingView<ToastView>) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + toast.rootView.options.delayDuration) {[weak self] in
            self?.present(toast: toast) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+toast.rootView.options.displayDuration) {[weak self] in
                    self?.dismiss(toast: toast) { () -> Void in
                        if self?.displayQueue.isEmpty == true {
                            return
                        }
                        self?.displayQueue.removeFirst()
                        if let toast = self?.displayQueue.first {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                self?.display(toast: toast)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func add(toast: UIHostingView<ToastView>) {
        toast.isUserInteractionEnabled = false
        if !showingNotification {
            displayQueue.append(toast)
            display(toast: toast)
        } else {
            displayQueue.append(toast)
        }
    }
    
    class func show(toast: ToastView) {
        shared.add(toast: UIHostingView(rootView: toast))
    }
    
    class func show(text: String, color: ToastColor, duration: Double? = nil, delay: Double? = nil) {
        ToastManager.show(toast: ToastView(title: text, background: color, duration: duration))
    }
}

class ToastOptions: ObservableObject {
    @Published var isVisible = false
    
    @Published var title: String?
    @Published var subtitle: String?
    
    @Published var leftImage: UIImage?
    
    var displayDuration = 2.0
    var delayDuration = 0.0

    @Published var backgroundColor = ToastColor.red
    
    @Published var rightIcon: UIImage?
    @Published var rightText: String?
    @Published var rightTextColor = UIColor.gray50
    
    @Published var statsChanges: [StatsChange] = []
}
