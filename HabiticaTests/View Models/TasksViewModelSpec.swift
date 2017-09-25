//
//  TasksViewModelSpec.swift
//  HabiticaTests
//
//  Created by Elliot Schrock on 9/29/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Quick
import Nimble
import FunkyNetwork
@testable import Habitica

class TasksViewModelSpec: QuickSpec {
    override func spec() {
        describe("Refresh test") {
            context("success") {
                it("should download tasks") {
                    let call = GetTasksCall(configuration: HRPGServerConfig.stub)
                    let viewModel = TasksViewModel(tasksCall: call)
                    
                    waitUntil(timeout: 0.5) { done in
                        viewModel.outputs.tasksUpdatedSignal.observeValues({ (tasks) in
                            expect(tasks).toNot(beNil())
                            done()
                        })
                        viewModel.inputs.refresh()
                    }
                }
            }
        }
    }
}
