//
//  UINotificationFeedbackGenerator.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.05.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
extension UINotificationFeedbackGenerator {
    func safePrepare() {
        DispatchQueue.main.async {
            self.prepare()
        }
    }
    
    func safeNotificationOccurred(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            self.notificationOccurred(type)
        }
    }
    
    class func oneShotNotificationOccurred(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let feedback = UINotificationFeedbackGenerator()
            feedback.prepare()
            feedback.notificationOccurred(type)
        }
    }
}

@available(iOS 10.0, *)
extension UISelectionFeedbackGenerator {
    
    class func oneShotSelectionChanged() {
        let feedback = UISelectionFeedbackGenerator()
        feedback.prepare()
        feedback.selectionChanged()
    }
}

@available(iOS 10.0, *)
extension UIImpactFeedbackGenerator {
    
    class func oneShotImpactOccurred(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let feedback = UIImpactFeedbackGenerator(style: style)
        feedback.prepare()
        feedback.impactOccurred()
    }
}
