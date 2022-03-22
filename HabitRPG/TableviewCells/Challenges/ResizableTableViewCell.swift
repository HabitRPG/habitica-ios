//
//  ResizableTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 1/12/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

protocol ResizableTableViewCellDelegate: AnyObject {
    func cellResized()
}

class ResizableTableViewCell: UITableViewCell {
    public weak var resizingDelegate: ResizableTableViewCellDelegate?
}
