//
//  LabeledCheckboxView.swift
//  Habitica
//
//  Created by Phillip Thelen on 15/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

@IBDesignable
class LabeledCheckboxView: UILabel {

    let edgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)

    private let checkboxView = UIImageView()

    var checkedAction: ((Bool) -> Void)?

    @IBInspectable var isChecked: Bool = false {
        didSet {
            updateCheckbox()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        checkboxView.contentMode = .center
        addSubview(checkboxView)
        updateCheckbox()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        gestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(gestureRecognizer)
        isUserInteractionEnabled = true
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: edgeInsets))
    }

    override var intrinsicContentSize: CGSize {
            var size = super.intrinsicContentSize
            size.width += self.edgeInsets.left + edgeInsets.right
            size.height += self.edgeInsets.top + edgeInsets.bottom
            return size
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        checkboxView.frame = CGRect(x: 0, y: 0, width: 20, height: frame.size.height)
    }

    func updateCheckbox() {
        if isChecked {
            checkboxView.image = #imageLiteral(resourceName: "checkbox_checked").withRenderingMode(.alwaysTemplate)
        } else {
            checkboxView.image = #imageLiteral(resourceName: "checkbox_unchecked")
        }
    }

    @objc
    func tapped() {
        isChecked = !isChecked
        if let action = checkedAction {
            action(isChecked)
        }
    }
}
