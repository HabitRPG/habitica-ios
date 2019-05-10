//
//  ChallengeCategoriesTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/25/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class ChallengeCategoriesTableViewCell: ResizableTableViewCell, ChallengeConfigurable {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var caretButton: UIButton!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    var categories: [String]?
    var categoryViews: [UIView] = []
    
    private var isExpanded = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with challenge: ChallengeProtocol) {
        categories = challenge.categories.map { $0.name ?? "" }
        if isExpanded {
            self.contentView.removeConstraint(bottomConstraint)
            removeOldCategoryViews()
            addCategories()
            contentView.updateLayout()
        }
    }
    
    func addCategories() {
        var aboveView: UIView = titleLabel
        if let categories = categories {
            for category in categories {
                let label = createCategoryLabel(category)
                contentView.addSubview(label)
                contentView.addConstraint(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: aboveView, attribute: .bottom, multiplier: 1, constant: 8))
                contentView.addConstraint(NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 16))
                categoryViews.append(label)
                aboveView = label
            }
        }
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: aboveView,
                                                     attribute: .bottom, multiplier: 1, constant: bottomConstraint.constant))
    }
    
    func createCategoryLabel(_ category: String) -> UILabel {
        let label = emptyTagLabel()
        label.text = "  \(category)  "
        label.textColor = ThemeService.shared.theme.ternaryTextColor
        label.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }
    
    func emptyTagLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.cornerRadius = 8
        return label
    }
    
    func expand() {
        rotateCaret()
        
        self.contentView.removeConstraint(bottomConstraint)
        addCategories()
        
        self.resizingDelegate?.cellResized()
    }
    
    func collapse() {
        rotateCaret()
        
        removeOldCategoryViews()
        categoryViews = []
        self.contentView.addConstraint(bottomConstraint)
        self.contentView.updateLayout()
        
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
    
    func removeOldCategoryViews() {
        for view in categoryViews {
            view.removeFromSuperview()
        }
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
