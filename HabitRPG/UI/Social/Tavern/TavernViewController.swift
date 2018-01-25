//
//  TavernViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class TavernViewController: HRPGUIViewController, UIScrollViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    let tavernID = "00000000-0000-4000-A000-000000000000"
    let segmentedControl = UISegmentedControl(items: [NSLocalizedString("Tavern", comment: ""), NSLocalizedString("Chat", comment: "")])
    
    var detailViewController: TavernDetailViewController?
    var chatViewController: GroupChatViewController?
    
    private var fetchedResultsController: NSFetchedResultsController<Group>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.tintColor = UIColor.purple300()
        self.segmentedControl.addTarget(self, action: #selector(TavernViewController.switchView(_:)), for: .valueChanged)

        scrollView.delegate = self
        
        for childViewController in self.childViewControllers {
            if let viewController = childViewController as? TavernDetailViewController {
                detailViewController = viewController
            }
            if let viewController = childViewController as? GroupChatViewController {
                chatViewController = viewController
            }
        }
        
        chatViewController?.groupID = tavernID
        
        fetchGroup()
    }
    
    private func fetchGroup() {
        let fetchRequest: NSFetchRequest<Group> = SocialRepository().getFetchRequest(entityName: "Group",
                                                                    predicate: NSPredicate(format: "id == %@", "00000000-0000-4000-A000-000000000000")
            )
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchedResultsController = NSFetchedResultsController<Group>(fetchRequest: fetchRequest, managedObjectContext: HRPGManager.shared().getManagedObjectContext(), sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
        try? fetchedResultsController?.performFetch()
        
        setGroup()
    }
    
    private func setGroup() {
        if let items = fetchedResultsController?.fetchedObjects, items.count > 0 {
            let group = items[0]
            detailViewController?.group = group
            
            if let questKey = group.questKey {
                let quest = InventoryRepository().getQuest(questKey)
                detailViewController?.quest = quest
            } else {
                detailViewController?.quest = nil
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = getCurrentPage()
        self.segmentedControl.selectedSegmentIndex = currentPage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let segmentedWrapper = PaddedView()
        segmentedWrapper.containedView = self.segmentedControl
        if let navController = self.hrpgTopHeaderNavigationController() {
            navController.setAlternativeHeaderView(segmentedWrapper)
            navController.showHeader()
            scrollViewTopConstraint.constant = navController.contentInset
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setGroup()
    }
    
    @objc
    func switchView(_ segmentedControl: UISegmentedControl) {
        scrollTo(page: segmentedControl.selectedSegmentIndex)
    }
    
    func getCurrentPage() -> Int {
        return Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
    
    func scrollTo(page: Int) {
        let point = CGPoint(x: scrollView.frame.size.width * CGFloat(page), y: 0)
        scrollView .setContentOffset(point, animated: true)
    }
}
