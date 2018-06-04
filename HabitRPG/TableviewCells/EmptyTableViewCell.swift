//
//  EmptyTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 5/31/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstParagraphLabel: UILabel!
    @IBOutlet weak var secondParagraphLabel: UILabel!
    
    static func habitsStyle(cell: EmptyTableViewCell) {
        cell.titleLabel.text = "These are your Habits"
        cell.firstParagraphLabel.text = "Habits don't have a rigid schedule. You can check them off multiple times per day."
        cell.secondParagraphLabel.text = ""
    }
    
    static func dailiesStyle(cell: EmptyTableViewCell) {
        cell.titleLabel.text = "These are your Dailies"
        cell.firstParagraphLabel.text = "To-Dos need to be completed once. Add checklists to your To-Dos to increase their value."
        cell.secondParagraphLabel.text = ""
    }
    
    static func todoStyle(cell: EmptyTableViewCell) {
        cell.titleLabel.text = "These are your To-Dos"
        cell.firstParagraphLabel.text = "To-Dos need to be completed once. Add checklists to your To-Dos to increase their value."
        cell.secondParagraphLabel.text = ""
    }
    
    static func rewardsStyle(cell: EmptyTableViewCell) {
        cell.titleLabel.text = "These are your Rewards"
        cell.firstParagraphLabel.text = "Rewards are a great way to use Habitica and complete your tasks. Try adding a few today!"
        cell.secondParagraphLabel.text = ""
    }
}
