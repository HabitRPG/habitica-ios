//
//  LabeledFormValue.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.08.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation

struct LabeledFormValue<V: Equatable & Hashable>: Equatable, CustomStringConvertible, Identifiable, Hashable {
    static func == (lhs: LabeledFormValue<V>, rhs: LabeledFormValue<V>) -> Bool {
        return lhs.value == rhs.value
    }
    
    var value: V
    var label: String
    
    var description: String {
        return label
    }
    
    var id: String {
        return value as? String ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
