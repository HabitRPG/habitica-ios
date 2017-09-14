//
//  SetupViewController.swift
//  Habitica
//
//  Created by Phillip on 28.07.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import MRProgress

class SetupViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var pageIndicatorContainer: UIStackView!
    @IBOutlet weak var pageIndicatorHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var avatarSetupView: UIView!
    @IBOutlet weak var taskSetupView: UIView!
    
    @IBOutlet weak var nextButtonView: UIStackView!
    @IBOutlet weak var nextButtonTextView: UILabel!
    @IBOutlet weak var nextButtonImageView: UIImageView!
    
    @IBOutlet weak var previousButtonView: UIStackView!
    @IBOutlet weak var previousButtonTextView: UILabel!
    @IBOutlet weak var previousButtonImageView: UIImageView!
    
    var sharedManager: HRPGManager?
    
    var views: [UIView] = []
    var viewControllers: [TypingTextViewController] = []
    var taskSetupViewController: TaskSetupViewController?
    var currentpage = 0
    
    var createdTags = [SetupTaskCategory: Tag]()
    var tagsToCreate = [SetupTaskCategory: Tag]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sharedManager = HRPGManager.shared()
        
        let nextGesture = UITapGestureRecognizer(target: self, action: #selector(scrollToNextPage))
        nextButtonView.addGestureRecognizer(nextGesture)
        let previousGesture = UITapGestureRecognizer(target: self, action: #selector(scrollToPreviousPage))
        previousButtonView.addGestureRecognizer(previousGesture)
        views = [welcomeView, avatarSetupView, taskSetupView]
        avatarSetupView.isHidden = true
        avatarSetupView.alpha = 0
        taskSetupView.isHidden = true
        taskSetupView.alpha = 0
        previousButtonImageView.tintColor = UIColor.purple100()
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "isInSetup")
        let currentSetupStep = defaults.integer(forKey: "currentSetupStep")
        if currentSetupStep != 0 {
            if currentSetupStep > 1 {
                avatarSetupView.alpha = 1
                avatarSetupView.isHidden = false
            }
            scrollToPage(currentSetupStep)
        }
        
        if self.view.frame.size.height <= 480 {
            pageIndicatorHeightConstraint.constant = 42
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewControllers[0].startTyping()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = getCurrentPage()
        updateIndicator(currentPage)
    }

    func updateIndicator(_ currentPage: Int) {
        for (index, element) in pageIndicatorContainer.arrangedSubviews.enumerated() {
            if let indicatorView = element as? UIImageView {
                if index == currentPage {
                    indicatorView.image = #imageLiteral(resourceName: "indicatorDiamondSelected")
                } else {
                    indicatorView.image = #imageLiteral(resourceName: "indicatorDiamondUnselected")
                }
            }
        }
    }
    
    func getCurrentPage() -> Int {
        return currentpage
    }
    
    func scrollToNextPage() {
        if getCurrentPage() >= 2 {
            completeSetup()
            return
        }
        scrollToPage(getCurrentPage()+1)
    }
    
    func scrollToPreviousPage() {
        if getCurrentPage() <= 0 {
            return
        }
        scrollToPage(getCurrentPage()-1)
    }
    
    func scrollToPage(_ page: Int) {
        UserDefaults.standard.set(page, forKey: "currentSetupStep")
        if currentpage > page {
            let oldpage = currentpage
            UIView.animate(withDuration: 0.2, animations: {[weak self] in
                    self?.views[oldpage].alpha = 0
            }, completion: {[weak self] _ in
                    self?.views[oldpage].isHidden = true
            })
        } else {
            views[page].isHidden = false
            UIView.animate(withDuration: 0.2, animations: {[weak self] in
                self?.views[page].alpha = 1
            })
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.6) {[weak self] in
            self?.viewControllers[page].startTyping()
        }
        currentpage = page
        
        updateIndicator(page)
        
        if page <= 0 {
            previousButtonImageView.tintColor = UIColor.purple100()
        } else {
            previousButtonImageView.tintColor = UIColor.white
        }
        if page >= 2 {
            nextButtonTextView.text = NSLocalizedString("Finish", comment: "")
        } else {
            nextButtonTextView.text = NSLocalizedString("Next", comment: "")
        }
    }
    
    func completeSetup() {
        UserDefaults.standard.set(false, forKey: "isInSetup")
        UserDefaults.standard.set(0, forKey: "currentSetupStep")
        let overlayView = MRProgressOverlayView.showOverlayAdded(to: self.view, title: NSLocalizedString("Teleporting to Habitica", comment: ""), mode: .indeterminate, animated: true)
        overlayView?.setTintColor(UIColor.purple400())
        overlayView?.backgroundColor = UIColor.purple50().withAlphaComponent(0.6)
        if let viewController = taskSetupViewController, let manager = sharedManager {
            for taskCategory in viewController.selectedCategories {
                tagsToCreate[taskCategory] = taskCategory.getTag(managedObjectContext: manager.getManagedObjectContext())
            }
        }
        createTag {[weak self] in
            self?.createTasks {
                self?.sharedManager?.fetchUser({
                    self?.showMainView()
                }, onError: {
                    self?.showMainView()
                })
            }
        }
    }
    
    private func createTag(_ completeFunc: @escaping () -> Void) {
        guard let taskCategory = tagsToCreate.keys.first else {
            completeFunc()
            return
        }
        if let tag = tagsToCreate.removeValue(forKey: taskCategory) {
            sharedManager?.createTag(tag, onSuccess: {[weak self] tag in
                self?.createdTags[taskCategory] = tag
                self?.createTag(completeFunc)
                }, onError: {[weak self] in
                    self?.createTag(completeFunc)
            })
        }
    }
    
    private func createTasks(_ completeFunc: @escaping () -> Void) {
        if let viewController = taskSetupViewController {
            var tasks = [[String: Any]]()
            for taskCategory in viewController.selectedCategories {
                tasks.append(contentsOf: taskCategory.getTasks(tagId: createdTags[taskCategory]?.id))
            }
            tasks.append([
                "text": NSLocalizedString("Reward yourself", comment: ""),
                "notes": NSLocalizedString("Watch TV, play a game, eat a treat, it’s up to you!", comment: ""),
                "value": 20,
                "type": "reward"
                ])
            tasks.append([
                "text": NSLocalizedString("Join Habitica (Check me off!)", comment: ""),
                "notes": NSLocalizedString("You can either complete this To-Do, edit it, or remove it.", comment: ""),
                "type": "todo"
                ])
            tasks.append([
                "text": NSLocalizedString("Tap here to edit this into a bad habit you'd like to quit", comment: ""),
                "notes": NSLocalizedString("Or delete it by swiping left", comment: ""),
                "up": false,
                "down": true,
                "type": "habit"
                ])
            if tasks.count == 0 {
                completeFunc()
                return
            }
            self.sharedManager?.createTasks(tasks, onSuccess: {
                completeFunc()
            }, onError: {
                completeFunc()
            })
        } else {
            completeFunc()
        }
    }
    
    func showMainView() {
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        performSegue(withIdentifier: "MainSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? TypingTextViewController {
            if segue.identifier == "WelcomeSegue" {
                viewControllers.insert(viewController, at: 0)
            } else if segue.identifier == "AvatarSegue" {
                if viewControllers.count < 1 {
                    viewControllers.append(viewController)
                } else {
                    viewControllers.insert(viewController, at: 1)
                }
            } else if segue.identifier == "TaskSegue" {
                if viewControllers.count < 2 {
                    viewControllers.append(viewController)
                } else {
                    viewControllers.insert(viewController, at: 2)
                }
                if let taskSetupViewController = viewController as? TaskSetupViewController {
                    self.taskSetupViewController = taskSetupViewController
                }
            }
        }
    }
}
