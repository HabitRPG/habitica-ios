//
//  TaskSetupViewController.swift
//  Habitica
//
//  Created by Phillip on 01.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

enum SetupTaskCategory {
    case work, exercise, health, school, selfcare, chores, creativity

    //siwftlint:disable:next identifier_name
    func createSampleHabit(_ text: String, tagId: String?, positive: Bool, negative: Bool, taskRepository: TaskRepository) -> TaskProtocol {
        let task = taskRepository.getNewTask()
        task.text = text
        task.up = positive
        task.down = negative
        task.type = "habit"
        if let id = tagId {
            task.tags = [taskRepository.getNewTag(id: id)]
        }
        return task
    }
    
    func createSampleDaily(_ text: String, tagId: String?, notes: String, taskRepository: TaskRepository) -> TaskProtocol {
        let task = taskRepository.getNewTask()

        task.text = text
        task.notes = notes
        task.startDate = Date()
        task.type = "daily"
        if let id = tagId {
            task.tags = [taskRepository.getNewTag(id: id)]
        }
        return task
    }
    
    func createSampleToDo(_ text: String, tagId: String?, notes: String, taskRepository: TaskRepository) -> TaskProtocol {
        let task = taskRepository.getNewTask()
        task.text = text
        task.type = "todo"
        task.notes = notes
        if let id = tagId {
            task.tags = [taskRepository.getNewTag(id: id)]
        }
        return task
    }
    
    func getTasks(tagId: String?, taskRepository: TaskRepository) -> [TaskProtocol] {
        switch self {
        case .work:
            return [
                createSampleHabit(NSLocalizedString("Process email", comment: ""), tagId: tagId, positive: true, negative: false, taskRepository: taskRepository),
                createSampleDaily(NSLocalizedString("Worked on today’s most important task", comment: ""),
                                  tagId: tagId, notes: NSLocalizedString("Tap to specify your most important task", comment: ""), taskRepository: taskRepository),
                createSampleToDo(NSLocalizedString("Complete work project", comment: ""), tagId: tagId,
                                 notes: NSLocalizedString("Tap to specify the name of your current project + set a due date!", comment: ""), taskRepository: taskRepository)
            ]
        case .exercise:
            return [
                createSampleHabit(NSLocalizedString("10 minutes cardio", comment: ""), tagId: tagId, positive: true, negative: false, taskRepository: taskRepository),
                createSampleDaily(NSLocalizedString("Daily workout routine", comment: ""), tagId: tagId, notes: NSLocalizedString("Tap to choose your schedule and specify exercises!", comment: ""), taskRepository: taskRepository),
                createSampleToDo(NSLocalizedString("Set up workout schedule", comment: ""), tagId: tagId, notes: NSLocalizedString("Tap to add a checklist!", comment: ""), taskRepository: taskRepository)
            ]
        case .health:
            return [
                createSampleHabit(NSLocalizedString("Eat health/junk food", comment: ""), tagId: tagId, positive: true, negative: true, taskRepository: taskRepository),
                createSampleDaily(NSLocalizedString("Floss", comment: ""), tagId: tagId, notes: NSLocalizedString("Tap to make any changes!", comment: ""), taskRepository: taskRepository),
                createSampleToDo(NSLocalizedString("Brainstorm a healthy change", comment: ""), tagId: tagId, notes: NSLocalizedString("Tap to add checklists!", comment: ""), taskRepository: taskRepository)
            ]
        case .school:
            return [
                createSampleHabit(NSLocalizedString("Study/Procrastinate", comment: ""), tagId: tagId, positive: true, negative: true, taskRepository: taskRepository),
                createSampleDaily(NSLocalizedString("Do homework", comment: ""), tagId: tagId, notes: NSLocalizedString("Tap to specify your most important task", comment: ""), taskRepository: taskRepository),
                createSampleToDo(NSLocalizedString("Finish assignment for class", comment: ""), tagId: tagId, notes: NSLocalizedString("Tap to specify your most important task", comment: ""), taskRepository: taskRepository)
            ]
        case .selfcare:
            return [
                createSampleHabit(NSLocalizedString("Take a short break", comment: ""), tagId: tagId, positive: true, negative: false, taskRepository: taskRepository),
                createSampleDaily(NSLocalizedString("5 minutes of quiet breathing", comment: ""), tagId: tagId, notes: NSLocalizedString("Tap to choose your schedule!", comment: ""), taskRepository: taskRepository),
                createSampleToDo(NSLocalizedString("Engage in a fun activity", comment: ""), tagId: tagId, notes: NSLocalizedString("Tap to specify what you plan to do!", comment: ""), taskRepository: taskRepository)
            ]
        case .chores:
            return [
                createSampleHabit(NSLocalizedString("10 minutes cleaning", comment: ""), tagId: tagId, positive: true, negative: false, taskRepository: taskRepository),
                createSampleDaily(NSLocalizedString("Wash dishes", comment: ""), tagId: tagId, notes: NSLocalizedString("Tap to choose your schedule!", comment: ""), taskRepository: taskRepository),
                createSampleToDo(NSLocalizedString("Organize clutter", comment: ""), tagId: tagId, notes: NSLocalizedString("Tap to specify the cluttered area!", comment: ""), taskRepository: taskRepository)
            ]
        case .creativity:
            return [
                createSampleHabit(NSLocalizedString("Practiced a new creative technique", comment: ""), tagId: tagId, positive: true, negative: false, taskRepository: taskRepository),
                createSampleDaily(NSLocalizedString("Work on creative project", comment: ""), tagId: tagId,
                                  notes: NSLocalizedString("Tap to specify the name of your current project + set the schedule!", comment: ""), taskRepository: taskRepository),
                createSampleToDo(NSLocalizedString("Finish creative project", comment: ""), tagId: tagId, notes: NSLocalizedString("Tap to specify the name of your project", comment: ""), taskRepository: taskRepository)
            ]
        }
    }
    
