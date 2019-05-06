//
//  PartyViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 21.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Crashlytics

class PartyViewController: SplitSocialViewController {
    
    private let userRepository = UserRepository()
    private let configRepository = ConfigRepository()
    
    @IBOutlet weak var noPartyContainerView: UIView!
    @IBOutlet weak var userIDButton: UIButton!
    @IBOutlet weak var groupInvitationListView: GroupInvitationListView!
    @IBOutlet weak var noPartyHeaderBackground: GradientImageView!
    
    @IBOutlet weak var createPartyTitleLabel: UILabel!
    @IBOutlet weak var createPartyDescriptionLabel: UILabel!
    @IBOutlet weak var createPartyButton: UIButton!
    @IBOutlet weak var joinPartyTitle: UILabel!
    @IBOutlet weak var joinPartyDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ImageManager.getImage(name: "timeTravelersShop_background_fall") { (image, _) in
            self.noPartyHeaderBackground.image = image?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: UIImage.ResizingMode.tile)
        }
        let gradient = CAGradientLayer()
        let bgColor = ThemeService.shared.theme.contentBackgroundColor
        gradient.colors = [bgColor.cgColor, bgColor.withAlphaComponent(0).cgColor, bgColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.locations =  [0, 0.4, 1]
        noPartyHeaderBackground.gradient = gradient
        chatViewController?.autocompleteContext = "party"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposable.inner.add(userRepository.getUser()
            .on(value: {[weak self] user in
                self?.userIDButton.setTitle("@\(user.username ?? "")", for: .normal)
                self?.groupInvitationListView.set(invitations: user.invitations)
            })
            .map({ (user) -> String? in
                return user.party?.id
            })
            .on(value: {[weak self] partyID in
                self?.groupID = partyID
                
                if partyID == nil {
                    self?.scrollView.isHidden = true
                    self?.noPartyContainerView.isHidden = false
                    self?.topHeaderCoordinator.hideHeader = true
                    self?.topHeaderCoordinator.navbarHiddenColor = .white
                    self?.topHeaderCoordinator.showHideHeader(show: false)
                } else {
                    self?.scrollView.isHidden = false
                    self?.noPartyContainerView.isHidden = true
                    self?.topHeaderCoordinator.hideHeader = false
                    self?.topHeaderCoordinator.showHideHeader(show: true)
                }
            })
            .on(failed: { error in
                Crashlytics.sharedInstance().recordError(error)
            })
            .start())
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        createPartyButton.backgroundColor = theme.windowBackgroundColor
        userIDButton.backgroundColor = theme.windowBackgroundColor
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.party
        createPartyTitleLabel.text = L10n.Party.createPartyTitle
        createPartyDescriptionLabel.text = L10n.Party.createPartyDescription
        createPartyButton.setTitle(L10n.Party.createPartyButton, for: .normal)
        joinPartyTitle.text = L10n.Party.joinPartyTitle
        joinPartyDescriptionLabel.text = L10n.Party.joinPartyDescription
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userRepository.retrieveUser(withTasks: false).observeCompleted {}
    }
    
    @IBAction func createPartyButtonTapped(_ sender: Any) {
        perform(segue: StoryboardSegue.Social.formSegue)
    }
    
    @IBAction func userIDButtonTapped(_ sender: UIButton) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = sender.title(for: .normal)?.replacingOccurrences(of: "@", with: "")
        ToastManager.show(text: L10n.copiedToClipboard, color: .blue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.formSegue.rawValue {
            let navigationController = segue.destination as? UINavigationController
            let formViewController = navigationController?.topViewController as? GroupFormViewController
            formViewController?.isParty = true
        }
        super.prepare(for: segue, sender: sender)
    }
}
