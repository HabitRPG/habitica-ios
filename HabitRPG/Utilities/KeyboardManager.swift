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
    
    static func addObservingView(_ view: UIView) {
        shared.viewsToUpdate.append(ObservingView(value: view))
    }

    private func observeKeyboardNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(self.keyboardChange), name: UIResponder.keyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: #selector(self.keyboardChange), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    @objc
    private func keyboardChange(_ notification: Notification) {
        guard measuredSize == CGRect.zero, let info = notification.userInfo,
              let value = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            else { return }

        measuredSize = value.cgRectValue
        
        for view in viewsToUpdate {
            view.value?.setNeedsLayout()
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
