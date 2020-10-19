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
    case work, exercise, health, school, team, chores, creativity

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
                createSampleHabit(L10n.Tasks.Examples.workHabit, tagId: tagId, positive: true, negative: false, taskRepository: taskRepository),
                createSampleDaily(L10n.Tasks.Examples.workDailyText, tagId: tagId, notes: L10n.Tasks.Examples.workDailyNotes, taskRepository: taskRepository),
                createSampleToDo(L10n.Tasks.Examples.workTodoText, tagId: tagId, notes: L10n.Tasks.Examples.workTodoNotes, taskRepository: taskRepository)
            ]
        case .exercise:
            return [
                createSampleHabit(L10n.Tasks.Examples.exerciseHabit, tagId: tagId, positive: true, negative: false, taskRepository: taskRepository),
                createSampleDaily(L10n.Tasks.Examples.exerciseDailyText, tagId: tagId, notes: L10n.Tasks.Examples.exerciseDailyNotes, taskRepository: taskRepository),
                createSampleToDo(L10n.Tasks.Examples.exerciseTodoText, tagId: tagId, notes: L10n.Tasks.Examples.exerciseTodoNotes, taskRepository: taskRepository)
            ]
        case .health:
            return [
                createSampleHabit(L10n.Tasks.Examples.healthHabit, tagId: tagId, positive: true, negative: true, taskRepository: taskRepository),
                createSampleDaily(L10n.Tasks.Examples.healthDailyText, tagId: tagId, notes: L10n.Tasks.Examples.healthDailyNotes, taskRepository: taskRepository),
                createSampleToDo(L10n.Tasks.Examples.healthTodoText, tagId: tagId, notes: L10n.Tasks.Examples.healthTodoNotes, taskRepository: taskRepository)
            ]
        case .school:
            return [
                createSampleHabit(L10n.Tasks.Examples.schoolHabit, tagId: tagId, positive: true, negative: true, taskRepository: taskRepository),
                createSampleDaily(L10n.Tasks.Examples.schoolDailyText, tagId: tagId, notes: L10n.Tasks.Examples.schoolDailyNotes, taskRepository: taskRepository),
                createSampleToDo(L10n.Tasks.Examples.schoolTodoText, tagId: tagId, notes: L10n.Tasks.Examples.schoolTodoNotes, taskRepository: taskRepository)
            ]
        case .team:
            return [
                createSampleHabit(L10n.Tasks.Examples.teamHabit, tagId: tagId, positive: true, negative: false, taskRepository: taskRepository),
                createSampleDaily(L10n.Tasks.Examples.teamDailyText, tagId: tagId, notes: L10n.Tasks.Examples.teamDailyNotes, taskRepository: taskRepository),
                createSampleToDo(L10n.Tasks.Examples.teamTodoText, tagId: tagId, notes: L10n.Tasks.Examples.teamTodoNotes, taskRepository: taskRepository)
            ]
        case .chores:
            return [
                createSampleHabit(L10n.Tasks.Examples.choresHabit, tagId: tagId, positive: true, negative: false, taskRepository: taskRepository),
                createSampleDaily(L10n.Tasks.Examples.choresDailyText, tagId: tagId, notes: L10n.Tasks.Examples.choresDailyNotes, taskRepository: taskRepository),
                createSampleToDo(L10n.Tasks.Examples.choresTodoText, tagId: tagId, notes: L10n.Tasks.Examples.choresTodoNotes, taskRepository: taskRepository)
            ]
        case .creativity:
            return [
                createSampleHabit(L10n.Tasks.Examples.creativityHabit, tagId: tagId, positive: true, negative: false, taskRepository: taskRepository),
                createSampleDaily(L10n.Tasks.Examples.creativityDailyText, tagId: tagId, notes: L10n.Tasks.Examples.creativityDailyNotes, taskRepository: taskRepository),
                createSampleToDo(L10n.Tasks.Examples.creativityTodoText, tagId: tagId, notes: L10n.Tasks.Examples.creativityTodoNotes, taskRepository: taskRepository)
            ]
        }
    }
    
    func getTag(taskRepository: TaskRepository) -> TagProtocol {
        let tag = taskRepository.getNewTag()
        switch self {
        case .work:
            tag.text = L10n.Tasks.work
        case .exercise:
            tag.text = L10n.Tasks.exercise
        case .health:
            tag.text = L10n.Tasks.health
        case .school:
            tag.text = L10n.Tasks.school
        case .team:
            tag.text = L10n.Tasks.team
        case .chores:
            tag.text = L10n.Tasks.chores
        case .creativity:
            tag.text = L10n.Tasks.creativity
        }
        return tag
    }
}

class TaskSetupViewController: UIViewController, TypingTextViewController, Themeable {
    
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
        
        speechBubbleView.text = L10n.Intro.taskSetupSpeechbubble
        ThemeService.shared.addThemeable(themable: self)

        avatarView.showBackground = false
        avatarView.showMount = false
        avatarView.showPet = false
        avatarView.size = .regular
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.user = user
        }).start())
        
        initButtons()
    
        if view.frame.size.height <= 568 {
            containerHeight.constant = 205
        }
    }
    
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.windowBackgroundColor
    }
    
    func initButtons() {
        workCategoryButton.setTitle(L10n.Tasks.work, for: .normal)
        exerciseCategoryButton.setTitle(L10n.Tasks.exercise, for: .normal)
        healthCategoryButton.setTitle(L10n.Tasks.health, for: .normal)
        schoolCategoryButton.setTitle(L10n.Tasks.school, for: .normal)
        teamCategoryButton.setTitle(L10n.Tasks.team, for: .normal)
        choresCategoryButtton.setTitle(L10n.Tasks.chores, for: .normal)
        creativityCategoryButton.setTitle(L10n.Tasks.creativity, for: .normal)
        
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
                if let index = selectedCategories.firstIndex(of: selectedCategory) {
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
                return .team
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
            button.setTitleColor(UIColor.purple300, for: .normal)
            button.setImage(#imageLiteral(resourceName: "checkmark_small"), for: .normal)
        } else {
            button.tintColor = UIColor.purple50
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
            return selectedCategories.contains(.team)
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
