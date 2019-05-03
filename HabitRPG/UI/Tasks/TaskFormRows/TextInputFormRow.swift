//
//  TextInputFormRow.swift
//  Habitica
//
//  Created by Phillip Thelen on 21.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Eureka
import PinLayout

public class TaskTextInputCell: Cell<String>, CellType, UITextViewDelegate {
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var textViewBackgroundView: UIView!
    
    private var topSpacing: CGFloat = 0
    private var bottomSpacing: CGFloat = 0
    
    public override func setup() {
        super.setup()
        textField.delegate = self
        selectionStyle = .none

    }

    public override func update() {
        titleLabel.text = row.title
        if textField.text != row.value {
            textField.text = row.value
        }
        
        if let taskRow = row as? TaskTextInputRow {
            cellBackgroundView.backgroundColor = taskRow.tintColor
            textField.tintColor = taskRow.tintColor.lighter(by: 10)
            titleLabel.textColor = UIColor(white: 1, alpha: 0.7)
            //textField.attributedPlaceholder = NSAttributedString(string: taskRow.placeholder ?? "", attributes: [NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.5)])
            topSpacing = taskRow.topSpacing
            bottomSpacing = taskRow.bottomSpacing
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        row.value = textView.text
        DispatchQueue.main.async {[weak self] in
            self?.row.updateCell()
        }
    }
   
    private func layout() {
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: bounds.size.width)
        
        titleLabel.pin.horizontally(26).top(topSpacing).sizeToFit(.width)
        textViewBackgroundView.pin.below(of: titleLabel).marginTop(4).horizontally(16)
        textField.pin.top(4).horizontally(10).sizeToFit(.width)
        textViewBackgroundView.pin.height(textField.frame.size.height + 8)
        cellBackgroundView.pin.top(-2).horizontally().height(textViewBackgroundView.frame.origin.y + textViewBackgroundView.frame.size.height + bottomSpacing + 4)
        pin.height(cellBackgroundView.frame.size.height - 4)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)
        layout()
        return CGSize(width: contentView.frame.width, height: textViewBackgroundView.frame.height + textViewBackgroundView.frame.origin.y + bottomSpacing)
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
