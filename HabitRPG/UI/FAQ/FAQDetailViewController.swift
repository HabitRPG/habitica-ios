//
//  FAQDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift
import Down

class FAQDetailViewController: BaseUIViewController {
    
    var index: Int = 0
    
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var questionLabel: UILabel!
    
    private let contentRepository = ContentRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator.hideHeader = true
        
        answerTextView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        
        disposable.inner.add(contentRepository.getFAQEntry(index: index).on(value: {[weak self]entry in
            self?.questionLabel.text = entry.question
            self?.answerTextView.attributedText = try? Down(markdownString: entry.answer).toHabiticaAttributedString()
        }).start())
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        questionLabel.textColor = theme.primaryTextColor
        answerTextView.backgroundColor = theme.contentBackgroundColor
    }
}
