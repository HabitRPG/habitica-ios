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
    @IBOutlet weak var noPartyContainerView: UIView!
    @IBOutlet weak var userIDButton: UIButton!
    @IBOutlet weak var qrCodeView: HRPGQRCodeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disposable.inner.add(userRepository.getUser()
            .on(value: {[weak self] user in
                self?.userIDButton.setTitle(user.id, for: .normal)
                self?.qrCodeView.userID = user.id
                self?.qrCodeView.setAvatarViewWithUser(user)
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
                    self?.topHeaderCoordinator.showHideHeader(show: false)
                } else {
                    self?.scrollView.isHidden = false
                    self?.noPartyContainerView.isHidden = true
                    self?.topHeaderCoordinator.hideHeader = false
                    self?.topHeaderCoordinator.showHideHeader(show: true)
                }
            })
            .start())
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
        pasteboard.string = sender.title(for: .normal)
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