    func getTag(taskRepository: TaskRepository) -> TagProtocol {
        let tag = taskRepository.getNewTag()
        switch self {
        case .work:
            tag.text = NSLocalizedString("Work", comment: "")
        case .exercise:
            tag.text = NSLocalizedString("Exercise", comment: "")
        case .health:
            tag.text = NSLocalizedString("Health", comment: "")
        case .school:
            tag.text = NSLocalizedString("School", comment: "")
        case .selfcare:
            tag.text = NSLocalizedString("Self-Care", comment: "")
        case .chores:
            tag.text = NSLocalizedString("Chores", comment: "")
        case .creativity:
            tag.text = NSLocalizedString("Creativity", comment: "")
        }
        return tag
    }
}

class TaskSetupViewController: UIViewController, TypingTextViewController {
    
    @IBOutlet weak var avatarView: AvatarView!

    @IBOutlet weak var workCategoryButton: UIButton!
    @IBOutlet weak var exerciseCategoryButton: UIButton!
    @IBOutlet weak var healthCategoryButton: UIButton!
    @IBOutlet weak var schoolCategoryButton: UIButton!
    @IBOutlet weak var teamCategoryButton: UIButton!
    @IBOutlet weak var choresCategoryButtton: UIButton!
    @IBOutlet weak var creativityCategoryButton: UIButton!
    @IBOutlet weak var speechBubbleView: SpeechbubbleView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    let buttonBackground = #imageLiteral(resourceName: "DiamondButton").resizableImage(withCapInsets: UIEdgeInsets(top: 18, left: 15, bottom: 18, right: 15)).withRenderingMode(.alwaysTemplate)
    
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())

    var user: UserProtocol? {
        didSet {
            if let user = self.user {
                avatarView.avatar = AvatarViewModel(avatar: user)
            }
        }
    }
    
    public var selectedCategories: [SetupTaskCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarView.showBackground = false
        avatarView.showMount = false
        avatarView.showPet = false
        avatarView.size = .regular
        
        disposable.inner.add(userRepository.getUser().on(value: { user in
            self.user = user
        }).start())
        
        initButtons()
    
        if self.view.frame.size.height <= 568 {
            containerHeight.constant = 205
        }
    }
    
    func initButtons() {
        workCategoryButton.setBackgroundImage(buttonBackground, for: .normal)
        exerciseCategoryButton.setBackgroundImage(buttonBackground, for: .normal)
        healthCategoryButton.setBackgroundImage(buttonBackground, for: .normal)
        schoolCategoryButton.setBackgroundImage(buttonBackground, for: .normal)
        teamCategoryButton.setBackgroundImage(buttonBackground, for: .normal)
        choresCategoryButtton.setBackgroundImage(buttonBackground, for: .normal)
        creativityCategoryButton.setBackgroundImage(buttonBackground, for: .normal)
        
        workCategoryButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleButton(_:))))
        exerciseCategoryButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleButton(_:))))
        healthCategoryButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleButton(_:))))
        schoolCategoryButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleButton(_:))))
        teamCategoryButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleButton(_:))))
        choresCategoryButtton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleButton(_:))))
        creativityCategoryButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleButton(_:))))
        
        updateButtonBackgrounds()
    }
    
    @objc
    func toggleButton(_ sender: UIGestureRecognizer) {
        if let selectedCategory = getCategoryFor(view: sender.view) {
            if selectedCategories.contains(selectedCategory) {
                if let index = selectedCategories.index(of: selectedCategory) {
                    selectedCategories.remove(at: index)
                }
            } else {
                selectedCategories.append(selectedCategory)
            }
        }
        updateButtonBackgrounds()
    }
    
    private func getCategoryFor(view: UIView?) -> SetupTaskCategory? {
        if let button = view as? UIButton {
            switch button {
            case workCategoryButton:
                return .work
            case exerciseCategoryButton:
                return .exercise
            case healthCategoryButton:
                return .health
            case schoolCategoryButton:
                return .school
            case teamCategoryButton:
                return .selfcare
            case choresCategoryButtton:
                return .chores
            case creativityCategoryButton:
                return .creativity
            default:
                return nil
            }
        }
        return nil
    }
    
    func updateButtonBackgrounds() {
        updateButton(workCategoryButton)
        updateButton(exerciseCategoryButton)
        updateButton(healthCategoryButton)
        updateButton(schoolCategoryButton)
        updateButton(teamCategoryButton)
        updateButton(choresCategoryButtton)
        updateButton(creativityCategoryButton)
    }
    
    func updateButton(_ button: UIButton) {
        if isSelected(button) {
            button.tintColor = .white
            button.setTitleColor(UIColor.purple300(), for: .normal)
            button.setImage(#imageLiteral(resourceName: "checkmark_small"), for: .normal)
        } else {
            button.tintColor = UIColor.purple50()
            button.setTitleColor(.white, for: .normal)
            button.setImage(nil, for: .normal)
        }
    }
    
    func isSelected(_ button: UIButton) -> Bool {
        switch button {
        case workCategoryButton:
            return selectedCategories.contains(.work)
        case exerciseCategoryButton:
            return selectedCategories.contains(.exercise)
        case healthCategoryButton:
            return selectedCategories.contains(.health)
        case schoolCategoryButton:
            return selectedCategories.contains(.school)
        case teamCategoryButton:
            return selectedCategories.contains(.selfcare)
        case choresCategoryButtton:
            return selectedCategories.contains(.chores)
        case creativityCategoryButton:
            return selectedCategories.contains(.creativity)
        default:
            return false
        }
    }
    
    func startTyping() {
        speechBubbleView.animateTextView()
        if let user = self.user {
            avatarView.avatar = AvatarViewModel(avatar: user)
        }
    }
}
