//
//  StatsView.swift
//  Habitica
//
//  Created by Phillip Thelen on 28.11.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class AllocateButton: UIView {
    var onAllocate: (() -> Void)?
    var statColor: UIColor = .purple400

    private let plusOneLabel: UILabel = {
        let label = UILabel()
        label.text = "+1"
        label.font = .boldSystemFont(ofSize: 22)
        return label
    }()
    private let arrowView = UIImageView(image: Asset.allocateArrow.image)

    override var tintColor: UIColor! {
        didSet {
            plusOneLabel.textColor = tintColor
            arrowView.tintColor = tintColor
            statColor = tintColor
        }
    }

    var secondTintColor: UIColor = .tintColor

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        addSubview(plusOneLabel)
        addSubview(arrowView)
        clipsToBounds = false
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIView.animate(withDuration: 1, delay: 1, options: [.repeat, .autoreverse]) {
                self.arrowView.tintColor = self.secondTintColor
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        plusOneLabel.pin.sizeToFit().vCenter()
        arrowView.pin.sizeToFit().vCenter()
        let totalWidth = plusOneLabel.frame.width + arrowView.frame.width + 8
        let left = (frame.size.width - totalWidth) / 2
        plusOneLabel.pin.left(left)
        arrowView.pin.right(of: plusOneLabel).marginLeft(8)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 97, height: 43)
    }

    private let squashScale: CGFloat = 0.85
    private let popScale: CGFloat = 1.12
    private let squashVerticalCompression: CGFloat = 0.9

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        StatAllocationHaptics.shared.prepare()

        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            options: .allowUserInteraction
        ) {
            let squashTransform = CGAffineTransform(scaleX: self.squashScale, y: self.squashScale * self.squashVerticalCompression)
            self.plusOneLabel.transform = squashTransform
            self.arrowView.transform = squashTransform
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.85)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            options: .allowUserInteraction
        ) {
            self.plusOneLabel.transform = CGAffineTransform(scaleX: self.popScale, y: self.popScale)
            self.arrowView.transform = CGAffineTransform(scaleX: self.popScale, y: self.popScale)
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(1)
        } completion: { _ in
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: .allowUserInteraction
            ) {
                self.plusOneLabel.transform = .identity
                self.arrowView.transform = .identity
            }
        }

        if let action = onAllocate {
            StatAllocationHaptics.shared.triggerAllocationHaptic()

            let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
            let particleCount = StatAllocationHaptics.shared.currentTapVelocity > 5 ? 12 : 8
            StatParticleEmitter.createBurst(at: centerPoint, in: self, color: statColor, count: particleCount)
            addGlowPulse(color: statColor)

            action()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.3,
            options: .allowUserInteraction
        ) {
            self.plusOneLabel.transform = .identity
            self.arrowView.transform = .identity
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(1)
        }
    }
}

@IBDesignable
class StatsView: UIView, Themeable {
    
    @IBOutlet private weak var topBackground: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var totalValueLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet private weak var levelValueLabel: UILabel!
    @IBOutlet weak var equipmentLabel: UILabel!
    @IBOutlet private weak var equipmentValueLabel: UILabel!
    @IBOutlet weak var buffsLabel: UILabel!
    @IBOutlet private weak var buffsValueLabel: UILabel!
    @IBOutlet private weak var allocatedValueLabel: UILabel!
    @IBOutlet private weak var allocatedLabel: UILabel!
    @IBOutlet private weak var allocatedBackgroundView: UIView!
    @IBOutlet private weak var allocateButton: AllocateButton!
    @IBOutlet weak var topBarTrailingConstraint: NSLayoutConstraint!
    
    private var containedView: UIView?
    
    @IBInspectable var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    @IBInspectable var attributeBackgroundColor: UIColor? {
        didSet {
            topBackground.backgroundColor = attributeBackgroundColor
        }
    }
    @IBInspectable var attributeTextColor: UIColor? {
        didSet {
            titleLabel.textColor = attributeTextColor
            totalValueLabel.textColor = attributeTextColor
        }
    }
    @IBInspectable var allocateButtonBackgroundColor: UIColor?
    @IBInspectable var allocateButtonTextColor: UIColor? {
        didSet {
            allocateButton.tintColor = allocateButtonTextColor
        }
    }
    @IBInspectable var allocateButtonSecondColor: UIColor = .tintColor {
        didSet {
            allocateButton.secondTintColor = allocateButtonSecondColor
        }
    }

    var totalValue: Int = -1 {
        didSet {
            if oldValue != totalValue && oldValue != -1 {
                animateValueChange(label: totalValueLabel, from: oldValue, to: totalValue)
            } else {
                totalValueLabel.text = String(totalValue)
            }
        }
    }

    private func animateValueChange(label: UILabel, from oldValue: Int, to newValue: Int) {
        let effectColor = attributeTextColor ?? .purple400
        label.addSunburstEffect(color: effectColor, dotCount: 10)

        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            options: .allowUserInteraction
        ) {
            label.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            label.text = String(newValue)

            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: .allowUserInteraction
            ) {
                label.transform = .identity
            }
        }
    }
    
    var levelValue: Int = 0 {
        didSet {
            levelValueLabel.text = String(levelValue)
        }
    }
    var equipmentValue: Int = 0 {
        didSet {
            equipmentValueLabel.text = String(equipmentValue)
        }
    }
    var buffValue: Int = 0 {
        didSet {
            buffsValueLabel.text = String(buffValue)
        }
    }
    var allocatedValue: Int = -1 {
        didSet {
            if oldValue != allocatedValue && oldValue != -1 {
                animateValueChange(label: allocatedValueLabel, from: oldValue, to: allocatedValue)
            } else {
                allocatedValueLabel.text = String(allocatedValue)
            }
        }
    }
    
    var canAllocatePoints: Bool = false {
        didSet {
            allocateButton.isHidden = !canAllocatePoints
            let theme = ThemeService.shared.theme
            if canAllocatePoints {
                allocateButton.backgroundColor = allocateButtonBackgroundColor
                topBarTrailingConstraint.constant = 0
            } else {
                allocateButton.backgroundColor = theme.windowBackgroundColor
                topBarTrailingConstraint.constant = 26
            }
        }
    }
    
    var allocateAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 154, height: 36))
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        if let view = viewFromNibForClass() {
            containedView = view
            translatesAutoresizingMaskIntoConstraints = false
            
            view.frame = bounds
            addSubview(view)
            
            levelLabel.text = L10n.level
            equipmentLabel.text = L10n.Equipment.equipment
            buffsLabel.text = L10n.buffs
            allocatedLabel.text = L10n.allocated
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
                                    
            allocateButton.onAllocate = {
                self.allocateButtonTapped()
            }
            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        backgroundColor = theme.contentBackgroundColor
        containedView?.backgroundColor = theme.contentBackgroundColorDimmed
        levelLabel.textColor = theme.secondaryTextColor
        levelValueLabel.textColor = theme.secondaryTextColor
        equipmentLabel.textColor = theme.secondaryTextColor
        equipmentValueLabel.textColor = theme.secondaryTextColor
        buffsLabel.textColor = theme.secondaryTextColor
        buffsValueLabel.textColor = theme.secondaryTextColor
        allocatedLabel.textColor = theme.secondaryTextColor
        allocatedValueLabel.textColor = theme.secondaryTextColor
    }
    
    @objc
    func allocateButtonTapped() {
        if let action = allocateAction {
            action()
        }
    }
}
