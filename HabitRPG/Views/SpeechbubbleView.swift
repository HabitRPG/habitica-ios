//
//  SpeechbubbleView.swift
//  Habitica
//
//  Created by Phillip on 28.07.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

class SpeechbubbleView: UIView {
    
    @IBInspectable var npcName: String? {
        didSet {
            namePlateView.text = npcName
        }
    }
    
    @IBInspectable var text: String? {
        didSet {
            textView.setText(text, startAnimating: false)
        }
    }
    
    @IBInspectable var hasNpcImage: Bool = true {
        didSet {
            if hasNpcImage {
                npcImageView.image = npcImage
            } else {
                npcImageView.image = nil
            }
        }
    }
    
    @IBInspectable var npcImage: UIImage? {
        didSet {
            npcImageView.image = npcImage
        }
    }
    
    @IBInspectable var hasAdditionalText: Bool = false {
        didSet {
            caretView.isHidden = !hasAdditionalText
        }
    }
    
    @IBOutlet weak var namePlateView: UILabel!
    @IBOutlet weak var textView: HRPGTypingLabel!
    @IBOutlet weak var namePlateBackgroundView: UIImageView!
    @IBOutlet weak var npcImageView: UIImageView!
    @IBOutlet weak var caretView: UIImageView!
    
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
            
            textView.textContainerInset = UIEdgeInsets(top: 16, left: 20, bottom: 12, right: 12)
            textView.layer.cornerRadius = 4
            
            namePlateBackgroundView.image = #imageLiteral(resourceName: "Nameplate").resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21))
        }
    }
    
    func loadViewFromNib() -> UIView? {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        
        return view
    }
    
    func animateTextView() {
        textView.startAnimating()
    }
    
}
