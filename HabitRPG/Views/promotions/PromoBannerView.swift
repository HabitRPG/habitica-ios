//
//  PromoBannerView.swift
//  Habitica
//
//  Created by Phillip Thelen on 01.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

class PromoBannerView: UIView {
    
    var onTapped: (() -> Void)?
    
    let titleView: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledSystemFont(ofSize: 20, ofWeight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    let titleImageView = UIImageView()
    let descriptionImageView = UIImageView()
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledSystemFont(ofSize: 10, ofWeight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15, ofWeight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    let leftImageView = UIImageView()
    let rightImageView = UIImageView()
    
    func setTitle(_ title: String) {
        titleView.isHidden = false
        titleView.text = title
    }
    
    func setTitleImage(_ image: UIImage) {
        titleImageView.isHidden = false
        titleImageView.image = image
    }
    
    func setDescriptionImage(_ image: UIImage) {
        descriptionImageView.isHidden = false
        descriptionImageView.image = image
    }
    
    func setDescription(_ text: String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: 1.8, range: NSRange(location: 0, length: attributedString.length))
        descriptionLabel.attributedText = attributedString
        descriptionLabel.isHidden = false
    }
    
    func setDuration(_ duration: String) {
        durationLabel.isHidden = false
        durationLabel.text = duration
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(rightImageView)
        addSubview(leftImageView)
        addSubview(titleView)
        addSubview(titleImageView)
        addSubview(descriptionLabel)
        addSubview(durationLabel)
        addSubview(descriptionImageView)
        
        titleView.isHidden = true
        titleImageView.isHidden = true
        durationLabel.isHidden = true
        descriptionImageView.isHidden = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(wasTapped)))
        
        cornerRadius = 8
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        leftImageView.pin.sizeToFit().start().bottom()
        rightImageView.pin.sizeToFit().end().bottom()
        var upperEdge = edge.top
        if !titleView.isHidden {
            titleView.pin.top(to: upperEdge).marginTop(20).start(60).end(60).sizeToFit(.width)
            upperEdge = titleView.edge.bottom
        }
        if !titleImageView.isHidden {
            titleImageView.pin.top(to: upperEdge).marginTop(20).sizeToFit().hCenter()
            upperEdge = titleImageView.edge.bottom
        }
        if !descriptionLabel.isHidden {
            descriptionLabel.pin.top(to: upperEdge).marginTop(12).start(60).end(60).sizeToFit(.width)
            upperEdge = descriptionLabel.edge.bottom
        }
        if !descriptionImageView.isHidden {
            descriptionImageView.pin.top(to: upperEdge).marginTop(8).sizeToFit().hCenter()
            upperEdge = descriptionImageView.edge.bottom
        }
        if !durationLabel.isHidden {
            durationLabel.pin.top(to: upperEdge).start(34).end(34).marginTop(8).maxWidth(400).sizeToFit(.width)
            upperEdge = durationLabel.edge.bottom
        }
    
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach {
            $0.frame = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
        }
        leftImageView.pin.start().bottom()
        rightImageView.pin.end().bottom()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 148)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = CGSize(width: size.width, height: 148)
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: size.width, height: size.height)
        layout()
        return size
    }

    @objc
    private func wasTapped() {
        if let action = onTapped {
            action()
        }
    }
}
