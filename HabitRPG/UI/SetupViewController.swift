//
//  SetupViewController.swift
//  Habitica
//
//  Created by Phillip on 28.07.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import MRProgress
import Habitica_Models
import ReactiveSwift

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
    
    var userRepository = UserRepository()
    private var taskRepository = TaskRepository()
    
    var views: [UIView] = []
    var viewControllers: [TypingTextViewController] = []
    var taskSetupViewController: TaskSetupViewController?
    var currentpage = 0
    
    var createdTags = [SetupTaskCategory: TagProtocol]()
    var tagsToCreate = [SetupTaskCategory: TagProtocol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
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
        
        (viewControllers[0] as? WelcomeViewController)?.onEnableNextButton = {[weak self] enable in
            self?.enableNextButton(enabled: enable)
        }
        
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
    
    @objc
    func scrollToNextPage() {
        if getCurrentPage() >= 2 {
            completeSetup()
            return
        } else if getCurrentPage() == 0 {
            confirmNames()
        }
        scrollToPage(getCurrentPage()+1)
    }
    
    @objc
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
            nextButtonTextView.text = L10n.finish
        } else {
            nextButtonTextView.text = L10n.next
        }
    }
    
    func enablePreviousButton(enabled: Bool) {
        if enabled {
            previousButtonImageView.tintColor = UIColor.white
            previousButtonTextView.textColor = UIColor.white
            previousButtonView.isUserInteractionEnabled = true
        } else {
            previousButtonImageView.tintColor = UIColor.purple500()
            previousButtonTextView.textColor = UIColor.purple500()
            previousButtonView.isUserInteractionEnabled = false
        }
    }
    
    func enableNextButton(enabled: Bool) {
        if enabled {
            nextButtonImageView.tintColor = UIColor.white
            nextButtonTextView.textColor = UIColor.white
            nextButtonView.isUserInteractionEnabled = true
        } else {
            nextButtonImageView.tintColor = UIColor(white: 1.0, alpha: 0.5)
            nextButtonTextView.textColor = UIColor(white: 1.0, alpha: 0.5)
            nextButtonView.isUserInteractionEnabled = false
        }
    }
    
    func completeSetup() {
        UserDefaults.standard.set(false, forKey: "isInSetup")
        UserDefaults.standard.set(0, forKey: "currentSetupStep")
        let overlayView = MRProgressOverlayView.showOverlayAdded(to: self.view, title: L10n.teleportingHabitica, mode: .indeterminate, animated: true)
        overlayView?.setTintColor(ThemeService.shared.theme.tintColor)
        overlayView?.backgroundColor = ThemeService.shared.theme.backgroundTintColor.withAlphaComponent(0.6)
        if let viewController = taskSetupViewController {
            for taskCategory in viewController.selectedCategories {
                tagsToCreate[taskCategory] = taskCategory.getTag(taskRepository: taskRepository)
            }
        }
        createTag {[weak self] in
            self?.createTasks {
                self?.userRepository.retrieveUser().observeCompleted {
                    self?.showMainView()
                }
            }
        }
    }
    
    private func createTag(_ completeFunc: @escaping () -> Void) {
        guard let taskCategory = tagsToCreate.keys.first else {
            completeFunc()
            return
        }
        if let tag = tagsToCreate.removeValue(forKey: taskCategory) {
            taskRepository.createTag(tag).on(value: {[weak self]tag in
                self?.createdTags[taskCategory] = tag
            }).observeCompleted {[weak self] in
                self?.createTag(completeFunc)
            }
        }
    }
    
    private func createTasks(_ completeFunc: @escaping () -> Void) {
        if let viewController = taskSetupViewController {
            var tasks = [TaskProtocol]()
            for taskCategory in viewController.selectedCategories {
                tasks.append(contentsOf: taskCategory.getTasks(tagId: createdTags[taskCategory]?.id, taskRepository: taskRepository))
            }
            var task = taskRepository.getNewTask()
            task.text = L10n.Tasks.Examples.rewardText
            task.notes = L10n.Tasks.Examples.rewardNotes
            task.value = 20
            task.type = "reward"
            tasks.append(task)
            task = taskRepository.getNewTask()
            task.text = L10n.Tasks.Examples.todoText
            task.notes = L10n.Tasks.Examples.todoNotes
            task.type = "todo"
            tasks.append(task)
            task = taskRepository.getNewTask()
            task.text = L10n.Tasks.Examples.habitText
            task.notes = L10n.Tasks.Examples.habitNotes
            task.up = false
            task.down = true
            task.type = "habit"
            tasks.append(task)
            if tasks.isEmpty {
                completeFunc()
                return
            }
            taskRepository.createTasks(tasks).observeCompleted {
                completeFunc()
            }
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
    
    func confirmNames() {
        guard let welcomeViewController = viewControllers[0] as? WelcomeViewController else {
            return
        }
        guard let displayname = welcomeViewController.displayName else {
            return
        }
        guard let username = welcomeViewController.username else {
            return
        }
        userRepository.updateUser(key: "profile.name", value: displayname)
            .flatMap(.latest, { user -> SignalProducer<UserProtocol, ValidationError> in
                if user == nil {
                    return SignalProducer.init(error: ValidationError(""))
                }
                return self.userRepository.updateUsername(newUsername: username).mapError({ error -> ValidationError in
                    return ValidationError(error.localizedDescription)
                }).producer
            })
            .observeCompleted {}
    }
}

private struct ValidationError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
}
