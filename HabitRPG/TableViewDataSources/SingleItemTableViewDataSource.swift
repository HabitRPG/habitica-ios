//
//  SingleItemTableViewDataSource.swift
//  Habitica
//
//  Created by Elliot Schrock on 5/31/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class SingleItemTableViewDataSource<T>: NSObject, UITableViewDataSource where T: UITableViewCell {
    var cellIdentifier = "emptyCell"
    var styleFunction: ((T) -> Void)
    
    init(cellIdentifier: String? = nil, styleFunction: @escaping ((T) -> Void)) {
        self.cellIdentifier = cellIdentifier ?? "emptyCell"
        self.styleFunction = styleFunction
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? T {
            styleFunction(cell)
            return cell
        }
        return UITableViewCell()
    }
}

class TaskEmptyTableViewDataSource<T>: NSObject, UITableViewDataSource where T: UITableViewCell {
    var cellIdentifier = "emptyCell"
    var styleFunction: ((T) -> Void)
    weak var tableView: UITableView?
    
    internal let userRepository = UserRepository()
    internal let repository = TaskRepository()
    internal let socialRepository = SocialRepository()
    private let configRepository = ConfigRepository()
    
    var showingAdventureGuide = false
    private var adventureGuideCompletedCount = 0
    private var adventureGuideTotalCount = 0
    
    init(tableView: UITableView, cellIdentifier: String? = nil, styleFunction: @escaping ((T) -> Void)) {
        self.tableView = tableView
        self.cellIdentifier = cellIdentifier ?? "emptyCell"
        self.styleFunction = styleFunction
        super.init()
        if configRepository.bool(variable: .moveAdventureGuide) {
            userRepository.getUser().on(value: { user in
                self.showingAdventureGuide = !(user.achievements?.hasCompletedOnboarding ?? true)
                if self.showingAdventureGuide {
                    self.adventureGuideCompletedCount = user.achievements?.onboardingAchievements.filter({ $0.value }).count ?? 0
                    self.adventureGuideTotalCount = 5
                }
                self.tableView?.reloadData()
            }).start()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingAdventureGuide ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showingAdventureGuide && indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "adventureGuideCell", for: indexPath)
            if let agCell = cell as? AdventureGuideTableViewCell {
                agCell.completedCount = adventureGuideCompletedCount
                agCell.totalCount = adventureGuideTotalCount
            }
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? T {
            styleFunction(cell)
            return cell
        }
        return UITableViewCell()
    }
}
