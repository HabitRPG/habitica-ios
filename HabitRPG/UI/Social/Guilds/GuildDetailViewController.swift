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
    
    @IBOutlet weak var guildMembersWrapper: UIView!
    @IBOutlet weak var guildMembersLabel: UILabel!
    @IBOutlet weak var guildMembersTitleLabel: UILabel!
    @IBOutlet weak var guildGemWrapper: UIView!
    @IBOutlet weak var guildGemCountLabel: UILabel!
    @IBOutlet weak var guildGemTitleLabel: UILabel!
    @IBOutlet weak var guildMembersCrestIcon: UIImageView!
    @IBOutlet weak var gemIconView: UIImageView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var guildLeaderWrapper: UIView!
    @IBOutlet weak var guildLeaderNameLabel: UILabel!
    @IBOutlet weak var guildLeaderAvatarView: AvatarView!
    @IBOutlet weak var guildLeaderTitleLabel: UILabel!
    @IBOutlet weak var guildChallengesButton: UIButton!
    @IBOutlet weak var guildDescriptionTitleLabel: CollapsibleTitle!
    @IBOutlet weak var buttonsBackgorundView: UIView!
    
    let numberFormatter = NumberFormatter()

    var guildLeaderID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gemIconView.image = HabiticaIcons.imageOfGem_36
        
        numberFormatter.usesGroupingSeparator = true
        
        disposable.inner.add(groupProperty.producer.skipNil()
            .map({ (group) -> String? in
                return group.id
            })
            .skipNil()
            .skipRepeats()
            .flatMap(.latest, {[weak self] groupID in
            return self?.socialRepository.isUserGuildMember(groupID: groupID) ?? SignalProducer.empty
        }).on(value: {[weak self] isMember in
            self?.joinButton.isHidden = isMember
            self?.leaveButtonWrapper?.isHidden = !isMember
        }).start())
        
        disposable.inner.add(groupProperty.producer.skipNil().flatMap(.latest, {[weak self] group in
                return self?.socialRepository.getMember(userID: group.leaderID ?? "", retrieveIfNotFound: true).skipNil() ?? SignalProducer.empty
        }).on(value: {[weak self] guildLeader in
            self?.guildLeaderID = guildLeader.id
            self?.guildLeaderNameLabel.text = guildLeader.profile?.name
            self?.guildLeaderAvatarView.avatar = AvatarViewModel(avatar: guildLeader)
        }).start())
        
        guildLeaderWrapper.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openGuildLeaderProfile)))
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        guildMembersWrapper.backgroundColor = theme.contentBackgroundColor
        guildMembersLabel.textColor = theme.primaryTextColor
        guildMembersTitleLabel.textColor = theme.primaryTextColor
        guildGemWrapper.backgroundColor = theme.contentBackgroundColor
        guildGemCountLabel.textColor = theme.primaryTextColor
        guildGemTitleLabel.textColor = theme.primaryTextColor
        buttonsBackgorundView.backgroundColor = theme.contentBackgroundColor
        guildLeaderTitleLabel.textColor = theme.secondaryTextColor
        guildChallengesButton.backgroundColor = theme.contentBackgroundColor
    }
    
    override func populateText() {
        guildMembersTitleLabel.text = L10n.Guilds.guildMembers
        guildGemTitleLabel.text = L10n.Guilds.guildBank
        joinButton.setTitle(L10n.Guilds.joinGuild, for: .normal)
        inviteButton.setTitle(L10n.Guilds.inviteToGuild, for: .normal)
        guildLeaderTitleLabel.text = L10n.Guilds.guildLeader
        guildDescriptionTitleLabel.text = L10n.Guilds.guildDescription
        guildChallengesButton.setTitle(L10n.Guilds.guildChallenges, for: .normal)
    }
    
    override func updateData(group: GroupProtocol) {
        super.updateData(group: group)
        guildMembersCrestIcon.image = HabiticaIcons.imageOfGuildCrestMedium(memberCount: CGFloat(group.memberCount))
        guildMembersLabel.text = numberFormatter.string(from: NSNumber(value: group.memberCount))
        guildGemCountLabel.text = numberFormatter.string(from: NSNumber(value: group.gemCount))
    }
    
    @IBAction func guildLeaderMessageButtonTapped(_ sender: Any) {
        perform(segue: StoryboardSegue.Social.sendMessageSegue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.challengesSegue.rawValue, let groupID = self.groupProperty.value?.id {
            let challengesViewController = segue.destination as? ChallengeTableViewController
            challengesViewController?.dataSource.shownGuilds = [groupID]
            challengesViewController?.showOnlyUserChallenges = false
        } else if segue.identifier == StoryboardSegue.Social.userProfileSegue.rawValue, let leaderID = self.guildLeaderID {
            let profileViewController = segue.destination as? UserProfileViewController
            profileViewController?.userID = leaderID
        } else if segue.identifier == StoryboardSegue.Social.sendMessageSegue.rawValue, let leaderID = self.guildLeaderID {
            let navigationController = segue.destination as? UINavigationController
            let messageViewController = navigationController?.topViewController as? HRPGInboxChatViewController
            messageViewController?.isPresentedModally = true
            messageViewController?.userID = leaderID
        }
        super.prepare(for: segue, sender: sender)
    }

    @IBAction func joinButtonTapped(_ sender: Any) {
        if let groupID = self.groupProperty.value?.id {
            socialRepository.joinGroup(groupID: groupID).observeCompleted {}
        }
    }
    
    @objc
    private func openGuildLeaderProfile() {
        perform(segue: StoryboardSegue.Social.userProfileSegue)
    }
}
