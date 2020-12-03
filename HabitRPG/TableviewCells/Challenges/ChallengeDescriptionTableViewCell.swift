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
    
    func configure(with challenge: ChallengeProtocol, userID: String?) {
        if let notes = challenge.notes {
            descriptionLabel.attributedText = try? Down(markdownString: notes.unicodeEmoji).toHabiticaAttributedString(baseSize: descriptionLabel.font.pointSize)
        }
    }
    
    func expand() {
        rotateCaret()
        
        marginConstraint.constant = 8
        if let constraint = self.heightConstraint {
            descriptionLabel.removeConstraint(constraint)
        }
        
        resizingDelegate?.cellResized()
    }
    
    func collapse() {
        rotateCaret()
        
        self.marginConstraint.constant = 0
        if heightConstraint == nil, let label = descriptionLabel {
            heightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.height, relatedBy: .equal,
                                                       toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        }
        
        if let constraint = self.heightConstraint {
            descriptionLabel.addConstraint(constraint)
        }
        
        UIView.animate(withDuration: 0.25) {[weak self] in
            self?.contentView.updateLayout()
        }
        
        resizingDelegate?.cellResized()
    }
    
    func rotateCaret() {
        caretButton.isEnabled = false

        UIView.animate(withDuration: 0.25, animations: {[weak self] in
            let angle = self?.isExpanded == true ? 0 : CGFloat.pi
            self?.caretButton.transform = CGAffineTransform(rotationAngle: angle)
        }, completion: {[weak self] _ in
            self?.caretButton.isEnabled = true
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
