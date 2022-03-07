//
//  FAQDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift
import Down

class FAQDetailViewController: BaseUIViewController {
    
    var index: Int = -1
    
    @IBOutlet weak var answerTextView: MarkdownTextView!
    @IBOutlet weak var questionLabel: UILabel!
    
    private let contentRepository = ContentRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    var faqTitle: String?
    var faqText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.hideHeader = true
        
        answerTextView.contentInset = UIEdgeInsets.zero
        answerTextView.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        if let title = faqTitle {
            questionLabel.text = title
        }
        if let text = faqText {
            answerTextView.setMarkdownString(text)
        }
        if index >= 0 {
            disposable.inner.add(contentRepository.getFAQEntry(index: index).on(value: {[weak self]entry in
                self?.questionLabel.text = entry.question
                self?.answerTextView.setMarkdownString(entry.answer, highlightUsernames: false)
            }).start())
        }
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        questionLabel.textColor = theme.primaryTextColor
        answerTextView.backgroundColor = theme.contentBackgroundColor
    }
}
