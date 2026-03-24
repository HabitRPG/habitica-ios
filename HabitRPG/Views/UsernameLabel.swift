//
//  UsernameLabel.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftUI

class UsernameLabel: UILabel {
    @objc public var contributorLevel: Int = 0 {
        didSet {
            if ThemeService.shared.theme.isDark {
                textColor = UIColor.lightContributorColor(forTier: contributorLevel)
            } else {
                textColor = UIColor.contributorColor(forTier: contributorLevel)
            }
            iconView.image = HabiticaIcons.imageOfContributorBadge(tier: contributorLevel, isNPC: false)
        }
    }
    
    private let iconView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
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
        font = UIFont.systemFont(ofSize: 15.0)
        addSubview(iconView)
        self.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        iconView.frame = CGRect(x: self.frame.size.width - 16, y: self.frame.size.height/2-8, width: 16, height: 16)
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if contributorLevel > 0 {
            size.width += 18
        }
        return size
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let paddedSize = CGSize(width: size.width - 18, height: size.height)
        var newSize = super.sizeThatFits(paddedSize)
        if contributorLevel > 0 {
            newSize.width += 18
        }
        return newSize
    }
}

struct UsernameLabelUI: View {
    @ObservedObject var themeService = ThemeService.shared
    let name: String
    var level: Int = 0
    
    private var textColor: UIColor {
        if themeService.theme.isDark {
            return UIColor.lightContributorColor(forTier: level)
        } else {
            return UIColor.contributorColor(forTier: level)
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            Text(name).foregroundStyle(Color(textColor))
            if level > 0 {
                Image(uiImage: HabiticaIcons.imageOfContributorBadge(tier: level, isNPC: false)).frame(width: 16, height: 16)
            }
        }
    }
}
