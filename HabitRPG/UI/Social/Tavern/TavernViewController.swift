//
//  TavernViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class TavernViewController: SplitSocialViewController {

    private var tavernDetailViewController: TavernDetailViewController?
    
    override func viewDidLoad() {
        groupID = "00000000-0000-4000-A000-000000000000"
        for childViewController in self.childViewControllers {
            if let viewController = childViewController as? TavernDetailViewController {
                tavernDetailViewController = viewController
            }
        }
        
        super.viewDidLoad()

        scrollView.delegate = self

        chatViewController?.groupID = groupID
    }
    
    override internal func setGroup() {
        if let detailViewController = self.tavernDetailViewController, let items = fetchedResultsController?.fetchedObjects, items.count > 0 {
            let group = items[0]
            detailViewController.group = group
            
            if let questKey = group.questKey {
                let quest = InventoryRepository().getQuest(questKey)
                detailViewController.quest = quest
            } else {
                detailViewController.quest = nil
            }
        }
    }
}
