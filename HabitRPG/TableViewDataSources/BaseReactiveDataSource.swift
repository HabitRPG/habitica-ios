//
//  BaseReactiveDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 05.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift

class BaseReactiveDataSource: NSObject {
    
    let disposable = ScopedDisposable(CompositeDisposable())
    
}
