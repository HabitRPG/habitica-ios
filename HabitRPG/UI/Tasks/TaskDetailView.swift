//
//  TaskDetailView.swift
//  Habitica
//
//  Created by Phillip Thelen on 03.05.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models

struct TaskDetailInfo<ValueView: View, LabelView: View>: View {
    var value: ValueView
    var label: LabelView
    
    var body: some View {
        VStack(alignment: .center, content: {
            value.font(.title).foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
            label.font(.caption).foregroundColor(Color(ThemeService.shared.theme.secondaryTextColor))
        })
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(ThemeService.shared.theme.windowBackgroundColor))
        .cornerRadius(6)
    }
}

struct HabitDetails: View {
    var task: TaskProtocol?
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TaskDetailInfo(value: Text(String(task?.counterUp ?? 0)), label: Text(L10n.Tasks.Form.positive))
                    .padding(.trailing, 8)
                TaskDetailInfo(value: Text(String(task?.counterDown ?? 0)), label: Text(L10n.Tasks.Form.negative))
            }
        }
    }
}

struct DailyDetails: View {
    @Environment(\.calendar) var calendar
    
    private var month: DateInterval {
        calendar.dateInterval(of: .month, for: Date()) ?? DateInterval()
    }

    var task: TaskProtocol?
    
    private func backgroundColor(on day: Date) -> Color {
        guard let history = task?.history else {
            return Color.clear
        }
        for element in history.enumerated() {
            let entry = element.element
            var scoringDirection = element.offset == 0 ? 1 : 0
            if element.offset > 0 {
                if history[element.offset - 1].value < entry.value {
                    scoringDirection = 1
                } else if history[element.offset - 1].value > entry.value {
                    scoringDirection = -1
                }
            }
            if scoringDirection != 0, let timestamp = entry.timestamp, calendar.isDate(timestamp, inSameDayAs: day) {
                return scoringDirection > 0 ? Color(.green100) : Color(.red100)
            }
        }
        return Color.clear
    }
    
    private var monthName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: Date())
    }
    
    private var totalCompletionCount: Int {
        var totalCount = 0
        guard let history = task?.history else {
            return totalCount
        }
        for element in history.enumerated() {
            let entry = element.element
             if element.offset > 0 {
                if history[element.offset - 1].value < entry.value {
                    totalCount += 1
                }
            } else {
                totalCount += 1
            }
        }
        return totalCount
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TaskDetailInfo(value: Text(String(task?.streak ?? 0)), label: Text(L10n.streak))
                    .padding(.trailing, 8)
                TaskDetailInfo(value: Text(String(totalCompletionCount)), label: Text(L10n.totalCompletions))
            }
            VStack {
                Text(monthName).font(.title)
                CalendarView(interval: month) { date in
                    Text("30")
                        .hidden()
                        .padding(8)
                        .background(backgroundColor(on: date))
                        .clipShape(Circle())
                        .padding(.vertical, 4)
                        .overlay(
                            Text(String(self.calendar.component(.day, from: date)))
                        )
                }
            }.padding(8)
            .frame(maxWidth: .infinity)
            .background(Color(ThemeService.shared.theme.windowBackgroundColor))
            .cornerRadius(6)
        }
    }
}

struct TodoDetails: View {
    var task: TaskProtocol?
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TaskDetailInfo(value: Text(task?.createdAt?.description ?? ""), label: Text(L10n.createdAt))
                    .padding(.trailing, 8)
            }
        }
    }
}

struct TaskDetailView: View {
    @Environment(\.presentationMode) private var presentationMode

    var task: TaskProtocol?
    
    @State var title: String = ""
    @State var notes: String = ""
    
    var onSave: ((TaskProtocol?) -> Void)?
    var onShowForm: (() -> Void)?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack {
                    TextField(L10n.title, text: $title)
                        .padding(.bottom, 8)
                    TextField(L10n.notes, text: $notes)
                        .padding(.bottom, 8)
                    Button(action: {
                        task?.text = title
                        task?.notes = notes
                        onSave?(task)
                    }, label: {
                        Text(L10n.update)
                    })
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .background(Color(.purple400))
                    .cornerRadius(6)
                    .foregroundColor(.white)
                }.padding(8)
                .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                .cornerRadius(6)
                Button(action: {
                    onShowForm?()
                }, label: {
                    Text(L10n.Tasks.editDetails)
                })
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(Color(.purple400))
                .cornerRadius(6)
                .foregroundColor(.white)
                
                if task?.type == "habit" {
                    HabitDetails(task: task)
                } else if task?.type == "daily" {
                    DailyDetails(task: task)
                } else if task?.type == "todo" {
                    TodoDetails(task: task)
                } else {
                    EmptyView()
                }
            }.padding(.horizontal, 16)
            .padding(.top, 10)
        }.onAppear(perform: {
            title = task?.text ?? ""
            notes = task?.notes ?? ""
        })
    }
}

class TaskDetailViewController: UIHostingController<TaskDetailView> {
    private let taskRepository = TaskRepository()
    var task: TaskProtocol? {
        didSet {
            rootView.task = task
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: TaskDetailView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rootView.onSave = { task in
            if let task = task {
                self.taskRepository.updateTask(task)
            }
            self.dismiss(animated: true, completion: nil)
        }
        rootView.onShowForm = {
            self.perform(segue: StoryboardSegue.Tasks.formSegue)
        }
    }
}
