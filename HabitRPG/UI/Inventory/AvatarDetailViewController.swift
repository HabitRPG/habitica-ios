//
//  AvatarDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class AvatarDetailViewController: HRPGCollectionViewController {
    
    private var datasource: AvatarDetailViewDataSource?
    
    var customizationGroup: String?
    var customizationType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let type = customizationType {
            datasource = AvatarDetailViewDataSource(type: type, group: customizationGroup)
            datasource?.collectionView = self.collectionView
        }
    }
}
