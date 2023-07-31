//
//  KeyboardManager.swift
//  Habitica
//
//  Created by Phillip Thelen on 27.10.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit

class KeyboardManager: NSObject {
    static var shared = KeyboardManager()
    private var measuredSize: CGRect = CGRect.zero
    
    private var viewsToUpdate = [ObservingView]()
    
    @objc static var size: CGSize {
        return shared.measuredSize.size
    }
    
    @objc static var height: CGFloat {
        return size.height
    }
    
    static func dismiss() {
        UIApplication.shared.windows.first(where: {$0.isKeyWindow})?.endEditing(true)
    }
    
    static func addObservingView(_ view: UIView) {
        shared.viewsToUpdate.append(ObservingView(value: view))
    }

    private func observeKeyboardNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(self.keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(self.keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc
    private func keyboardShow(_ notification: Notification) {
        guard measuredSize == CGRect.zero, let info = notification.userInfo,
              let value = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            else { return }

        measuredSize = value.cgRectValue
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve)) { [weak self] in
            for view in self?.viewsToUpdate ?? [] {
                view.value?.setNeedsLayout()
                view.value?.layoutIfNeeded()
            }
        }
    }
    
    @objc
    private func keyboardHide(_ notification: Notification) {
        guard let info = notification.userInfo,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            else { return }
        measuredSize = .zero
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve)) { [weak self] in
            for view in self?.viewsToUpdate ?? [] {
                view.value?.setNeedsLayout()
                view.value?.layoutIfNeeded()
            }
        }
    }

    override init() {
        super.init()
        observeKeyboardNotifications()
    }
}

private class ObservingView<T: UIView> {
  weak var value: T?
  init (value: T) {
    self.value = value
  }
}

private extension Array where Element: ObservingView<UIView> {
  mutating func reap () {
    self = self.filter { nil != $0.value }
  }
}
