//
//  TavernDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

class TavernDetailViewController: GroupDetailViewController {
    
    @IBOutlet weak var tavernHeaderView: NPCBannerView!
    
    @IBOutlet weak var innButton: HabiticaButton!
    @IBOutlet weak var guidelinesButton: UIButton!
    @IBOutlet weak var faqButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var worldBossStackView: CollapsibleStackView!
    @IBOutlet weak var innStackView: CollapsibleStackView!
    @IBOutlet weak var guidelinesStackView: CollapsibleStackView!
    @IBOutlet weak var linksStackView: CollapsibleStackView!
    @IBOutlet weak var questProgressView: QuestProgressView!
    @IBOutlet weak var worldBossTitleView: CollapsibleTitle!
    @IBOutlet weak var innTextView: UITextView!
    @IBOutlet weak var guidelinesTextView: UITextView!
    
    var quest: QuestProtocol? {
        didSet {
            if let quest = self.quest {
                worldBossStackView.isHidden = false
                questProgressView.configure(quest: quest)
                tavernHeaderView.setNotes(L10n.worldBossIntroHeader)
                questProgressView.isHidden = false
                
                worldBossTitleView.infoIconAction = {
                    let alertController = HabiticaAlertController.alert(title: L10n.whatsWorldBoss)
                    let view = Bundle.main.loadNibNamed("WorldBossDescription", owner: nil, options: nil)?.last as? WorldBossDescriptionView
                    view?.bossName = quest.boss?.name
                    view?.questColorLight = quest.uicolorLight
                    view?.questColorExtraLight = quest.uicolorExtraLight
                    alertController.contentView = view
                    alertController.titleBackgroundColor = quest.uicolorLight
                    alertController.addCloseAction()
                    alertController.show()
                    alertController.titleLabel.textColor = .white
                }
            } else {
                worldBossStackView.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tavernHeaderView.npcNameLabel.text = "Daniel"
        tavernHeaderView.setSprites(identifier: "tavern")
        tavernHeaderView.setNotes(L10n.tavernIntroHeader)
        
        let margins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        worldBossStackView.layoutMargins = margins
        worldBossStackView.isLayoutMarginsRelativeArrangement = true
        innStackView.layoutMargins = margins
        innStackView.isLayoutMarginsRelativeArrangement = true
        guidelinesStackView.layoutMargins = margins
        guidelinesStackView.isLayoutMarginsRelativeArrangement = true
        linksStackView.layoutMargins = margins
        linksStackView.isLayoutMarginsRelativeArrangement = true
        
        worldBossTitleView.hasInfoIcon = true
        
        quest = nil
        
        configureInnButton()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            if user.preferences?.sleep == true {
                self?.innButton.setTitle(L10n.resumeDamage, for: .normal)
            } else {
                self?.innButton.setTitle(L10n.pauseDamage, for: .normal)
            }
            self?.questProgressView.configure(user: user)
        }).start())
    }
    
    override func populateText() {
        worldBossTitleView.text = L10n.WorldBoss.worldBoss
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        innButton.buttonColor = theme.warningColor
        guidelinesButton.backgroundColor = theme.offsetBackgroundColor
        faqButton.backgroundColor = theme.offsetBackgroundColor
        reportButton.backgroundColor = theme.offsetBackgroundColor
        innTextView.textColor = theme.secondaryTextColor
        guidelinesTextView.textColor = theme.secondaryTextColor
        tavernHeaderView.applyTheme(backgroundColor: theme.windowBackgroundColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //workaround to get the view to size correctly.
        worldBossStackView.isCollapsed = worldBossStackView.isCollapsed
    }
    
    override func updateData(group: GroupProtocol) {
        super.updateData(group: group)
        questProgressView.configure(group: group)
    }
    
    @IBAction func innButtonTapped(_ sender: Any) {
        configureInnButton(disabled: true)
        userRepository.sleep().observeCompleted {[weak self] in
            self?.configureInnButton()
        }
    }
    
    @IBAction func guidelinesButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "GuidelinesSegue", sender: self)
    }
    
    @IBAction func faqButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "FAQOverviewViewController")
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func reportBugButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AboutViewController")
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func configureInnButton(disabled: Bool = false) {
        innButton.isEnabled = !disabled
    }
}
