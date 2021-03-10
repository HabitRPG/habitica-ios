//
//  Alignment-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.03.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import SwiftUI

extension HorizontalAlignment {
    enum ZHorizontal: AlignmentID {
        static func defaultValue(in dimension: ViewDimensions) -> CGFloat { dimension[HorizontalAlignment.center] }
    }
    static let zAlignment = HorizontalAlignment(ZHorizontal.self)
}

extension VerticalAlignment {
    enum ZVertical: AlignmentID {
        static func defaultValue(in dimension: ViewDimensions) -> CGFloat { dimension[VerticalAlignment.center] }
    }
    static let zAlignment = VerticalAlignment(ZVertical.self)
}

extension Alignment {
    static let zAlignment = Alignment(horizontal: .zAlignment, vertical: .zAlignment)
}
