//
//  ChallengeDescriptionTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/25/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Down
import Habitica_Models

class ChallengeDescriptionTableViewCell: ResizableTableViewCell, ChallengeConfigurable {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var caretButton: UIButton!
    @IBOutlet weak var marginConstraint: NSLayoutConstraint!
    
    private var heightConstraint: NSLayoutConstraint?
    
    private var isExpanded = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with challenge: ChallengeProtocol) {
        if let notes = challenge.notes {
            descriptionLabel.attributedText = try? Down(markdownString: notes.unicodeEmoji).toHabiticaAttributedString(baseSize: descriptionLabel.font.pointSize)
        }
    }
    
    func expand() {
        rotateCaret()
        
        self.marginConstraint.constant = 8
        if let constraint = self.heightConstraint {
            self.descriptionLabel.removeConstraint(constraint)
        }
        
        self.resizingDelegate?.cellResized()
    }
    
    func collapse() {
        rotateCaret()
        
        self.marginConstraint.constant = 0
        if self.heightConstraint == nil {
            self.heightConstraint = NSLayoutConstraint(item: descriptionLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: .equal,
                                                       toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        }
        
        if let constraint = self.heightConstraint {
            self.descriptionLabel.addConstraint(constraint)
        }
        
        UIView.animate(withDuration: 0.25) {
            self.contentView.updateLayout()
        }
        
        self.resizingDelegate?.cellResized()
    }
    
    func rotateCaret() {
        caretButton.isEnabled = false

        UIView.animate(withDuration: 0.25, animations: {
            let angle = self.isExpanded ? 0 : CGFloat.pi
            self.caretButton.transform = CGAffineTransform(rotationAngle: angle)
        }, completion: { _ in
            self.caretButton.isEnabled = true
        })
    }
    
    @IBAction func caretPressed(_ sender: Any) {
        isExpanded = !isExpanded
        
        if isExpanded {
            expand()
        } else {
            collapse()
        }
    }
}
