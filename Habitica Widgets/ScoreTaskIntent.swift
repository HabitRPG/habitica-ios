//
//  ScoreTaskIntent.swift
//  Habitica WidgetsExtension
//
//  Created by Evgenii Tyutyuev on 02.05.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//

import AppIntents
import WidgetKit
import Habitica_API_Client
import Habitica_Models
import ReactiveSwift
import os

struct ScoreTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Score Task"

    @Parameter(title: "Task ID")
    var taskId: String

    @Parameter(title: "Task Type")
    var taskType: String

    init() {}

    init(taskId: String, taskType: String) {
        self.taskId = taskId
        self.taskType = taskType
    }

    func perform() async throws -> some IntentResult {
        let manager = TaskManager.shared
        guard let task = manager.getTasks(predicate: NSPredicate(format: "id == %@", taskId)).first else {
            return .result()
        }
        
        let lock = OSAllocatedUnfairLock<Disposable?>(initialState: nil)
        await withTaskCancellationHandler {
            let success = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
                let call = ScoreTaskCall(task: task, direction: .up)
                let disposable = call.habiticaResponseSignal.observeValues { response in
                    continuation.resume(returning: response?.success == true)
                    lock.withLock {
                        $0 = nil
                    }
                }
                lock.withLock {
                    $0 = disposable
                }
                call.fire()
            }

            if success, !Task.isCancelled {
                manager.markTaskCompleted(taskId: taskId)
                WidgetCenter.shared.reloadTimelines(ofKind: "TaskListWidget")
                WidgetCenter.shared.reloadTimelines(ofKind: "TodoTaskListWidget")
            }
        } onCancel: {
            lock.withLock {
                $0?.dispose()
            }
        }
        return .result()
    }
}
