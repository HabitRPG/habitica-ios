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
