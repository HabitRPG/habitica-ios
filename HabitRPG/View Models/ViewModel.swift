//
//  ViewModel.swift
//  Habitica
//
//  Created by Phillip Thelen on 29.09.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import ReactiveSwift

class ViewModel: ObservableObject {
    let disposable = CompositeDisposable()
    
    deinit {
        dispose()
    }
    
    func dispose() {
        if !disposable.isDisposed {
            disposable.dispose()
        }
    }
}
