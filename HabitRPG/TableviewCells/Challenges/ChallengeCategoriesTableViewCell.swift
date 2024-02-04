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
    
    func configure(with challenge: ChallengeProtocol, userID: String?) {
        categories = challenge.categories.map { $0.name ?? "" }
        if isExpanded {
            contentView.removeConstraint(bottomConstraint)
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
        label.text = "  \(localizedCategoryNameFor(name: category))  "
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
        
        contentView.removeConstraint(bottomConstraint)
        addCategories()
        
        resizingDelegate?.cellResized()
    }
    
    func collapse() {
        rotateCaret()
        
        removeOldCategoryViews()
        categoryViews = []
        contentView.addConstraint(bottomConstraint)
        contentView.updateLayout()
        
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
    
    func localizedCategoryNameFor(name: String) -> String {
        return switch name {
        case "habitica_official": L10n.ChallengeCategory.habiticaOfficial
        case "academics": L10n.ChallengeCategory.academics
        case "advocacy_causes": L10n.ChallengeCategory.advocacyCauses
        case "creativity": L10n.ChallengeCategory.creativity
        case "entertainment": L10n.ChallengeCategory.entertainment
        case "finance": L10n.ChallengeCategory.finance
        case "health_fitness": L10n.ChallengeCategory.healthFitness
        case "hobbies_occupations": L10n.ChallengeCategory.hobbiesOccupations
        case "location_based": L10n.ChallengeCategory.locationBased
        case "mental_health": L10n.ChallengeCategory.mentalHealth
        case "getting_organized": L10n.ChallengeCategory.gettingOrganized
        case "recovery_support_groups": L10n.ChallengeCategory.recoverySupportGroups
        case "self_improvement": L10n.ChallengeCategory.selfImprovement
        case "spirituality": L10n.ChallengeCategory.spirituality
        case "time_management": L10n.ChallengeCategory.timeManagement
        default: name
        }
    }
    
}
