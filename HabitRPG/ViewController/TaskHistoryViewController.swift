//
//  TaskHistoryViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Charts
import Habitica_Models

class TaskHistoryViewController: BaseUIViewController {
    
    private let taskRepository = TaskRepository()
    
    var taskID: String?
    
    @IBOutlet weak var chart: LineChartView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chart.dragEnabled = true

        chart.rightAxis.enabled = false
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelFont = .systemFont(ofSize: 13)
        chart.xAxis.labelRotationAngle = 45
        chart.xAxis.valueFormatter = DateAxisValueFormatter()
        chart.leftAxis.zeroLineWidth = 2
        chart.leftAxis.drawZeroLineEnabled = true
        chart.leftAxis.drawLabelsEnabled = false
        
        chart.drawGridBackgroundEnabled = true
        chart.gridBackgroundColor = .white
        chart.drawBordersEnabled = false
        chart.scaleYEnabled = false
        chart.scaleXEnabled = true
        
        chart.legend.enabled = false
        
        taskRepository.getTasks(predicate: NSPredicate(format: "id == %@", taskID ?? "")).on(value: { tasks in
            if let task = tasks.value.first {
                self.setData(task)
            }
            }).start()
    }
    
    private func setData(_ task: TaskProtocol) {
        if task.history.count == 0 {
            chart.data = nil
            return
        }
        var entries = [ChartDataEntry]()
        var colors = [UIColor]()
        task.history.forEach { (historyEntry) in
            let dataEntry = ChartDataEntry(x: historyEntry.timestamp?.timeIntervalSince1970 ?? 0, y: Double(historyEntry.value))
            colors.append(UIColor.forTaskValue(Int(historyEntry.value)))
            entries.append(dataEntry)
        }
        let dataset = LineChartDataSet(entries)
        dataset.colors = colors
        dataset.drawCirclesEnabled = false
        dataset.mode = .linear
        dataset.lineWidth = 3
        dataset.circleRadius = 4
        dataset.drawValuesEnabled = false
        chart.data = LineChartData(dataSet: dataset)
        /*chart.maxVisibleCount = 15
        chart.setVisibleXRangeMaximum(20)
        chart.moveViewToX(entries.last?.x ?? 0)
        chart.setVisibleXRangeMaximum(Double(entries.count))*/
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
