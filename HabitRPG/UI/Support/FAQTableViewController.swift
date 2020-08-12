//
//  FAQTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

class FAQViewController: BaseUIViewController {
    
    private let searchBar = UISearchBar()
    private let resetTutorialButton = UIButton()
    
    private let dataSource = FAQTableViewDataSource()
    private var selectedIndex: Int?
    
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    @IBOutlet private var mainStackView: UIStackView!
    @IBOutlet private var mechanicsTitleLabel: UILabel!
    @IBOutlet private var mechanicsStackView: UIStackView!
    @IBOutlet private var commonQuestionsTitleLabel: UILabel!
    @IBOutlet private var commonQuestionsStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator?.hideHeader = true
        topHeaderCoordinator?.followScrollView = false
        
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        populateMechanics()
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.basics
        mechanicsTitleLabel.text = L10n.gameMechanics
        commonQuestionsTitleLabel.text = L10n.commonQuestions
    }
    
    private func populateMechanics() {
        
    }
}
