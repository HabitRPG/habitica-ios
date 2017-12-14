//
//  String-Extensions.swift
//  Habitica
//
//  Created by Phillip on 18.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

extension String {

    //https://gist.github.com/zhjuncai/6af27ca9649126dd326c
    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.width
    }
}
