//
//  TaskFormViewModel.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class TaskFormViewModel {
    
    func sectionsFor(taskType: TaskType) -> [TaskFormSection] {
        var sections = [TaskFormSection]()
        sections.append(titleNotesSection())
        if taskType == .habit {
            sections.append(habitControlSection())
        }
        sections.append(difficultySection())
        if taskType == .habit {
            sections.append(resetStreakSection())
        }
        sections.append(tagsSection())
        return sections
    }
    
    private func titleNotesSection() -> TaskFormSection {
        let rows = [
            TaskFormRow(cellIdentifier: "TextInputCell"),
            TaskFormRow(cellIdentifier: "TextInputCell")
        ]
        return TaskFormSection(identifier: "titleNotes", title: nil, rows: rows)
    }
    
    private func habitControlSection() -> TaskFormSection {
        let rows = [
            TaskFormRow(cellIdentifier: "ControlsCell")
            ]
        return TaskFormSection(identifier: "habitControls", title: L10n.controls, rows: rows)
    }
    
    private func difficultySection() -> TaskFormSection {
        let rows = [
            TaskFormRow(cellIdentifier: "DifficultyCell")
        ]
        return TaskFormSection(identifier: "difficulty", title: L10n.difficulty, rows: rows)
    }
    
    private func resetStreakSection() -> TaskFormSection {
        let rows = [
            TaskFormRow(cellIdentifier: "ResetStreakCell")
        ]
        return TaskFormSection(identifier: "resetStreak", title: L10n.resetStreak, rows: rows)
    }
    
    private func tagsSection() -> TaskFormSection {
        let rows = [
            TaskFormRow(cellIdentifier: "Cell")
            ]
        return TaskFormSection(identifier: "tags", title: L10n.tags, rows: rows)
    }
}
