//
//  FAQDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
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
        answerTextView.textContainerInset = UIEdgeInsets.zero
        
        if let title = faqTitle {
            questionLabel.text = title
        }
        if let text = faqText {
            answerTextView.setMarkdownString(text)
        }
        if index >= 0 {
            disposable.inner.add(contentRepository.getFAQEntry(index: index).on(value: {[weak self]entry in
                self?.questionLabel.text = entry.question
                self?.answerTextView.setMarkdownString(entry.answer)
            }).start())
        }
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        questionLabel.textColor = theme.primaryTextColor
        answerTextView.backgroundColor = theme.contentBackgroundColor
    }
}
