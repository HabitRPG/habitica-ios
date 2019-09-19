//
//  UINotificationFeedbackGenerator.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.05.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit

extension UINotificationFeedbackGenerator {
    func safePrepare() {
        DispatchQueue.main.async {[weak self] in
            self?.prepare()
        }
    }
    
    func safeNotificationOccurred(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {[weak self] in
            self?.notificationOccurred(type)
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

extension UISelectionFeedbackGenerator {
    
    class func oneShotSelectionChanged() {
        let feedback = UISelectionFeedbackGenerator()
        feedback.prepare()
        feedback.selectionChanged()
    }
}

extension UIImpactFeedbackGenerator {
    
    class func oneShotImpactOccurred(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let feedback = UIImpactFeedbackGenerator(style: style)
        feedback.prepare()
        feedback.impactOccurred()
    }
}
