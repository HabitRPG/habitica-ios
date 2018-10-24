//
//  PartyViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 21.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class PartyViewController: SplitSocialViewController {
    
    private let userRepository = UserRepository()
    private let configRepository = ConfigRepository()
    
    @IBOutlet weak var noPartyContainerView: UIView!
    @IBOutlet weak var userIDButton: UIButton!
    @IBOutlet weak var qrCodeView: HRPGQRCodeView!
    @IBOutlet weak var groupInvitationListView: GroupInvitationListView!
    @IBOutlet weak var shareQRCodeButton: UIButton!
    @IBOutlet weak var qrCodeButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var joinPartyDescription: UILabel!
    @IBOutlet weak var noPartyHeaderBackground: GradientImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disposable.inner.add(userRepository.getUser()
            .on(value: {[weak self] user in
                if self?.configRepository.bool(variable: .enableUsernameRelease) == true {
                    self?.userIDButton.setTitle("@\(user.username ?? "")", for: .normal)
                } else {
                    self?.userIDButton.setTitle(user.id, for: .normal)
                    self?.qrCodeView.userID = user.id
                    self?.qrCodeView.setAvatarViewWithUser(user)
                    self?.groupInvitationListView.set(invitations: user.invitations)
                }
            })
            .map({ (user) -> String? in
            return user.party?.id
        })
            .skipRepeats()
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
            .start())
        
        if configRepository.bool(variable: .enableUsernameRelease) {
            qrCodeView.isHidden = true
            qrCodeButtonHeight.constant = 0
            shareQRCodeButton.isHidden = true
            joinPartyDescription.text = L10n.Party.joinPartyDescription
        }
        
        let spriteSuffix = configRepository.string(variable: .shopSpriteSuffix, defaultValue: "")
        ImageManager.getImage(name: "timeTravelersShop_background"+spriteSuffix) { (image, _) in
            self.noPartyHeaderBackground.image = image?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: UIImage.ResizingMode.tile)
        }
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor.init(white: 1, alpha: 0).cgColor, UIColor.white.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.locations =  [0, 0.4, 1]
        noPartyHeaderBackground.gradient = gradient
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
    
    @IBAction func shareQRCodeButtonTapped(_ sender: Any) {
        if let image = qrCodeView.snapshotView(afterScreenUpdates: true) {
            HRPGSharingManager.shareItems([image], withPresenting: self, withSourceView: nil)
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
}
