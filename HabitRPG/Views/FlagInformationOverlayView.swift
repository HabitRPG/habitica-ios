//
//  FlagInformationOverlayView.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.09.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation
import Down

class FlagInformationOverlayView: UIView {
    
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var messageView: UILabel!
    @IBOutlet weak var explanationView: UILabel!
    
    var message: String? {
        didSet {
            messageView.attributedText = try? Down(markdownString: message?.unicodeEmoji ?? "").toHabiticaAttributedString(baseSize: 15, textColor: ThemeService.shared.theme.primaryTextColor)
            explanationView.textColor = ThemeService.shared.theme.secondaryTextColor
            messageContainerView.borderColor = ThemeService.shared.theme.separatorColor
            setNeedsLayout()
        }
    }
}
