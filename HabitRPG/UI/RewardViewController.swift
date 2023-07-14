//
//  RewardViewController.swift
//  Habitica
//
//  Created by Phillip on 21.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

enum RewardSectionType {
    case custom
    case inApp
    
    var itemHeight: NSCollectionLayoutDimension {
        switch self {
        case .custom:
            return .estimated(70)
        case .inApp:
            return .absolute(120)
        }
    }
    
    var itemWidth: NSCollectionLayoutDimension {
        switch self {
        case .custom:
            return .fractionalWidth(1)
        case .inApp:
            return .estimated(90)
        }
    }

    var sectionInset: NSDirectionalEdgeInsets  {
        switch self {
        case .custom:
            return .zero
        case .inApp:
            return .init(top: 0, leading: 4, bottom: 0, trailing: 4)
        }
    }
}

class RewardViewController: BaseCollectionViewController, UICollectionViewDelegateFlowLayout {
    private struct DragWrapper {
        let sourceIndexPath: IndexPath
        let item: BaseRewardProtocol
    }
    
    let userRepository = UserRepository()
    
    let dataSource = RewardViewDataSource()

    #if !targetEnvironment(macCatalyst)
    let refreshControl = UIRefreshControl()
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource.collectionView = self.collectionView
        
        let customRewardNib = UINib.init(nibName: "CustomRewardCell", bundle: .main)
        collectionView?.register(customRewardNib, forCellWithReuseIdentifier: "CustomRewardCell")
        let inAppRewardNib = UINib.init(nibName: "InAppRewardCell", bundle: .main)
        collectionView?.register(inAppRewardNib, forCellWithReuseIdentifier: "InAppRewardCell")

        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
        
        collectionView.collectionViewLayout = createCollectionViewLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView?.alwaysBounceVertical = true
        #if !targetEnvironment(macCatalyst)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.addSubview(refreshControl)
        #endif
        
        tutorialIdentifier = "rewards"
        navigationItem.title = L10n.Tasks.rewards
        refresh()
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        collectionView.backgroundColor = theme.contentBackgroundColor
    }
    
    override func getDefinitionFor(tutorial: String) -> [String] {
        if tutorial == self.tutorialIdentifier {
            return [L10n.Tutorials.rewards1, L10n.Tutorials.rewards2]
        }
        return []
    }
    
    @objc
    func refresh() {
        userRepository.retrieveUser(withTasks: false)
            .flatMap(.latest, {[weak self] _ in
                return self?.userRepository.retrieveInAppRewards() ?? Signal.empty
            })
            .observeCompleted {[weak self] in
                #if !targetEnvironment(macCatalyst)
                self?.refreshControl.endRefreshing()
                #endif
        }
    }
    
    private var editedReward: TaskProtocol?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let reward = dataSource.item(at: indexPath) as? TaskProtocol {
            editedReward = reward
            performSegue(withIdentifier: "FormSegue", sender: self)
        } else {
            let storyboard = UIStoryboard(name: "BuyModal", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "HRPGBuyItemModalViewController") as? HRPGBuyItemModalViewController {
                viewController.modalTransitionStyle = .crossDissolve
                viewController.reward = dataSource.item(at: indexPath) as? InAppRewardProtocol
                if let tabbarController = self.tabBarController {
                    tabbarController.present(viewController, animated: true, completion: nil)
                } else {
                    present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FormSegue" {
            guard let destinationController = segue.destination as? UINavigationController else {
                return
            }
            guard let formController = destinationController.topViewController as? TaskFormController else {
                return
            }
            formController.taskType = .reward
            if let task = editedReward {
                formController.editedTask = task
            } else {
                formController.editedTask = nil
            }
            editedReward = nil
        }
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [self] sectionIndex, _ in
            let isCustomRewardsSection = self.dataSource.isCustomRewardsSection(sectionIndex)
            let sectionType: RewardSectionType = isCustomRewardsSection ? .custom : .inApp
            let itemSize = NSCollectionLayoutSize(widthDimension: sectionType.itemWidth,
                                                  heightDimension: sectionType.itemHeight)
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: sectionType.itemHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .flexible(1)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = sectionType.sectionInset
            return section
        }
        return layout
    }
}

extension RewardViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag,
           let dragWrapper = session.items.first?.localObject as? DragWrapper,
           dragWrapper.sourceIndexPath.section == destinationIndexPath?.section {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard coordinator.proposal.operation == .move,
              let destinationIndexPath = coordinator.destinationIndexPath,
              let item = coordinator.items.first,
              let sourceIndexPath = item.sourceIndexPath,
              let dragWrapper = item.dragItem.localObject as? DragWrapper else {
            return
        }
        collectionView.performBatchUpdates {
            dataSource.moveReward(
                reward: dragWrapper.item,
                fromPosition: sourceIndexPath.item,
                toPosition: destinationIndexPath.item
            )
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
        }

        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
    }
}

extension RewardViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let item = dataSource.item(at: indexPath) else {
            return []
        }
        let itemProvider = NSItemProvider(object: (item.text ?? "") as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = DragWrapper(sourceIndexPath: indexPath, item: item)
        dragItem.previewProvider = { [weak self] in
            if let preview = self?.dragPreviewFor(indexPath: indexPath),
               let view = preview.view,
               let parameters = preview.parameters {
                return UIDragPreview(view: view, parameters: parameters)
            }
            return nil
        }
        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return dragPreviewFor(indexPath: indexPath).parameters
    }

    func collectionView(_ collectionView: UICollectionView, dropPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return dragPreviewFor(indexPath: indexPath).parameters
    }

    private func dragPreviewFor(indexPath: IndexPath) -> (parameters: UIDragPreviewParameters?, view: UIView?) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return (nil, nil)
        }
        let parameters = UIDragPreviewParameters()
        parameters.backgroundColor = .clear

        if let cell = cell as? PathTraceable {
            parameters.visiblePath = cell.visiblePath()
        }

        return (parameters, cell)
    }
}
