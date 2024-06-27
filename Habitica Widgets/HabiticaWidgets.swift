//
//  HabiticaWidgets.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.10.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct HabiticaWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        DailiesCountWidget()
        DailyTaskListWidget()
        TodoTaskListWidget()
        AddTaskWidgetSingle()
        AddTaskWidget()
        StatsWidget()
    }
}
