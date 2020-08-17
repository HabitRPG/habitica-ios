//
//  TutorialStepView.swift
//  Habitica
//
//  Created by Phillip on 11.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

enum TutorialStepViewPosition {
    case top, center, bottom
}

class TutorialStepView: UIView {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var speechbubbleView: SpeechbubbleView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private weak var displayView: UIView?
    @objc var dismissAction: (() -> Void)?
    private var textList = [String]()
    
    @objc var highlightedFrame: CGRect = CGRect.zero {
        didSet {
            backgroundView.setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        if let view = loadViewFromNib() {
            view.frame = bounds
            view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            addSubview(view)
            
            backgroundView.backgroundColor = ThemeService.shared.theme.backgroundTintColor.withAlphaComponent(0.6)
            
            shouldGroupAccessibilityChildren = true
            isAccessibilityElement = true
            
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        }
    }

    func loadViewFromNib() -> UIView? {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        
        return view
    }
    
    @objc
    func display(onView: UIView, animated: Bool) {
        onView.addSubview(self)
        frame = onView.frame
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            self?.backgroundView.alpha = 1
        }, completion: {[weak self] _ in
            UIView.animate(withDuration: 0.4, delay: 0.3, options: [], animations: {[weak self] in
                self?.speechbubbleView.alpha = 1
            }, completion: {[weak self] _ in
                self?.speechbubbleView.animateTextView()
            })
        })
    }
    
    @objc
    func dismiss(animated: Bool) {
        displayView = nil
        if let action = self.dismissAction {
            action()
        }
        UIView .animate(withDuration: 0.4, animations: {[weak self] in
            self?.alpha = 0
            }, completion: {[weak self] _ in
                self?.removeFromSuperview()
        })
    }
    
    @objc
    func setText(_ text: String) {
        speechbubbleView.text = text
        if textList.isEmpty {
             speechbubbleView.caretView.isHidden = true
        }
        accessibilityLabel = text
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self)
    }
    
    @objc
    func setTexts(list: [String]) {
        if list.isEmpty == false {
            speechbubbleView.caretView.isHidden = false
            textList = list
            setText(textList.removeFirst())
            speechbubbleView.animateTextView()
        }
    }
    
    @objc
    func viewTapped() {
        if textList.isEmpty {
            dismiss(animated: true)
        } else {
            setText(textList.removeFirst())
            speechbubbleView.animateTextView()
        }
    }
}
