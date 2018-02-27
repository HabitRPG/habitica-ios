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
    
    @IBOutlet weak var backgroundView: HRPGHoledView!
    @IBOutlet weak var speechbubbleView: SpeechbubbleView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private weak var displayView: UIView?
    @objc var dismissAction: (() -> Void)?
    @objc var hintView: HRPGHintView?
    private var textList = [String]()
    
    @objc var highlightedFrame: CGRect = CGRect.zero {
        didSet {
            self.backgroundView.highlightedFrame = highlightedFrame
            self.backgroundView.setNeedsDisplay()
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
            view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
            addSubview(view)
            
            self.backgroundView.dimColor = UIColor.purple50().withAlphaComponent(0.6)
            
            self.shouldGroupAccessibilityChildren = true
            self.isAccessibilityElement = true
            
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        }
    }

    func loadViewFromNib() -> UIView? {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        
        return view
    }
    
    @objc
    func displayHint(onView: UIView, displayView: UIView, animated: Bool) {
        self.displayView = displayView
        let hintView = HRPGHintView()
        
        hintView.frame = CGRect(x: highlightedFrame.origin.x + ((highlightedFrame.size.width - 45) / 2),
                                y: self.highlightedFrame.origin.y + ((self.highlightedFrame.size.height - 45) / 2),
                                width: 45, height: 45)
        hintView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hintViewTapped)))
        hintView.pulse(toSize: 1.4, withDuration: 1.0)
        onView.addSubview(hintView)
        self.hintView = hintView
    }
    
    @objc
    func display(onView: UIView, animated: Bool) {
        onView.addSubview(self)
        self.frame = onView.frame
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
        self.displayView = nil
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
        if textList.count == 0 {
             speechbubbleView.caretView.isHidden = true
        }
        self.accessibilityLabel = text
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self)
    }
    
    @objc
    func setTexts(list: [String]) {
        if list.count > 0 {
            speechbubbleView.caretView.isHidden = false
            textList = list
            setText(textList.removeFirst())
            speechbubbleView.animateTextView()
        }
    }
    
    @objc
    func hintViewTapped() {
        self.hintView?.removeFromSuperview()
        self.hintView = nil
        if let view = displayView {
            display(onView: view, animated: true)
        }
    }
    
    @objc
    func viewTapped() {
        if textList.count == 0 {
            self.dismiss(animated: true)
        } else {
            setText(textList.removeFirst())
            speechbubbleView.animateTextView()
        }
    }
}
