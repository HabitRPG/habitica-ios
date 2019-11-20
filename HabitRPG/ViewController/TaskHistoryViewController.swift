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
    private let userRepository = UserRepository()
    
    var taskID: String?
    
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var subscribeLabel: UILabel!
    @IBOutlet weak var subscribeWrapper: UIView!
    @IBOutlet weak var subscribeButton: UIButton!
    
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
        
        let marker = BalloonMarker(color: UIColor.gray50,
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chart
        marker.minimumSize = CGSize(width: 80, height: 40)
        chart.marker = marker
        
        taskRepository.getTasks(predicate: NSPredicate(format: "id == %@", taskID ?? "")).on(value: { tasks in
            if let task = tasks.value.first {
                self.setData(task)
            }
            }).start()
        
        userRepository.getUser()
            .on(value: {[weak self] user in
                if !user.isSubscribed {
                    // Without subscription only 2 weeks of data is shown
                    self?.chart.xAxis.axisMinimum = Date().timeIntervalSince1970 - 1209600
                    self?.subscribeWrapper.isHidden = false
                }
            }).start()
        
        subscribeButton.setTitle(L10n.subscribe, for: .normal)
        subscribeLabel.text = L10n.subscribeForTaskHistory
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
        dataset.circleColors = colors
        dataset.drawCirclesEnabled = true
        dataset.mode = .linear
        dataset.lineWidth = 3
        dataset.circleRadius = 4
        dataset.drawValuesEnabled = false
        chart.data = LineChartData(dataSet: dataset)
        
        chart.setVisibleXRangeMaximum(86400 * 30)
        chart.moveViewToX(entries.last?.x ?? 0)
        chart.setVisibleXRangeMaximum(entries.last?.x ?? 1000)
    }
    
    @IBAction func subscribeButtonTapped(_ sender: Any) {
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

open class BalloonMarker: MarkerImage
{
    private let formatter: DateFormatter = {
        let formatter =  DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    @objc open var color: UIColor
    @objc open var arrowSize = CGSize(width: 15, height: 11)
    @objc open var font: UIFont
    @objc open var textColor: UIColor
    @objc open var insets: UIEdgeInsets
    @objc open var minimumSize = CGSize()
    
    fileprivate var label: String?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key : Any]()
    
    @objc public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
        super.init()
    }
    
    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint
    {
        var offset = self.offset
        var size = self.size

        if size.width == 0.0 && image != nil
        {
            size.width = image!.size.width
        }
        if size.height == 0.0 && image != nil
        {
            size.height = image!.size.height
        }

        let width = size.width
        let height = size.height
        let padding: CGFloat = 8.0

        var origin = point
        origin.x -= width / 2
        origin.y -= height

        if origin.x + offset.x < 0.0
        {
            offset.x = -origin.x + padding
        }
        else if let chart = chartView,
            origin.x + width + offset.x > chart.bounds.size.width
        {
            offset.x = chart.bounds.size.width - origin.x - width - padding
        }

        if origin.y + offset.y < 0
        {
            offset.y = height + padding;
        }
        else if let chart = chartView,
            origin.y + height + offset.y > chart.bounds.size.height
        {
            offset.y = chart.bounds.size.height - origin.y - height - padding
        }

        return offset
    }
    
    open override func draw(context: CGContext, point: CGPoint)
    {
        guard let label = label else { return }
        
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height
        
        context.saveGState()

        context.setFillColor(color.cgColor)

        if offset.y > 0
        {
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                y: rect.origin.y + arrowSize.height))
            //arrow vertex
            context.addLine(to: CGPoint(
                x: point.x,
                y: point.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + rect.size.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + arrowSize.height))
            context.fillPath()
        }
        else
        {
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            //arrow vertex
            context.addLine(to: CGPoint(
                x: point.x,
                y: point.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.fillPath()
        }
        
        if offset.y > 0 {
            rect.origin.y += self.insets.top + arrowSize.height
        } else {
            rect.origin.y += self.insets.top
        }

        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        label.draw(in: rect, withAttributes: _drawAttributes)
        
        UIGraphicsPopContext()
        
        context.restoreGState()
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        setLabel(formatter.string(from: Date(timeIntervalSince1970: entry.x)))
    }
    
    @objc open func setLabel(_ newLabel: String)
    {
        label = newLabel
        
        _drawAttributes.removeAll()
        _drawAttributes[.font] = self.font
        _drawAttributes[.paragraphStyle] = _paragraphStyle
        _drawAttributes[.foregroundColor] = self.textColor
        
        _labelSize = label?.size(withAttributes: _drawAttributes) ?? CGSize.zero
        
        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }
}


public class DateAxisValueFormatter: IAxisValueFormatter{
    private let formatter: DateFormatter = {
        let formatter =  DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return formatter.string(from: Date(timeIntervalSince1970: value))
    }
}
