//
//  SpeechbubbleView.swift
//  Habitica
//
//  Created by Phillip on 28.07.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
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
    
    @IBOutlet weak var namePlateView: UILabel!
    @IBOutlet weak var textView: HRPGTypingLabel!
    @IBOutlet weak var namePlateBackgroundView: UIImageView!
    
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
            
            textView.textContainerInset = UIEdgeInsets(top: 20, left: 24, bottom: 12, right: 12)
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
