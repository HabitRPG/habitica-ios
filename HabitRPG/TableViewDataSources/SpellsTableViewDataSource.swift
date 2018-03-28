//
//  SpellsTableViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 28.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class SpellsTableViewDataSource: BaseReactiveDataSource, UITableViewDataSource {
    
    private var userRepository = UserRepository()
    private var contentRepository = ContentRepository()
    
    private var spells = [SpellProtocol]()
    private var stats: StatsProtocol?
    
    override init() {
        super.init()
        disposable.inner.add(userRepository.getUser().on(value: { user in
            if let stats = user.stats {
                self.stats = stats
            }
        }).start())
        disposable.inner.add(contentRepository.getSpells().on(value: { result in
            self.spells = result.value
        }).start())
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpellCell", for: indexPath)
        return cell
    }
}
