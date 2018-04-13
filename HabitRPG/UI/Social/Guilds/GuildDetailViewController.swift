//
//  GuildDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class GuildDetailViewController: GroupDetailViewController {
    
    @IBOutlet weak var guildMembersLabel: UILabel!
    @IBOutlet weak var guildGemCountLabel: UILabel!
    @IBOutlet weak var guildMembersCrestIcon: UIImageView!
    @IBOutlet weak var gemIconView: UIImageView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var leaveButtonWrapper: UIView!
    @IBOutlet weak var guildLeaderWrapper: UIView!
    @IBOutlet weak var guildLeaderNameLabel: UILabel!
    @IBOutlet weak var guildLeaderAvatarView: AvatarView!
    
    var leaveInteractor: LeaveGroupInteractor?
    private let (lifetime, token) = Lifetime.make()
    
    let numberFormatter = NumberFormatter()
    
    var getGuildLeaderDisposable: Disposable?
    
    var guildLeaderID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gemIconView.image = HabiticaIcons.imageOfGem_36
        
        numberFormatter.usesGroupingSeparator = true
        
        if let groupID = self.groupID {
            disposable.inner.add(socialRepository.isUserGuildMember(groupID: groupID).on(value: {[weak self] isMember in
                self?.joinButton.isHidden = isMember
                self?.leaveButtonWrapper.isHidden = !isMember
            }).start())
        }
        
        self.leaveInteractor = LeaveGroupInteractor(presentingViewController: self)
        
        guildLeaderWrapper.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openGuildLeaderProfile)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposable.inner.add(self.leaveInteractor?.reactive.take(during: self.lifetime).observeCompleted {})
    }
    
    override func updateData(group: GroupProtocol) {
        super.updateData(group: group)
        guildMembersCrestIcon.image = HabiticaIcons.imageOfGuildCrestMedium(memberCount: CGFloat(group.memberCount))
        guildMembersLabel.text = numberFormatter.string(from: NSNumber(value: group.memberCount))
        guildGemCountLabel.text = numberFormatter.string(from: NSNumber(value: group.gemCount))
        
        if let leaderID = group.leaderID {
            getGuildLeader(leaderID: leaderID)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let disposable = getGuildLeaderDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
        super.viewWillDisappear(animated)
    }
    
    @IBAction func guildLeaderMessageButtonTapped(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.challengesSegue.rawValue, let groupID = self.groupID {
            let challengesViewController = segue.destination as? ChallengeTableViewController
            challengesViewController?.shownGuilds = [groupID]
            challengesViewController?.showOnlyUserChallenges = false
        } else if segue.identifier == StoryboardSegue.Social.userProfileSegue.rawValue, let leaderID = self.guildLeaderID {
            let profileViewController = segue.destination as? HRPGUserProfileViewController
            profileViewController?.userID = leaderID
        }
    }
    
    private func getGuildLeader(leaderID: String) {
        if let disposable = getGuildLeaderDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
        getGuildLeaderDisposable = socialRepository.getMember(userID: leaderID, retrieveIfNotFound: true).skipNil().on(value: {[weak self] guildLeader in
            self?.guildLeaderNameLabel.text = guildLeader.profile?.name
            self?.guildLeaderAvatarView.avatar = AvatarViewModel(avatar: guildLeader)
        }).start()
    }
    
    @IBAction func joinButtonTapped(_ sender: Any) {
        if let groupID = self.groupID {
            socialRepository.joinGroup(groupID: groupID).observeCompleted {}
        }
    }
    
    @IBAction func leaveButtonTapped(_ sender: Any) {
        if let groupID = self.groupID {
            leaveInteractor?.run(with: groupID)
        }
    }
    
    @objc
    private func openGuildLeaderProfile() {
        perform(segue: StoryboardSegue.Social.userProfileSegue)
    }
}
