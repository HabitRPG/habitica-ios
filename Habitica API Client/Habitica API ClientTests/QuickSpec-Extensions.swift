//
//  QuickSpec-Extensions.swift
//  Habitica API ClientTests
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Quick

extension QuickSpec {
    
    func dataFor(fileName: String, fileExtension: String) -> Data? {
        let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: fileExtension)
        return try? Data(contentsOf: URL(fileURLWithPath: path ?? ""), options: .mappedIfSafe)
    }
}
