//
//  SystemMessageTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class SystemMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageWrapper: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageTextView.textContainerInset = UIEdgeInsets.zero
    }
    
    @objc
    func configure(chatMessage: ChatMessageProtocol) {
        messageTextView.text = chatMessage.text?.unicodeEmoji.replacingOccurrences(of: "`", with: "")
        
        applyTheme(theme: ThemeService.shared.theme)
    }
    
    func applyTheme(theme: Theme) {
        backgroundColor = theme.windowBackgroundColor
        contentView.backgroundColor = theme.windowBackgroundColor
        messageTextView.textColor = theme.tintColor
    }
}
