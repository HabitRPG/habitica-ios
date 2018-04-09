//
//  BaseRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Database
import ReactiveSwift

class BaseRepository<T: BaseLocalRepository>: NSObject {
    
    let localRepository = T.init()
    let disposable = ScopedDisposable(CompositeDisposable())
}
