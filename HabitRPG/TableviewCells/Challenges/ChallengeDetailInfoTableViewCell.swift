//
//  ChallengeDetailInfoTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/24/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class ChallengeDetailInfoTableViewCell: UITableViewCell, ChallengeConfigurable {
    @IBOutlet weak var challengeTitleLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var rewardCurrencyCountView: HRPGCurrencyCountView!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var tagHolderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rewardCurrencyCountView.currency = .gem
        rewardCurrencyCountView.viewSize = .large
    }
    
    func configure(with challenge: Challenge) {
        challengeTitleLabel.text = challenge.name?.unicodeEmoji
        rewardCurrencyCountView.amount = challenge.prize?.intValue ?? 0
        participantsLabel.text = "\(challenge.memberCount?.intValue ?? 0)"
        
        tagHolderView.translatesAutoresizingMaskIntoConstraints = false
        addTags(for: challenge)
    }
    
    func addTags(for challenge: Challenge) {
        for view in tagHolderView.subviews {
            view.removeFromSuperview()
        }
        
        var tags: [UILabel] = []
        
        if Challenge.isOwner(of: challenge) {
            tags.append(ownerTag())
        }
        if let isOfficial = challenge.official?.boolValue, isOfficial {
            tags.append(officialTag())
        }
        if challenge.user != nil {
            tags.append(joinedTag())
        }
        if let shortName = challenge.shortName {
            tags.append(nameTag(shortName))
        }
        
        for (index, tag) in tags.enumerated() {
            tagHolderView.addSubview(tag)
            
            tag.translatesAutoresizingMaskIntoConstraints = false
            tag.addHeightConstraint(height: 22)
            tag.updateLayout()
            
            if index == 0 {
                tagHolderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tag]", options: .init(rawValue: 0), metrics: nil, views: ["tag": tag]))
            } else {
                let previousTag = tags[index-1]
                tagHolderView.addConstraint(NSLayoutConstraint(item: tag, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: previousTag, attribute: .trailing, multiplier: 1.0, constant: 8))
            }
            
            tagHolderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tag]-0-|", options: .init(rawValue: 0), metrics: nil, views: ["tag": tag]))
            
            if index == tags.count - 1 {
                tagHolderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[tag]-0-|", options: .init(rawValue: 0), metrics: nil, views: ["tag": tag]))
            }
        }
        
        tagHolderView.updateLayout()
        
        contentView.updateLayout()
    }
    
    func ownerTag() -> UILabel {
        let label = emptyTagLabel()
        label.text = "  Owner  "
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.blue50()
        return label
    }
    
    func officialTag() -> UILabel {
        let label = emptyTagLabel()
        label.text = "  Official  "
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.purple300()
        
        return label
    }
    
    func joinedTag() -> UILabel {
        let label = emptyTagLabel()
        label.text = "  Joined  "
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.green100()
        
        return label
    }
    
    func nameTag(_ shortName: String) -> UILabel {
        let label = emptyTagLabel()
        label.text = "  \(shortName.unicodeEmoji)  "
        label.textColor = UIColor.gray200()
        label.backgroundColor = UIColor.gray600()
        
        return label
    }
    
    func emptyTagLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.cornerRadius = 11
        return label
    }
}

extension UIView {
    func updateLayout() {
        self.setNeedsUpdateConstraints()
        self.updateConstraints()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func addHeightConstraint(height: CGFloat) {
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
    }
}
