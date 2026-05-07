//
//  HRPGShopSectionHeaderCollectionReusableView.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/1/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class HRPGShopSectionHeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gearCategoryButton: UIButton!
    @IBOutlet weak var dropdownIconView: UIImageView!
    @IBOutlet weak var otherClassDisclaimer: UILabel!
    @IBOutlet weak var swapsInLabel: UILabel!
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var lowerBackgroundView: UIView!
    
    @IBOutlet weak var rightSparkleView: UIImageView!
    @IBOutlet weak var leftSparkleView: UIImageView!
    var onGearCategoryChanged: ((String) -> Void)?
        
    @IBOutlet weak var changeClassWrapper: UIView!
    @IBOutlet weak var changeClassTitle: UILabel!
    @IBOutlet weak var changeClassSubtitle: UILabel!
    @IBOutlet weak var changeClassPriceLabel: CurrencyCountView!
    
    lazy var notesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 13, weight: .semibold))
        label.textColor = .yellow1
        label.textAlignment = .center
        label.numberOfLines = 0
        addSubview(label)
        return label
    }()

    var newClassName: String?
    var onClassChange: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .white
        swapsInLabel.textColor = .white
        
        backgroundView.layer.cornerRadius = UIConstants.mediumCornerRadius
        lowerBackgroundView.layer.cornerRadius = UIConstants.mediumCornerRadius - 3
        lowerBackgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        changeClassPriceLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeClassTapped)))
        
        gearCategoryButton.menu = UIMenu(children: [
            UIAction(title: L10n.Classes.warrior, image: HabiticaIcons.imageOfWarriorLightBg) { _ in
                if let action = self.onGearCategoryChanged {
                    action("warrior")
                }
            },
            UIAction(title: L10n.Classes.mage, image: HabiticaIcons.imageOfMageLightBg) { _ in
                if let action = self.onGearCategoryChanged {
                    action("mage")
                }
            },
            UIAction(title: L10n.Classes.healer, image: HabiticaIcons.imageOfHealerLightBg) { _ in
                if let action = self.onGearCategoryChanged {
                    action("healer")
                }
            },
            UIAction(title: L10n.Classes.rogue, image: HabiticaIcons.imageOfRogueLightBg) { _ in
                if let action = self.onGearCategoryChanged {
                    action("rogue")
                }
            },
            UIAction(title: L10n.Tasks.Form.none) { _ in
                if let action = self.onGearCategoryChanged {
                    action("none")
                }
            }
        ])
        gearCategoryButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        gearCategoryButton.titleLabel?.textAlignment = .natural
        gearCategoryButton.showsMenuAsPrimaryAction = true
    }
    
    @objc
    private func changeClassTapped() {
        let dialog = HabiticaAlertController(title: L10n.classChangeConfirm(newClassName ?? ""), message: L10n.classChangeConfirmDescription)
        dialog.addAction(title: L10n.Settings.changeClass, isMainAction: true) { _ in
            if let action = self.onClassChange {
                action()
            }
        }
        dialog.addCloseAction()
        dialog.show()
    }
    
    func hideSecondRow() {
        separatorView.isHidden = true
        lowerBackgroundView.isHidden = true
        swapsInLabel.isHidden = true
        gearCategoryButton.isHidden = true
        dropdownIconView.isHidden = true
    }
    
    func setSecondRow(dates: Set<Date>) {
        separatorView.isHidden = false
        lowerBackgroundView.isHidden = false
        swapsInLabel.isHidden = false
        gearCategoryButton.isHidden = true
        dropdownIconView.isHidden = true
        guard let date = dates.min() else {
            return
        }
        if date > Date() && dates.count > 1 {
            swapsInLabel.text = L10n.nextSwitchInX(date.getImpreciseRemainingString())
        } else if date > Date() {
            swapsInLabel.text = L10n.swapsInX(date.getImpreciseRemainingString())
        } else {
            swapsInLabel.text = L10n.refreshForItems
        }
        lowerBackgroundView.backgroundColor = .purple300
    }
    
    func setSecondRow(className: String, classColor: UIColor) {
        separatorView.isHidden = false
        lowerBackgroundView.isHidden = false
        swapsInLabel.isHidden = true
        gearCategoryButton.isHidden = false
        dropdownIconView.isHidden = false
        gearCategoryButton.setTitle(className, for: .normal)
        lowerBackgroundView.backgroundColor = classColor
        gearCategoryButton.setTitleColor(classColor.isLight() ? .gray50 : .white, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let topOffset = 0.0
        let horizontalPadding = 12.0 + safeAreaInsets.left
        let horizontalPaddingEnd = 12.0 + safeAreaInsets.right
        let verticalPadding = 8.0
        titleLabel.pin.start(horizontalPadding + 24).end(horizontalPaddingEnd + 24).top(topOffset+verticalPadding).sizeToFit(.width)
        leftSparkleView.pin.start(horizontalPadding + 16).vCenter(to: titleLabel.edge.vCenter)
        rightSparkleView.pin.end(horizontalPaddingEnd + 16).vCenter(to: titleLabel.edge.vCenter)

        var height = titleLabel.bounds.size.height + verticalPadding*2
        if !separatorView.isHidden || !lowerBackgroundView.isHidden {
            separatorView.pin.start(horizontalPadding).end(horizontalPaddingEnd).top(topOffset+height - 3).height(3)
            lowerBackgroundView.pin.start(horizontalPadding + 3).end(horizontalPaddingEnd + 3).top(topOffset+height).height(height-8)
            height *= 2
            height -= 5
        }
        if !swapsInLabel.isHidden {
            swapsInLabel.pin.start(horizontalPadding + 12).end(horizontalPaddingEnd).top(topOffset+height/2).height(height/2)
        }
        if !gearCategoryButton.isHidden {
            gearCategoryButton.pin.start(horizontalPadding + 12).end(horizontalPaddingEnd).top(topOffset+height/2).height(height/2)
        }
        if !dropdownIconView.isHidden {
            dropdownIconView.pin.end(horizontalPaddingEnd + 16).vCenter(to: lowerBackgroundView.edge.vCenter).width(10).height(7)
        }
        backgroundView.pin.start(horizontalPadding).end(horizontalPaddingEnd).top(topOffset).height(height)

        if !otherClassDisclaimer.isHidden {
            otherClassDisclaimer.pin.below(of: backgroundView).marginTop(12).start(horizontalPadding).end(horizontalPaddingEnd).sizeToFit(.width)
        }

        if !changeClassWrapper.isHidden {
            changeClassWrapper.pin.below(of: otherClassDisclaimer).marginTop(6).start(horizontalPadding).end(horizontalPaddingEnd).height(60)
        }

        if !notesLabel.isHidden, notesLabel.text?.isEmpty == false {
            notesLabel.pin.below(of: backgroundView).marginTop(8).start(horizontalPadding).end(horizontalPaddingEnd).sizeToFit(.width)
        }
    }
}
