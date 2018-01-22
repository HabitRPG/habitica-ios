//
//  ChallengeCategoriesTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/25/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class ChallengeCategoriesTableViewCell: ResizableTableViewCell, ChallengeConfigurable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var caretButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var categories: [String]?
    var categoryLabels: [UILabel]?
    
    private var isExpanded = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collapse()
    }
    
    func configure(with challenge: Challenge) {
        
    }
    
    func addCategories() {
        var aboveView: UIView = titleLabel
        if let categories = categories {
            for category in categories {
                let label = createCategoryLabel(category)
                contentView.addSubview(label)
                contentView.addConstraint(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: aboveView, attribute: .bottom, multiplier: 1, constant: 8))
                contentView.addConstraint(NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 16))
                aboveView = label
            }
        }
        contentView.addConstraint(NSLayoutConstraint(item: aboveView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 8))
    }
    
    func createCategoryLabel(_ category: String) -> UILabel {
        let label = emptyTagLabel()
        label.text = "  \(category)  "
        label.textColor = UIColor.gray200()
        label.backgroundColor = UIColor.gray600()
        label.sizeToFit()
        return label
    }
    
    func emptyTagLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.cornerRadius = 11
        return label
    }
    
    func expand() {
        rotateCaret()
        
        self.contentView.removeConstraint(bottomConstraint)
        
        self.resizingDelegate?.cellResized()
    }
    
    func collapse() {
        rotateCaret()
        
        self.contentView.addConstraint(bottomConstraint)
        
        self.resizingDelegate?.cellResized()
    }
    
    func rotateCaret() {
        let angle = self.isExpanded ? 0 : CGFloat.pi
        self.caretButton.transform = CGAffineTransform(rotationAngle: angle)
//        caretButton.isEnabled = false
//
//        UIView.animate(withDuration: 0.5, animations: {
//            let angle = self.isExpanded ? 0 : CGFloat.pi
//            self.caretButton.transform = CGAffineTransform(rotationAngle: angle)
//        }, completion: { _ in
//            self.caretButton.isEnabled = true
//        })
    }
    
    @IBAction func caretPressed() {
        isExpanded = !isExpanded
        
        if isExpanded {
            expand()
        } else {
            collapse()
        }
    }
    
}
