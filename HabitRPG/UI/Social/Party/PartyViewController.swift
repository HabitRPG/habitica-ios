//
//  PartyViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 21.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveSwift

class PartyViewController: SplitSocialViewController {
    
    private let userRepository = UserRepository()
    private let configRepository = ConfigRepository.shared
    
    @IBOutlet weak var noPartyContainerView: UIView!
    @IBOutlet weak var userIDButton: UIButton!
    @IBOutlet weak var groupInvitationListView: GroupInvitationListView!
    @IBOutlet weak var noPartyHeaderBackground: GradientImageView!
    
    @IBOutlet weak var createPartyTitleLabel: UILabel!
    @IBOutlet weak var createPartyDescriptionLabel: UILabel!
    @IBOutlet weak var createPartyButton: UIButton!
    @IBOutlet weak var joinPartyTitle: UILabel!
    @IBOutlet weak var joinPartyDescriptionLabel: UILabel!
    
    @IBOutlet weak var lookingForPartySubtitleLabel: UILabel!
    @IBOutlet weak var leaveLookingForPartyButton: UIButton!
    @IBOutlet weak var leaveLookingForPartySubtitle: UILabel!
    var userDisposable: Disposable?
    private var isSeekingParty = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ImageManager.getImage(name: "timeTravelersShop_background_fall") {[weak self] (image, _) in
            self?.noPartyHeaderBackground.image = image?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: UIImage.ResizingMode.tile)
        }
        let gradient = CAGradientLayer()
        let bgColor = ThemeService.shared.theme.contentBackgroundColor
        gradient.colors = [bgColor.cgColor, bgColor.withAlphaComponent(0).cgColor, bgColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.locations =  [0, 0.4, 1]
        noPartyHeaderBackground.gradient = gradient
        chatViewController?.autocompleteContext = "party"
        
        userDisposable = userRepository.getUser()
            .on(value: {[weak self] user in
                self?.isSeekingParty = user.party?.seeking != nil
                if self?.isSeekingParty == true {
                    self?.userIDButton?.setTitle(L10n.Party.lookingForParty, for: .normal)
                    self?.userIDButton?.backgroundColor = .clear
                    self?.userIDButton?.setTitleColor(ThemeService.shared.theme.successColor, for: .normal)
                    self?.userIDButton?.borderColor = ThemeService.shared.theme.successColor
                    self?.userIDButton?.borderWidth = 2
                    self?.lookingForPartySubtitleLabel.isHidden = false
                    self?.leaveLookingForPartyButton.isHidden = false
                    self?.leaveLookingForPartySubtitle.isHidden = false
                } else {
                    self?.userIDButton?.setTitle(L10n.Party.lookForParty, for: .normal)
                    self?.userIDButton?.backgroundColor = ThemeService.shared.theme.backgroundTintColor
                    self?.userIDButton?.setTitleColor(.white, for: .normal)
                    self?.userIDButton?.borderColor = nil
                    self?.lookingForPartySubtitleLabel.isHidden = true
                    self?.leaveLookingForPartyButton.isHidden = true
                    self?.leaveLookingForPartySubtitle.isHidden = true
                }
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
                    self?.topHeaderCoordinator?.hideHeader = true
                    self?.topHeaderCoordinator?.showHideHeader(show: false)
                } else {
                    self?.scrollView.isHidden = false
                    self?.noPartyContainerView?.isHidden = true
                    let showTabs = !(self?.traitCollection.horizontalSizeClass == .regular && self?.traitCollection.verticalSizeClass == .regular)
                    self?.topHeaderCoordinator?.hideHeader = !showTabs
                    self?.topHeaderCoordinator?.showHideHeader(show: showTabs)
                }
            })
            .on(failed: { error in
                logger.record(error: error)
            })
            .start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if userDisposable?.isDisposed == false {
            userDisposable?.dispose()
        }
        super.viewWillDisappear(animated)
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        createPartyButton.backgroundColor = theme.windowBackgroundColor
        userIDButton.backgroundColor = theme.windowBackgroundColor
        view.backgroundColor = theme.contentBackgroundColor
        lookingForPartySubtitleLabel.textColor = theme.secondaryTextColor
        leaveLookingForPartyButton.tintColor = theme.errorColor
        leaveLookingForPartySubtitle.textColor = theme.successColor
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.party
        createPartyTitleLabel.text = L10n.Party.createPartyTitle
        createPartyDescriptionLabel.text = L10n.Party.createPartyDescription
        createPartyButton.setTitle(L10n.Party.createPartyButton, for: .normal)
        joinPartyTitle.text = L10n.Party.joinPartyTitle
        joinPartyDescriptionLabel.text = L10n.Party.joinPartyDescription
        leaveLookingForPartySubtitle.text = L10n.Party.leaveLookingForPartySubtitle
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userRepository.retrieveUser(withTasks: false).observeCompleted {}
    }
    
    @IBAction func createPartyButtonTapped(_ sender: Any) {
        perform(segue: StoryboardSegue.Social.formSegue)
    }
    
    @IBAction func userIDButtonTapped(_ sender: UIButton) {
        if !isSeekingParty {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            disposable.inner.add(userRepository.updateUser(key: "party.seeking", value: dateFormatter.string(from: Date())).observeCompleted {})
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.formSegue.rawValue {
            let navigationController = segue.destination as? UINavigationController
            let formViewController = navigationController?.topViewController as? GroupFormViewController
            formViewController?.isParty = true
        }
        super.prepare(for: segue, sender: sender)
    }
    
    @IBAction func leaveLookingButtonTapped(_ sender: Any) {
        disposable.inner.add(userRepository.updateUser(key: "party.seeking", value: nil)
            `.observeCompleted {})
    }
}
