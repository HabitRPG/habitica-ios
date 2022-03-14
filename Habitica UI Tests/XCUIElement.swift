//
//  XCUIElement.swift
//  Habitica UI Tests
//
//  Created by Phillip Thelen on 11.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation
import XCTest
import Nimble
extension XCUIElement {
    func scroll(toFindCellWithId identifier:String) -> XCUIElement? {
            guard self.elementType == .collectionView else {
                fatalError("XCUIElement is not a collectionView.")
            }
      
            var reachedTheEnd = false
            var allVisibleElements = [String]()
            
            while !reachedTheEnd {
                let cell = self.cells[identifier]
                
                // Did we find our cell ?
                if cell.exists {
                    return cell
                }
     
                // If not: we store the list of all the elements we've got in the CollectionView
                let allElements = self.cells.allElementsBoundByIndex.map({ cell -> String in
                    if cell.identifier.isEmpty {
                        return cell.label
                    } else {
                        return cell.identifier
                    }
                })
                
                // Did we read then end of the CollectionView ?
                // i.e: do we have the same elements visible than before scrolling ?
                reachedTheEnd = (allElements == allVisibleElements)
                allVisibleElements = allElements
                
                // Then, we do a scroll up on the scrollview
                let startCoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.99, dy: 0.9))
                startCoordinate.press(forDuration: 0.01, thenDragTo: self.coordinate(withNormalizedOffset:CGVector(dx: 0.99, dy: 0.1)))
            }
            return nil
        }
        

        // After this, you may want to scroll to top ...
        func statusBarScrollToTop() {
            let statusBar = XCUIApplication().statusBars.element
            statusBar.doubleTap()
        }
}


public func expectExists(_ element: XCUIElement?, timeout: Double = 2) {
    expect(element?.waitForExistence(timeout: timeout)).to(beTrue())
}


public func expectNotExists(_ element: XCUIElement?, timeout: Double = 2) {
    expect(element?.exists).to(beFalse())
}
