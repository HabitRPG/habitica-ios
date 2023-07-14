//
//  RewardViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class RewardViewDataSource: BaseReactiveCollectionViewDataSource<BaseRewardProtocol> {
    
    private let userRepository = UserRepository()
    private let taskRepository = TaskRepository()
    
    private var user: UserProtocol?
    
    override init() {
        super.init()
        sections.append(ItemSection<BaseRewardProtocol>())
        sections.append(ItemSection<BaseRewardProtocol>())
        
        disposable.add(taskRepository.getTasks(predicate: NSPredicate(format: "type == 'reward'")).on(value: {[weak self](tasks, changes) in
            self?.sections[0].items = tasks
            self?.notify(changes: changes)
        }).start())
        disposable.add(userRepository.getInAppRewards().on(value: {[weak self](inAppRewards, changes) in
            self?.sections[1].items = inAppRewards
            self?.notify(changes: changes)
        }).start())
        disposable.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
        }).start())
    }
    
    func isCustomRewardsSection(_ section: Int) -> Bool {
        if let item = item(at: IndexPath(row: 0, section: section)) {
            if item as? TaskProtocol != nil {
                return true
            }
        }
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let reward = item(at: indexPath) as? TaskProtocol {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomRewardCell", for: indexPath)
            if let rewardCell = cell as? CustomRewardCell, reward.isValid {
                rewardCell.configure(reward: reward)
                rewardCell.canAfford = reward.value < self.user?.stats?.gold ?? 0
                rewardCell.onBuyButtonTapped = {
                    self.userRepository.buyCustomReward(reward: reward).observeCompleted {
                        SoundManager.shared.play(effect: .rewardBought)
                    }
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InAppRewardCell", for: indexPath)
            if let rewardCell = cell as? InAppRewardCell, let reward = item(at: indexPath) as? InAppRewardProtocol, reward.isValid {
                rewardCell.configure(reward: reward, user: user)
            }
            return cell
        }
    }

    @objc
    func moveReward(reward: BaseRewardProtocol, fromPosition: Int, toPosition: Int, completion: (() -> Void)? = nil) {
        var section: Int?
        if let task = reward as? TaskProtocol {
            section = 0
            taskRepository.moveTask(task, toPosition: toPosition).observeCompleted {
                completion?()
            }
        } else if let reward = reward as? InAppRewardProtocol {
            section = 1
            userRepository.movePinnedItem(reward, toPosition: toPosition).observeCompleted {
                completion?()
            }
        }

        if let section = section {
            // Update local array for smooth animation
            sections[section].items.remove(at: fromPosition)
            sections[section].items.insert(reward, at: toPosition)
        }
    }
}
