//
//  TextInputFormRow.swift
//  Habitica
//
//  Created by Phillip Thelen on 21.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Eureka

public class TaskTextInputCell: Cell<String>, CellType {
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var topSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSpacingConstraint: NSLayoutConstraint!
    
    public override func setup() {
        super.setup()
    }

    public override func update() {
        titleLabel.text = row.title
        
        if let taskRow = row as? TaskTextInputRow {
            cellBackgroundView.backgroundColor = taskRow.tintColor
            textField.tintColor = taskRow.tintColor.lighter(by: 10)
            //textField.attributedPlaceholder = NSAttributedString(string: taskRow.placeholder ?? "", attributes: [NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.5)])
            topSpacingConstraint.constant = taskRow.topSpacing
            bottomSpacingConstraint.constant = taskRow.bottomSpacing
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: bounds.size.width)
    }
}

final class TaskTextInputRow: TaskRow<TaskTextInputCell>, RowType {
    
    var placeholder: String?
    var topSpacing: CGFloat = 0
    var bottomSpacing: CGFloat = 0
    
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<TaskTextInputCell>(nibName: "TaskTextInputCell")
    }
}
