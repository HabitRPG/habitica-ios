//
//  AdventureGuidePromoView.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.06.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
class AdventureGuideBannerView: UIView, Themeable {
    
    var onTapped: (() -> Void)?
    
    private let container: UIView = {
        let view = UIView()
        view.cornerRadius = 8
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.text = L10n.onboardingTasks
        return label
    }()
    
    private let completeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .yellow10
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        let transform = CGAffineTransform(scaleX: 1, y: 2)
        progressView.transform = transform
        progressView.cornerRadius = 2
        return progressView
    }()
        
    private let leftImage = UIImageView(image: Asset.onboardingGoldLeft.image)
    private let rightImage = UIImageView(image: Asset.onboardingGoldRight.image)
    
    private let rightIndicator: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.image = Asset.caretRight.image
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        addSubview(leftImage)
        leftImage.contentMode = .bottom
        addSubview(rightImage)
        rightImage.contentMode = .bottom
        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(completeLabel)
        container.addSubview(progressLabel)
        container.addSubview(progressView)
        container.addSubview(rightIndicator)
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        titleLabel.textColor = theme.primaryTextColor
        let attrString = NSMutableAttributedString(string: L10n.completeToEarnGold)
        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: theme.primaryTextColor, range: NSRange(location: 0, length: attrString.length))
        attrString.addAttributesToSubstring(string: L10n.hundredGold, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.yellow10
        ])
        completeLabel.attributedText = attrString
        backgroundColor = theme.navbarHiddenColor
        if theme.isDark {
            container.backgroundColor = theme.windowBackgroundColor
            rightIndicator.backgroundColor = theme.offsetBackgroundColor
        } else {
            container.backgroundColor = theme.contentBackgroundColor
            rightIndicator.backgroundColor = theme.windowBackgroundColor
        }
        progressView.backgroundColor = theme.offsetBackgroundColor
        progressView.tintColor = .yellow50
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        leftImage.pin.start().top().bottom().width(73)
        rightImage.pin.end().top().bottom().width(75)
        container.pin.all(12)
        rightIndicator.pin.top().bottom().right().width(29)
        titleLabel.pin.top(8).start(16).end(16).sizeToFit(.width)
        progressLabel.pin.below(of: titleLabel).before(of: rightIndicator).marginRight(16).sizeToFit()
        completeLabel.pin.below(of: titleLabel).marginTop(4).start(16).end(16).sizeToFit()
        progressView.pin.start(16).before(of: rightIndicator).marginRight(16).bottom(16).height(4)
    }
    
    func setProgress(earned: Int, total: Int) {
        progressLabel.text = "\(earned) / \(total)"
        progressView.setProgress(Float(earned) / Float(total), animated: false)
        setNeedsLayout()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 100, height: 81)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 81)
    }
    
    @objc
    private func viewTapped() {
        onTapped?()
    }
}
